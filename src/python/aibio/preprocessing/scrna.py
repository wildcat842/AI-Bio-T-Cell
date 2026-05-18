"""Standard scRNA-seq preprocessing wrappers around scanpy."""
from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from anndata import AnnData


def standard_qc(adata: "AnnData", min_genes: int = 200, min_cells: int = 3,
                pct_mt_max: float = 20.0) -> "AnnData":
    """Apply common QC filters and return a new AnnData (does not modify input)."""
    import scanpy as sc
    a = adata.copy()
    sc.pp.filter_cells(a, min_genes=min_genes)
    sc.pp.filter_genes(a, min_cells=min_cells)
    a.var["mt"] = a.var_names.str.upper().str.startswith(("MT-", "MT."))
    sc.pp.calculate_qc_metrics(a, qc_vars=["mt"], percent_top=None, log1p=False, inplace=True)
    a = a[a.obs["pct_counts_mt"] < pct_mt_max].copy()
    return a


def log_norm_pca(adata: "AnnData", target_sum: float = 1e4, n_pcs: int = 50) -> "AnnData":
    """Total-count normalize, log1p, HVG, scale, PCA."""
    import scanpy as sc
    a = adata.copy()
    sc.pp.normalize_total(a, target_sum=target_sum)
    sc.pp.log1p(a)
    sc.pp.highly_variable_genes(a, n_top_genes=2000, flavor="seurat_v3")
    sc.pp.scale(a, max_value=10)
    sc.tl.pca(a, n_comps=n_pcs)
    return a
