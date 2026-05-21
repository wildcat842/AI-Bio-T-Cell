#!/bin/bash
# setup_miniforge.sh
# Linux 공용 서버에서 Miniforge3 -> conda env "AI-Bio-T-Cell" 일괄 셋업.
#
# 사용:
#   bash scripts/setup_miniforge.sh                          # 표준 (Python + R + GPU)
#   bash scripts/setup_miniforge.sh --installer ~/Downloads/Miniforge3-Linux-x86_64.sh
#   bash scripts/setup_miniforge.sh --no-gpu                 # CPU만
#   bash scripts/setup_miniforge.sh --skip-miniforge         # miniforge 이미 깔린 경우
#   bash scripts/setup_miniforge.sh --skip-env               # env 생성 건너뜀
#   bash scripts/setup_miniforge.sh --env-name myenv         # 이름 변경
#
# 단계:
#   [1] Miniforge3 설치 (~/miniforge3)
#   [2] conda init bash
#   [3] mamba env create -f environment.yml
#   [4] conda activate <env>
#   [5] pip install -e ".[dev,ml,bridge,genome]" (이미 environment.yml의 pip:에 있지만 안전망)
#   [6] R bridge 설치 (sceasy, SeuratDisk)
#   [7] verification: nvidia-smi, python -c "import aibio; import torch", Rscript -e "library(Seurat)"

set -euo pipefail

INSTALLER="${HOME}/Miniforge3-Linux-x86_64.sh"
SKIP_MINIFORGE=0
SKIP_ENV=0
ENV_NAME="AI-Bio-T-Cell"
USE_GPU=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --installer)        INSTALLER="$2"; shift 2 ;;
    --skip-miniforge)   SKIP_MINIFORGE=1; shift ;;
    --skip-env)         SKIP_ENV=1; shift ;;
    --env-name)         ENV_NAME="$2"; shift 2 ;;
    --no-gpu)           USE_GPU=0; shift ;;
    -h|--help)          sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
done

log()  { printf '\033[36m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }
ok()   { printf '\033[32m[ OK ]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
err()  { printf '\033[31m[ERR ]\033[0m %s\n' "$*"; exit 1; }

# Verify we are at repo root
[[ -f pyproject.toml && -f environment.yml ]] || \
  err "Run this script from the AI-Bio-T-Cell repo root. Current: $(pwd)"

# -------------------------------------------------------------------
# [1] Miniforge3 install
# -------------------------------------------------------------------
MINIFORGE_PREFIX="${HOME}/miniforge3"
if [[ "$SKIP_MINIFORGE" -eq 0 ]]; then
  if [[ -d "$MINIFORGE_PREFIX" ]]; then
    warn "miniforge already at $MINIFORGE_PREFIX -> skipping install"
  else
    [[ -f "$INSTALLER" ]] || err "Installer not found: $INSTALLER  (use --installer PATH)"
    log "Installing Miniforge3 to $MINIFORGE_PREFIX"
    bash "$INSTALLER" -b -p "$MINIFORGE_PREFIX"
    ok "Miniforge installed"
  fi
fi

# Source the conda hooks
# shellcheck disable=SC1091
source "${MINIFORGE_PREFIX}/etc/profile.d/conda.sh"
# shellcheck disable=SC1091
[[ -f "${MINIFORGE_PREFIX}/etc/profile.d/mamba.sh" ]] && source "${MINIFORGE_PREFIX}/etc/profile.d/mamba.sh"

# conda init bash if not already
if ! grep -q "miniforge3/etc/profile.d/conda.sh" "${HOME}/.bashrc" 2>/dev/null; then
  log "conda init bash"
  "${MINIFORGE_PREFIX}/bin/conda" init bash >/dev/null
  ok "conda init done. New shells will auto-activate base."
fi

# -------------------------------------------------------------------
# [2] Create env from environment.yml
# -------------------------------------------------------------------
if [[ "$SKIP_ENV" -eq 0 ]]; then
  if conda env list | grep -qE "^${ENV_NAME}\s"; then
    log "env '$ENV_NAME' exists -> mamba env update --prune"
    mamba env update -n "$ENV_NAME" -f environment.yml --prune
  else
    log "Creating env '$ENV_NAME' from environment.yml (this may take 15-30 minutes)"
    CONDA_SOLVER=libmamba mamba env create -n "$ENV_NAME" -f environment.yml
  fi
  ok "Env '$ENV_NAME' ready"
fi

# Activate
conda activate "$ENV_NAME"
log "Active env: $CONDA_DEFAULT_ENV  (python=$(python -V 2>&1))"

# -------------------------------------------------------------------
# [3] Editable project install (in case environment.yml's pip section was skipped)
# -------------------------------------------------------------------
log "Editable install: pip install -e \".[dev,ml,bridge,genome]\""
# uv if available (faster), else pip
if command -v uv >/dev/null 2>&1; then
  uv pip install -e ".[dev,ml,bridge,genome]" || pip install -e ".[dev,ml,bridge,genome]"
else
  pip install -e ".[dev,ml,bridge,genome]"
fi
ok "Project installed"

# -------------------------------------------------------------------
# [4] R bridge (sceasy, SeuratDisk)
# -------------------------------------------------------------------
if command -v Rscript >/dev/null 2>&1; then
  log "Installing R bridge (sceasy, SeuratDisk via remotes::install_github)"
  Rscript datasets/01_reaptec_atlas/scripts/install_r_bridge.R || \
    warn "R bridge install had issues - check log"
else
  warn "Rscript not found in env. R 패키지 누락 가능성. environment.yml의 r-base 설치 확인."
fi

# -------------------------------------------------------------------
# [5] Verification
# -------------------------------------------------------------------
log "=== Verification ==="

# GPU
if [[ "$USE_GPU" -eq 1 ]] && command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi | head -8
  python - <<'PY'
import torch
print(f"[torch] {torch.__version__}  CUDA available={torch.cuda.is_available()}  device_count={torch.cuda.device_count()}")
if torch.cuda.is_available():
    print(f"[torch] device 0 = {torch.cuda.get_device_name(0)}")
PY
fi

# aibio import
python -c "import aibio; print('[aibio] version', aibio.__version__)" || warn "aibio import failed"

# Pytest smoke
if command -v pytest >/dev/null 2>&1; then
  log "pytest tests/python -q"
  pytest tests/python -q || warn "pytest had failures (review tests/python/)"
fi

# R Seurat
if command -v Rscript >/dev/null 2>&1; then
  log "R smoke test (Seurat + reticulate)"
  Rscript -e 'suppressPackageStartupMessages({library(Seurat); library(reticulate)});
              cat("[Seurat] version ", as.character(packageVersion("Seurat")), "\n");
              cat("[reticulate] python ", reticulate::py_config()$python, "\n")' || \
    warn "R smoke test failed"
fi

# Catalog visible
python -c "from aibio.data import DATASET_REGISTRY; print('[catalog]', len(DATASET_REGISTRY), 'datasets')" \
  || warn "catalog import failed"

ok "Setup complete."

cat <<'EOS'

=========================================================================
[NEXT]
1) 새 셸 열기 또는 'source ~/.bashrc' 로 conda 자동 활성화.
2) 'conda activate AI-Bio-T-Cell' 로 env 진입.
3) Dryad 데이터 다운로드:
     bash datasets/01_reaptec_atlas/scripts/download_dryad.sh --tier p0
4) Daily 노트:
     obsidian/30_Daily/2026-05-22.md  (체크리스트 시드 포함)
=========================================================================
EOS
