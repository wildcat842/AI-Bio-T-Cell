"""aibio - AI Virtual Cells for T-Cell immunology.

Public submodules:
    data            - dataset loaders for ReapTEC, scRNA-seq, etc.
    preprocessing   - AnnData/MuData preprocessing helpers
    models          - flow matching, diffusion, GNN model wrappers
    eval            - evaluation metrics for trajectory & perturbation
    utils           - logging, config, IO

See README.md and obsidian/ for project context.
"""

__version__ = "0.1.0"
__author__ = "Sojung Kim"

from . import data, eval, models, preprocessing, utils  # noqa: F401

__all__ = ["data", "preprocessing", "models", "eval", "utils", "__version__"]
