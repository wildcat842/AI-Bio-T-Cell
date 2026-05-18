"""Smoke test for the dataset registry."""
from aibio.data import DATASET_REGISTRY, get_dataset_path


def test_registry_nonempty() -> None:
    assert len(DATASET_REGISTRY) >= 10, (
        f"Expected at least 10 datasets, got {len(DATASET_REGISTRY)}"
    )


def test_reaptec_in_registry() -> None:
    assert "RIKEN ReapTEC T-Cell Atlas" in DATASET_REGISTRY


def test_get_dataset_path_resolves() -> None:
    p = get_dataset_path("RIKEN ReapTEC T-Cell Atlas")
    # path may not exist on disk yet, but must be absolute
    assert p.is_absolute()
