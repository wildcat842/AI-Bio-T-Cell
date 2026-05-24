#!/bin/bash
# r_quiet.sh
# Rscript wrapper that suppresses reticulate's cosmetic warnings on Miniforge.
#
# Why: when reticulate auto-detects a conda env it tries to source
#   <env>/bin/activate, which does NOT exist in Miniforge (the activate
#   script lives only in base). The resulting "No such file" and
#   "CondaError: Run 'conda init' before 'conda activate'" come from bash,
#   not R, so R's suppressWarnings() cannot mute them.
#
# This wrapper filters those specific stderr lines while passing through
# every other R error/warning unchanged.
#
# Usage:
#   bash scripts/r_quiet.sh -e 'library(reticulate); print(py_config())'
#   bash scripts/r_quiet.sh path/to/script.R
#   bash scripts/r_quiet.sh -e 'library(Seurat); ...'    # also fine
#
# Notes:
#   - Real errors are NOT suppressed - they go through unchanged.
#   - Stdout is untouched.
#   - This is a convenience for interactive work and CI logs.
#   - For details see obsidian/60_Methods/R_Manual.md §13.

if [[ $# -eq 0 ]]; then
  echo "Usage: bash $0 -e '<R code>' | <script.R>" >&2
  exit 2
fi

# Patterns to filter out (extended regex, line-anchored where possible).
# Add new patterns here if more cosmetic noise appears.
FILTERS=(
  'activate: No such file or directory'
  "CondaError: Run 'conda init' before 'conda activate'"
  'normalizePath\(file\.path\(dirname\(conda\)'
  'path\[1\]=.*activate.*No such file'
  '^Warning messages:$'
  '^[0-9]+: In normalizePath'
  'FutureWarning.*__version__.*deprecated'
)

# Build single grep -vE pattern
PAT="$(IFS='|'; echo "${FILTERS[*]}")"

# Run Rscript with stderr filtered via process substitution
exec Rscript "$@" 2> >(grep -vE "$PAT" >&2)
