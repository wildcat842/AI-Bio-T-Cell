"""Project-wide logger factory with sensible defaults."""
from __future__ import annotations

import logging
import sys
from typing import Optional

_CONFIGURED = False


def _configure(level: int = logging.INFO) -> None:
    global _CONFIGURED
    if _CONFIGURED:
        return
    handler = logging.StreamHandler(sys.stderr)
    fmt = "%(asctime)s [%(levelname)s] %(name)s - %(message)s"
    handler.setFormatter(logging.Formatter(fmt, datefmt="%Y-%m-%dT%H:%M:%S"))
    root = logging.getLogger()
    root.setLevel(level)
    root.addHandler(handler)
    _CONFIGURED = True


def get_logger(name: Optional[str] = None, level: int = logging.INFO) -> logging.Logger:
    _configure(level)
    return logging.getLogger(name or "aibio")
