# AI-Bio-T-Cell - 공통 작업 자동화
# 사용 예: make help, make setup-py, make lint-py, make test, make notebook

.PHONY: help setup-py setup-r lint-py format-py test test-py test-r data-catalog \
        clean-py clean-r notebook serve-docs gitkeep

PY ?= python
R  ?= Rscript

help:
	@echo "Available targets:"
	@echo "  setup-py     - install Python deps (editable + dev/ml)"
	@echo "  setup-r      - install R deps via renv"
	@echo "  lint-py      - run ruff on src/python and tests/python"
	@echo "  format-py    - run black on src/python and tests/python"
	@echo "  test         - run all tests (python + R)"
	@echo "  test-py      - pytest"
	@echo "  test-r       - testthat"
	@echo "  data-catalog - show datasets/data_catalog.csv preview"
	@echo "  notebook     - launch jupyter lab from project root"
	@echo "  serve-docs   - serve docs locally"
	@echo "  gitkeep      - add .gitkeep to empty data dirs"
	@echo "  clean-py     - remove __pycache__/.pytest_cache/.ruff_cache"
	@echo "  clean-r      - remove .Rcheck/.Rhistory"

setup-py:
	$(PY) -m pip install -e ".[dev,ml]"

setup-r:
	$(R) -e 'if (!requireNamespace("renv", quietly=TRUE)) install.packages("renv"); renv::restore()'

lint-py:
	ruff check src/python tests/python

format-py:
	black src/python tests/python
	ruff check --fix src/python tests/python

test: test-py test-r

test-py:
	pytest tests/python -q

test-r:
	$(R) -e 'testthat::test_dir("tests/R")'

data-catalog:
	@head -n 5 datasets/data_catalog.csv
	@echo "..."
	@wc -l datasets/data_catalog.csv

notebook:
	jupyter lab --notebook-dir=.

serve-docs:
	@echo "TODO: hook quarto/mkdocs serve"

gitkeep:
	@for d in data/raw data/interim data/processed data/external reports/figures reports/tables; do \
		touch $$d/.gitkeep; \
	done
	@echo "[OK] .gitkeep placed."

clean-py:
	find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	rm -rf .pytest_cache .ruff_cache .mypy_cache htmlcov .coverage

clean-r:
	find . -type d -name "*.Rcheck" -prune -exec rm -rf {} +
	find . -type f -name ".Rhistory" -delete
