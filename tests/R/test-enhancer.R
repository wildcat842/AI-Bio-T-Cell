library(testthat)
source(here::here("src", "R", "R", "enhancer_analysis.R"))

test_that("overlap_snps_with_enhancers returns empty for non-overlapping inputs", {
  skip_if_not_installed("GenomicRanges")
  skip_if_not_installed("IRanges")
  enhancers <- GenomicRanges::GRanges(
    seqnames = "chr1",
    ranges = IRanges::IRanges(start = 1000, end = 2000),
    name = "e1"
  )
  snps <- data.frame(chr = "chr1", pos = 5000, rsid = "rs1", trait = "RA")
  out <- overlap_snps_with_enhancers(enhancers, snps)
  expect_equal(nrow(out), 0)
})

test_that("overlap returns a hit when SNP is inside enhancer", {
  skip_if_not_installed("GenomicRanges")
  skip_if_not_installed("IRanges")
  enhancers <- GenomicRanges::GRanges(
    seqnames = "chr1",
    ranges = IRanges::IRanges(start = 1000, end = 2000),
    name = "e1"
  )
  snps <- data.frame(chr = "chr1", pos = 1500, rsid = "rs1", trait = "RA")
  out <- overlap_snps_with_enhancers(enhancers, snps)
  expect_equal(nrow(out), 1)
  expect_equal(out$enhancer_id, "e1")
})
