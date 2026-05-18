"""Flow Matching trainer skeleton (Topic 1).

This module is intentionally minimal. Hook torchcfm or a custom CFM
implementation here when the trajectory data is ready.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional


@dataclass
class FlowMatchingConfig:
    """Hyperparameters for conditional flow matching."""

    n_pcs: int = 50
    sigma: float = 0.1
    batch_size: int = 256
    lr: float = 1e-3
    epochs: int = 100
    device: str = "cuda"
    seed: int = 42
    log_dir: str = "experiments/topic1/runs"


class FlowMatchingTrainer:
    """Skeleton trainer. Replace `fit` body with actual CFM loop."""

    def __init__(self, config: Optional[FlowMatchingConfig] = None) -> None:
        self.config = config or FlowMatchingConfig()

    def fit(self, X0, X1):  # pragma: no cover - skeleton
        """Train a conditional vector field that transports X0 -> X1.

        X0, X1: torch.Tensor of shape (n, n_pcs).
        """
        raise NotImplementedError(
            "Implement CFM training loop. See torchcfm.ConditionalFlowMatcher."
        )

    def sample_trajectory(self, X0, n_steps: int = 100):  # pragma: no cover - skeleton
        raise NotImplementedError("Implement ODE solver-based sampling.")
