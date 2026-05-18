#' Standard Signac preprocessing for scATAC-seq (e.g., ReapTEC-derived)
#' @export
preprocess_signac <- function(seurat_atac, min_features = 1000) {
  if (!requireNamespace("Signac", quietly = TRUE)) {
    stop("Signac is required. install.packages('Signac')")
  }
  Signac::DefaultAssay(seurat_atac) <- "peaks"
  seurat_atac <- Signac::RunTFIDF(seurat_atac, verbose = FALSE)
  seurat_atac <- Signac::FindTopFeatures(seurat_atac, min.cutoff = "q75")
  seurat_atac <- Signac::RunSVD(seurat_atac, verbose = FALSE)
  seurat_atac <- Seurat::FindNeighbors(seurat_atac, reduction = "lsi", dims = 2:30)
  seurat_atac <- Seurat::RunUMAP(seurat_atac, reduction = "lsi", dims = 2:30, verbose = FALSE)
  seurat_atac
}
