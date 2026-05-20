#!/usr/bin/env Rscript
# rds_to_h5ad.R
# Convert ReapTEC Seurat .rds files to AnnData (.h5ad) for Python interop.
#
# Usage:
#   Rscript rds_to_h5ad.R --in processed/seurat_objects --out processed/h5ad
#
# Requirements (CRAN/Bioc):
#   - Seurat (>= 5.0)
#   - SeuratDisk (for h5Seurat -> h5ad)        OR
#   - sceasy + reticulate + anndata (alternative one-shot path)
#
# Strategy:
#   We prefer sceasy::convertFormat which calls anndata via reticulate.
#   Fall back to SeuratDisk SaveH5Seurat + Convert(..., dest='h5ad') if sceasy is unavailable.

suppressPackageStartupMessages({
  library(optparse)
})

option_list <- list(
  make_option(c("--in"),  type = "character", default = "processed/seurat_objects",
              help = "Input directory containing .rds Seurat files [%default]"),
  make_option(c("--out"), type = "character", default = "processed/h5ad",
              help = "Output directory for .h5ad files [%default]"),
  make_option(c("--assay"), type = "character", default = "RNA",
              help = "Seurat assay to export [%default]"),
  make_option(c("--max_size_gb"), type = "double", default = 12.0,
              help = "Skip .rds files larger than this (memory safety) [%default]"),
  make_option(c("--overwrite"), action = "store_true", default = FALSE,
              help = "Re-convert even if .h5ad exists")
)
opt <- parse_args(OptionParser(option_list = option_list))

dir.create(opt$out, showWarnings = FALSE, recursive = TRUE)

rds_files <- list.files(opt$`in`, pattern = "\\.[rR]ds$", full.names = TRUE, recursive = TRUE)
if (length(rds_files) == 0) stop("No .rds files found under: ", opt$`in`)

cat(sprintf("[INFO] Found %d .rds files in %s\n", length(rds_files), opt$`in`))

# Choose conversion backend
backend <- NULL
if (requireNamespace("sceasy", quietly = TRUE) &&
    requireNamespace("reticulate", quietly = TRUE)) {
  backend <- "sceasy"
} else if (requireNamespace("SeuratDisk", quietly = TRUE)) {
  backend <- "seuratdisk"
} else {
  stop("Need one of: sceasy+reticulate+anndata (Python)  OR  SeuratDisk.\n",
       "  install.packages('SeuratDisk')  # github.com/mojaveazure/seurat-disk\n",
       "  or use sceasy: remotes::install_github('cellgeni/sceasy')")
}
cat(sprintf("[INFO] Using backend: %s\n", backend))

convert_one <- function(rds_path) {
  base <- tools::file_path_sans_ext(basename(rds_path))
  out  <- file.path(opt$out, paste0(base, ".h5ad"))
  if (!opt$overwrite && file.exists(out)) {
    cat(sprintf("[SKIP] %s exists (use --overwrite)\n", out)); return(invisible(NULL))
  }
  sz_gb <- file.info(rds_path)$size / 1e9
  if (sz_gb > opt$max_size_gb) {
    cat(sprintf("[WARN] %s is %.1f GB > --max_size_gb=%.1f, skipping. ",
                rds_path, sz_gb, opt$max_size_gb))
    cat("Convert manually or raise --max_size_gb.\n")
    return(invisible(NULL))
  }
  cat(sprintf("[CONV] %s (%.2f GB) -> %s\n", rds_path, sz_gb, out))
  obj <- readRDS(rds_path)
  if (!inherits(obj, "Seurat")) {
    cat(sprintf("[WARN] %s is not a Seurat object (class=%s). Skipping.\n",
                rds_path, paste(class(obj), collapse = "/")))
    return(invisible(NULL))
  }
  # Ensure assay exists
  if (!opt$assay %in% Seurat::Assays(obj)) {
    cat(sprintf("[WARN] Assay '%s' not in object (assays: %s). Skipping.\n",
                opt$assay, paste(Seurat::Assays(obj), collapse = ", ")))
    return(invisible(NULL))
  }
  Seurat::DefaultAssay(obj) <- opt$assay

  if (backend == "sceasy") {
    sceasy::convertFormat(obj,
                          from = "seurat", to = "anndata",
                          outFile = out, main_layer = "data",
                          assay = opt$assay)
  } else {
    # SeuratDisk path: write h5Seurat then Convert
    tmp <- tempfile(fileext = ".h5Seurat")
    SeuratDisk::SaveH5Seurat(obj, filename = tmp, overwrite = TRUE)
    SeuratDisk::Convert(tmp, dest = "h5ad", assay = opt$assay)
    h5ad_tmp <- sub("\\.h5Seurat$", ".h5ad", tmp)
    file.rename(h5ad_tmp, out)
    file.remove(tmp)
  }
  cat(sprintf("[ OK ] %s written\n", out))
}

# Run sequentially (memory-safe). Use Sys.setenv(OMP_NUM_THREADS=1) for predictability.
for (f in rds_files) {
  try(convert_one(f), silent = FALSE)
  invisible(gc())
}

cat("[DONE] Conversion complete.\n")
