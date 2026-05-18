# 01_load_reaptec.R
# Quick loader for ReapTEC processed atlas. Run from project root:
#   Rscript src/R/scripts/01_load_reaptec.R

suppressPackageStartupMessages({
  library(here)
  source(here("src", "R", "R", "enhancer_analysis.R"))
})

reaptec_dir <- here("datasets", "01_reaptec_atlas", "processed")
if (!dir.exists(reaptec_dir)) {
  stop(sprintf("Run datasets/01_reaptec_atlas/scripts/download_processed.sh first. Missing: %s", reaptec_dir))
}

bed <- list.files(reaptec_dir, pattern = "\\.bed(\\.gz)?$", full.names = TRUE)
if (length(bed) == 0) stop("No BED file found under processed/.")
cat("[INFO] Found BED:", bed[1], "\n")

gr <- rtracklayer::import(bed[1], format = "BED")
cat("[INFO] Loaded", length(gr), "enhancer regions.\n")
print(summary(GenomicRanges::width(gr)))
