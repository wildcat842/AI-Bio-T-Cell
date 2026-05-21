#!/bin/bash
# setup_miniforge.sh
# Linux 공용 서버에서 Miniforge3 -> conda env "AI-Bio-T-Cell" 일괄 셋업.
#
# 사용:
#   bash scripts/setup_miniforge.sh
#   bash scripts/setup_miniforge.sh --skip-miniforge         # miniforge 이미 깔린 경우
#   bash scripts/setup_miniforge.sh --installer ~/Miniforge3-Linux-x86_64.sh
#   bash scripts/setup_miniforge.sh --env-name myenv
#   bash scripts/setup_miniforge.sh --no-gpu
#   CUDA_TAG=cu121 bash scripts/setup_miniforge.sh           # CUDA 변경

set -euo pipefail

INSTALLER="${HOME}/Miniforge3-Linux-x86_64.sh"
SKIP_MINIFORGE=0
SKIP_ENV=0
ENV_NAME="AI-Bio-T-Cell"
USE_GPU=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --installer)      INSTALLER="$2"; shift 2 ;;
    --skip-miniforge) SKIP_MINIFORGE=1; shift ;;
    --skip-env)       SKIP_ENV=1; shift ;;
    --env-name)       ENV_NAME="$2"; shift 2 ;;
    --no-gpu)         USE_GPU=0; shift ;;
    -h|--help)        sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
done

log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
ok()   { printf '[ OK ] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
err()  { printf '[ERR ] %s\n' "$*"; exit 1; }

[[ -f pyproject.toml && -f environment.yml ]] || \
  err "Run from AI-Bio-T-Cell repo root. cwd=$(pwd)"

# [1] Miniforge3 install
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

source "${MINIFORGE_PREFIX}/etc/profile.d/conda.sh"
[[ -f "${MINIFORGE_PREFIX}/etc/profile.d/mamba.sh" ]] && \
  source "${MINIFORGE_PREFIX}/etc/profile.d/mamba.sh"

if ! grep -q "miniforge3/etc/profile.d/conda.sh" "${HOME}/.bashrc" 2>/dev/null; then
  log "conda init bash"
  "${MINIFORGE_PREFIX}/bin/conda" init bash >/dev/null
fi

# [2] Create/update env
if [[ "$SKIP_ENV" -eq 0 ]]; then
  if conda env list | grep -qE "^${ENV_NAME}\s"; then
    log "env '$ENV_NAME' exists -> mamba env update --prune"
    mamba env update -n "$ENV_NAME" -f environment.yml --prune
  else
    log "Creating env '$ENV_NAME' (15-30 min)"
    CONDA_SOLVER=libmamba mamba env create -n "$ENV_NAME" -f environment.yml
  fi
  ok "Env ready"
fi

conda activate "$ENV_NAME"
log "Active env: $CONDA_DEFAULT_ENV  python=$(python -V 2>&1)"

# [3a] PyTorch with CUDA wheel - SEPARATE from environment.yml
# environment.yml에 --extra-index-url 두면 uv dep-confusion 보호 동작이 다른
# 패키지(rpy2 등) 설치를 깨뜨림. 그래서 여기서 torch만 별도 install.
CUDA_TAG="${CUDA_TAG:-cu124}"
TORCH_INDEX="https://download.pytorch.org/whl/${CUDA_TAG}"
log "Installing PyTorch from $TORCH_INDEX (pip)"
python -m pip install --index-url "$TORCH_INDEX" \
  "torch>=2.4,<2.6" "torchvision>=0.19" "torchaudio>=2.4"
python -m pip install "lightning>=2.4"
ok "PyTorch installed (CUDA $CUDA_TAG)"

# [3b] Editable project
log "pip install -e .[dev,ml,bridge,genome]"
python -m pip install -e ".[dev,ml,bridge,genome]"
ok "Project installed"

# [4] R bridge
if command -v Rscript >/dev/null 2>&1; then
  log "Installing R bridge (sceasy, SeuratDisk)"
  Rscript datasets/01_reaptec_atlas/scripts/install_r_bridge.R \
    || warn "R bridge install had issues"
else
  warn "Rscript not found - check r-base in env"
fi

# [5] Verification
log "=== Verification ==="

if [[ "$USE_GPU" -eq 1 ]] && command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi | head -8
  python - <<'PY'
import torch
print(f"[torch] {torch.__version__} cuda={torch.cuda.is_available()} ndev={torch.cuda.device_count()}")
if torch.cuda.is_available():
    print(f"[torch] dev0 = {torch.cuda.get_device_name(0)}")
PY
fi

python -c "import aibio; print('[aibio]', aibio.__version__)" \
  || warn "aibio import failed"

if command -v pytest >/dev/null 2>&1; then
  log "pytest tests/python -q"
  pytest tests/python -q || warn "pytest had failures"
fi

if command -v Rscript >/dev/null 2>&1; then
  log "R smoke test"
  Rscript datasets/01_reaptec_atlas/scripts/smoke_r.R 2>/dev/null \
    || Rscript -e 'suppressPackageStartupMessages(library(Seurat)); cat("[Seurat]", as.character(packageVersion("Seurat")), "\n")' \
    || warn "R smoke test failed"
fi

python -c "from aibio.data import DATASET_REGISTRY; print('[catalog]', len(DATASET_REGISTRY), 'datasets')" \
  || warn "catalog import failed"

ok "Setup complete."
echo ""
echo "NEXT:"
echo "  1) source ~/.bashrc  or open a new shell"
echo "  2) conda activate $ENV_NAME"
echo "  3) bash datasets/01_reaptec_atlas/scripts/download_dryad.sh --tier p0"
echo "  4) See obsidian/30_Daily/2026-05-22.md for checklist"
