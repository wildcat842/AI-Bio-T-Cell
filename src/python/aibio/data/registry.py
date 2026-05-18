"""Single source of truth for dataset paths.

The CSV at `datasets/data_catalog.csv` is the canonical catalog. This module
reads it once and exposes a lookup by short name.
"""
from __future__ import annotations

import csv
from pathlib import Path
from typing import Dict

REPO_ROOT = Path(__file__).resolve().parents[4]
CATALOG_PATH = REPO_ROOT / "datasets" / "data_catalog.csv"


def _load_registry() -> Dict[str, dict]:
    if not CATALOG_PATH.exists():
        return {}
    registry: Dict[str, dict] = {}
    with CATALOG_PATH.open("r", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            registry[row["dataset_name"]] = row
    return registry


DATASET_REGISTRY: Dict[str, dict] = _load_registry()


def get_dataset_path(name: str) -> Path:
    """Return absolute path to the dataset's local storage folder."""
    if name not in DATASET_REGISTRY:
        raise KeyError(f"Dataset '{name}' not in catalog. Available: {list(DATASET_REGISTRY)[:5]}...")
    rel = DATASET_REGISTRY[name]["storage_path"]
    return (REPO_ROOT / rel).resolve()
