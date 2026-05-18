"""Lightweight evaluation metrics."""
from __future__ import annotations

import numpy as np


def wasserstein_distance_proxy(x: np.ndarray, y: np.ndarray) -> float:
    """Sliced-1D Wasserstein proxy for high-dimensional cell embeddings.

    For full Wasserstein use POT (Python Optimal Transport). This proxy averages
    1D Wasserstein over each dimension and is suitable for quick sanity checks.
    """
    from scipy.stats import wasserstein_distance
    if x.shape[1] != y.shape[1]:
        raise ValueError(f"Dim mismatch: {x.shape[1]} vs {y.shape[1]}")
    dists = [wasserstein_distance(x[:, d], y[:, d]) for d in range(x.shape[1])]
    return float(np.mean(dists))
