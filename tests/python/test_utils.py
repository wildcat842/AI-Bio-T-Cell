"""Smoke tests for utils."""
from aibio.utils import get_logger, set_seed


def test_get_logger() -> None:
    log = get_logger("test")
    assert log is not None
    log.info("hello from test")


def test_set_seed() -> None:
    import random
    set_seed(42)
    a = random.random()
    set_seed(42)
    b = random.random()
    assert a == b
