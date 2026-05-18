#' Overlap a set of GWAS SNPs with ReapTEC enhancer regions
#'
#' @param enhancers_bed Path to BED file (or a GRanges object) of enhancer coordinates.
#' @param snps_df data.frame with columns chr, pos (and optionally rsid, trait).
#' @return data.frame of overlaps with enhancer_id, snp columns.
#' @export
overlap_snps_with_enhancers <- function(enhancers_bed, snps_df) {
  if (!requireNamespace("GenomicRanges", quietly = TRUE)) {
    stop("GenomicRanges is required. BiocManager::install('GenomicRanges')")
  }
  if (is.character(enhancers_bed)) {
    enhancers <- rtracklayer::import(enhancers_bed, format = "BED")
  } else {
    enhancers <- enhancers_bed
  }
  if (is.null(enhancers$name)) enhancers$name <- paste0("e", seq_along(enhancers))

  snp_gr <- GenomicRanges::GRanges(
    seqnames = snps_df$chr,
    ranges = IRanges::IRanges(start = snps_df$pos, end = snps_df$pos),
    rsid = if (!is.null(snps_df$rsid)) snps_df$rsid else NA,
    trait = if (!is.null(snps_df$trait)) snps_df$trait else NA
  )
  hits <- GenomicRanges::findOverlaps(snp_gr, enhancers)
  data.frame(
    snp_index    = S4Vectors::queryHits(hits),
    rsid         = snp_gr$rsid[S4Vectors::queryHits(hits)],
    trait        = snp_gr$trait[S4Vectors::queryHits(hits)],
    enhancer_id  = enhancers$name[S4Vectors::subjectHits(hits)],
    enhancer_chr = as.character(GenomicRanges::seqnames(enhancers))[S4Vectors::subjectHits(hits)],
    enhancer_start = GenomicRanges::start(enhancers)[S4Vectors::subjectHits(hits)],
    enhancer_end   = GenomicRanges::end(enhancers)[S4Vectors::subjectHits(hits)]
  )
}
