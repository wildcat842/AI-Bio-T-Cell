"""Loader skeleton for RIKEN ReapTEC enhancer atlas.

The actual atlas files (BED, h5ad) live under `datasets/01_reaptec_atlas/processed/`
once downloaded. This loader currently exposes a thin wrapper; replace stubs
with concrete IO as data becomes available.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Optional


@dataclass
class ReapTECLoader:
    """Lazy loader for the RIKEN ReapTEC enhancer atlas."""

    root: Path
    version: str = "2024-science"

    @classmethod
    def from_catalog(cls) -> "ReapTECLoader":
        from .registry import get_dataset_path
        return cls(root=get_dataset_path("RIKEN ReapTEC T-Cell Atlas") / "processed")

    def enhancers_bed(self) -> Optional[Path]:
        """Return path to the enhancer BED file, or None if not yet downloaded."""
        for candidate in ("enhancers.bed", "reaptec_enhancers.bed.gz"):
            p = self.root / candidate
            if p.exists():
                return p
        return None

    def expression_h5ad(self) -> Optional[Path]:
        p = self.root / "tcell_expression.h5ad"
        return p if p.exists() else None

    def __repr__(self) -> str:  # pragma: no cover - cosmetic
        return f"ReapTECLoader(root={self.root}, version={self.version})"
