#!/usr/bin/env Rscript
# install_r_bridge.R
# Install R packages that are NOT on conda-forge (sceasy, SeuratDisk).
# Run from inside the conda env "AI-Bio-T-Cell" AFTER environment.yml installation.
#
# Usage:
#   conda activate AI-Bio-T-Cell
#   Rscript datasets/01_reaptec_atlas/scripts/install_r_bridge.R

cat("== install_r_bridge.R - setting up Seurat <-> AnnData bridge ==\n")

# 1) Point reticulate to the active conda env's python
py <- Sys.getenv("CONDA_PREFIX")
if (nzchar(py)) {
  Sys.setenv(RETICULATE_PYTHON = file.path(py, "bin", "python"))
  cat(sprintf("[INFO] RETICULATE_PYTHON = %s\n", Sys.getenv("RETICULATE_PYTHON")))
}

# 2) Required: remotes (should already be installed via conda)
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cloud.r-project.org")
}

# 3) Install GitHub-only packages
pkgs <- list(
  sceasy      = "cellgeni/sceasy",
  SeuratDisk  = "mojaveazure/seurat-disk"
)

for (p in names(pkgs)) {
  if (!requireNamespace(p, quietly = TRUE)) {
    cat(sprintf("[INFO] installing %s from GitHub: %s\n", p, pkgs[[p]]))
    remotes::install_github(pkgs[[p]], upgrade = "never", build_vignettes = FALSE)
  } else {
    cat(sprintf("[ OK ] %s already installed (%s)\n", p, packageVersion(p)))
  }
}

# 4) Verify reticulate <-> Python anndata is reachable
ok <- TRUE
if (requireNamespace("reticulate", quietly = TRUE)) {
  reticulate::use_condaenv(condaenv = "AI-Bio-T-Cell", required = TRUE, conda = "auto")
  if (!reticulate::py_module_available("anndata")) {
    cat("[WARN] python 'anndata' not visible to reticulate. Check env activation.\n")
    ok <- FALSE
  } else {
    cat(sprintf("[ OK ] reticulate -> python anndata version: %s\n",
                reticulate::py_get_attr(reticulate::import("anndata"), "__version__")))
  }
} else {
  cat("[WARN] reticulate missing - install r-reticulate via conda first.\n")
  ok <- FALSE
}

# 5) Smoke test: create a tiny Seurat object and convert to AnnData
if (ok && requireNamespace("Seurat", quietly = TRUE) &&
    requireNamespace("sceasy", quietly = TRUE)) {
  cat("[TEST] roundtrip Seurat -> AnnData ... ")
  set.seed(1)
  mat <- matrix(rpois(50 * 20, 2), nrow = 50)
  rownames(mat) <- paste0("g", 1:50); colnames(mat) <- paste0("c", 1:20)
  obj <- Seurat::CreateSeuratObject(counts = mat)
  tmp <- tempfile(fileext = ".h5ad")
  sceasy::convertFormat(obj, from = "seurat", to = "anndata",
                        outFile = tmp, main_layer = "counts", assay = "RNA")
  ok_file <- file.exists(tmp) && file.info(tmp)$size > 0
  cat(if (ok_file) "OK\n" else "FAIL\n")
  if (ok_file) {
    cat(sprintf("[ OK ] wrote %s (%.1f KB)\n", tmp, file.info(tmp)$size / 1024))
    file.remove(tmp)
  }
}

cat("[DONE] R bridge ready.\n")
