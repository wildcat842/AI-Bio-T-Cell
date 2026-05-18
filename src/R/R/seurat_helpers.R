#' Standard Seurat QC + normalization for T-cell scRNA-seq
#'
#' Wraps the most common preprocessing steps. Returns the modified object.
#'
#' @param seurat A Seurat object.
#' @param min_features Minimum features per cell (default 200).
#' @param max_mt_pct Maximum percent mitochondrial (default 20).
#' @param npcs Number of PCs to compute (default 50).
#' @return A Seurat object after QC, normalization, HVG, scaling, PCA, neighbors, UMAP.
#' @export
preprocess_seurat <- function(seurat, min_features = 200, max_mt_pct = 20, npcs = 50) {
  if (!requireNamespace("Seurat", quietly = TRUE)) {
    stop("Seurat is required. install.packages('Seurat')")
  }
  seurat[["percent.mt"]] <- Seurat::PercentageFeatureSet(seurat, pattern = "^MT-")
  seurat <- subset(seurat,
                   subset = nFeature_RNA >= min_features &
                            percent.mt < max_mt_pct)
  seurat <- Seurat::NormalizeData(seurat, verbose = FALSE)
  seurat <- Seurat::FindVariableFeatures(seurat, nfeatures = 2000, verbose = FALSE)
  seurat <- Seurat::ScaleData(seurat, verbose = FALSE)
  seurat <- Seurat::RunPCA(seurat, npcs = npcs, verbose = FALSE)
  seurat <- Seurat::FindNeighbors(seurat, dims = 1:npcs, verbose = FALSE)
  seurat <- Seurat::RunUMAP(seurat, dims = 1:npcs, verbose = FALSE)
  seurat
}


#' Subset to T-cell lineage by common markers
#'
#' Uses CD3D/CD3E/CD3G expression and (optional) cluster annotation.
#' @export
subset_t_cells <- function(seurat, min_cd3 = 1) {
  expr <- Seurat::GetAssayData(seurat, slot = "data")
  cd3_markers <- intersect(c("CD3D", "CD3E", "CD3G"), rownames(expr))
  if (length(cd3_markers) == 0) stop("No CD3D/E/G found in rownames(expr).")
  cd3_score <- Matrix::colSums(expr[cd3_markers, , drop = FALSE])
  keep <- cd3_score >= min_cd3
  seurat[, keep]
}
