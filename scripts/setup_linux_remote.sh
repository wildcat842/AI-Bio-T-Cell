#!/bin/bash
# setup_linux_remote.sh
# Linux remote 서버에서 AI-Bio-T-Cell 프로젝트를 GitHub로부터 가져오고
# Python(conda 또는 venv) + R(renv) 환경을 일괄 설치합니다.
#
# 두 가지 모드를 자동 감지합니다.
#   MODE A (fresh clone)    : 현재 디렉토리가 비어있거나 .git/이 없고 README.md 등 핵심 파일이 없음
#   MODE B (in-place link)  : 현재 디렉토리에 파일은 있는데 .git/이 없음 (예: scp로 받은 상태)
#                              -> git init + remote add + fetch + reset --hard origin/main
#                              -> 로컬 변경이 있다면 자동 백업 (./_pre_git_backup_TIMESTAMP)
#
# 사용:
#   chmod +x scripts/setup_linux_remote.sh
#   bash scripts/setup_linux_remote.sh                 # 자동 모드
#   bash scripts/setup_linux_remote.sh --clone         # MODE A 강제
#   bash scripts/setup_linux_remote.sh --link          # MODE B 강제
#   bash scripts/setup_linux_remote.sh --no-python     # Python 설치 건너뜀
#   bash scripts/setup_linux_remote.sh --no-r          # R 설치 건너뜀
#   bash scripts/setup_linux_remote.sh --branch dev    # 다른 브랜치
#
# 필요 도구: git, python>=3.10, (선택) conda 또는 venv, (선택) Rscript

set -euo pipefail

REPO_URL="https://github.com/wildcat842/AI-Bio-T-Cell.git"
REPO_NAME="AI-Bio-T-Cell"
BRANCH="main"
DO_PYTHON=1
DO_R=1
FORCE_MODE=""

# ---------- 인수 파싱 ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clone)       FORCE_MODE="clone"; shift ;;
    --link)        FORCE_MODE="link"; shift ;;
    --no-python)   DO_PYTHON=0; shift ;;
    --no-r)        DO_R=0; shift ;;
    --branch)      BRANCH="$2"; shift 2 ;;
    --repo)        REPO_URL="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
done

log()   { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
warn()  { printf '\033[33m[WARN] %s\033[0m\n' "$*"; }
err()   { printf '\033[31m[ERR ] %s\033[0m\n' "$*"; exit 1; }
ok()    { printf '\033[32m[ OK ] %s\033[0m\n' "$*"; }

# ---------- 0) 필수 도구 ----------
command -v git >/dev/null || err "git이 설치되어 있지 않습니다: sudo apt install git -y"
command -v python3 >/dev/null || err "python3가 필요합니다."

# ---------- 1) 모드 감지 ----------
detect_mode() {
  if [[ -n "$FORCE_MODE" ]]; then
    echo "$FORCE_MODE"; return
  fi
  if [[ -d ".git" ]]; then
    echo "existing"; return
  fi
  # 디렉토리가 비었으면 clone
  if [[ -z "$(ls -A 2>/dev/null)" ]]; then
    echo "clone"; return
  fi
  # 파일은 있지만 README.md/datasets 등이 보이면 link (현재 상태와 일치)
  if [[ -f "README.md" && -d "datasets" ]]; then
    echo "link"; return
  fi
  echo "clone"
}

MODE="$(detect_mode)"
log "mode = $MODE  (repo=$REPO_URL, branch=$BRANCH)"

# ---------- 2) Git 처리 ----------
case "$MODE" in
  clone)
    PARENT="$(pwd)"
    if [[ -d "$REPO_NAME" ]]; then
      err "이미 $PARENT/$REPO_NAME 존재. 다른 위치에서 실행하거나 --link 사용."
    fi
    log "git clone $REPO_URL"
    git clone --branch "$BRANCH" "$REPO_URL" "$REPO_NAME"
    cd "$REPO_NAME"
    ok "Cloned into $PARENT/$REPO_NAME"
    ;;

  link)
    # 현재 디렉토리에 파일이 있고 .git이 없음 -> 안전 백업 후 in-place 연결
    BACKUP="../${REPO_NAME}.predl.$(date +%Y%m%d-%H%M%S)"
    log "기존 파일을 ${BACKUP}에 백업합니다 (.git 없는 상태)"
    mkdir -p "$BACKUP"
    # rsync 우선, 없으면 cp
    if command -v rsync >/dev/null; then
      rsync -a --exclude='.git' ./ "$BACKUP/"
    else
      cp -a . "$BACKUP/"
    fi
    ok "백업 완료: $BACKUP"

    log "git init + remote 연결"
    git init -b "$BRANCH"
    git remote add origin "$REPO_URL"
    log "원격 fetch"
    git fetch origin "$BRANCH"
    warn "다음 단계 'git reset --hard origin/$BRANCH'는 로컬 파일을 원격 상태로 덮어씁니다."
    warn "(백업은 ${BACKUP}에 있습니다)"
    read -r -p "  계속하시겠습니까? [y/N] " ans
    case "${ans,,}" in
      y|yes)
        git reset --hard "origin/$BRANCH"
        git branch --set-upstream-to="origin/$BRANCH" "$BRANCH" 2>/dev/null || true
        ok "in-place link 완료. (백업: $BACKUP)"
        ;;
      *)
        warn "reset 취소. 원하는 시점에 직접 'git reset --hard origin/$BRANCH'를 실행하세요."
        ;;
    esac
    ;;

  existing)
    log "기존 .git 감지. git pull로 최신화."
    git fetch origin "$BRANCH"
    git pull --ff-only origin "$BRANCH" || warn "fast-forward 불가. 수동 머지 필요."
    ;;

  *)
    err "알 수 없는 mode: $MODE"
    ;;
esac

ok "git 단계 완료"
git --no-pager log --oneline -3 || true
echo

# ---------- 3) Python 환경 ----------
if [[ "$DO_PYTHON" -eq 1 ]]; then
  log "Python 환경 설치"
  # conda 우선
  if command -v conda >/dev/null 2>&1; then
    # 이미 활성 env가 있으면 거기에 설치
    if [[ -n "${CONDA_DEFAULT_ENV:-}" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
      log "활성 conda env=$CONDA_DEFAULT_ENV 에 pip 설치"
      python3 -m pip install --upgrade pip
      python3 -m pip install -e ".[dev,ml]" || warn "ml 추가 옵션 설치 실패. 'pip install -e \".[dev]\"'만 시도"
    else
      log "conda env 'aibio' 신규 생성 (environment.yml)"
      conda env update -n aibio -f environment.yml --prune
      ok "다음 명령으로 활성화하세요: conda activate aibio"
    fi
  else
    log "conda 없음. venv 사용"
    [[ -d .venv ]] || python3 -m venv .venv
    # shellcheck disable=SC1091
    source .venv/bin/activate
    python -m pip install --upgrade pip
    python -m pip install -e ".[dev,ml]" || warn "ml 옵션 실패. dev만 설치 시도"
    [[ "$?" -ne 0 ]] && python -m pip install -e ".[dev]"
    ok "venv 활성화: source .venv/bin/activate"
  fi
  python3 -c "import aibio; print('aibio version =', aibio.__version__)" \
    || warn "aibio import 실패 - PYTHONPATH 또는 editable install 확인 필요"
fi

# ---------- 4) R 환경 ----------
if [[ "$DO_R" -eq 1 ]]; then
  if command -v Rscript >/dev/null 2>&1; then
    log "R + renv 초기화"
    Rscript -e 'if (!requireNamespace("renv", quietly=TRUE)) install.packages("renv", repos="https://cloud.r-project.org")'
    Rscript -e 'renv::restore(prompt = FALSE)' || warn "renv::restore 실패. 직접 install.packages로 보강 필요."
  else
    warn "Rscript 미설치. R 사용하지 않으려면 --no-r"
  fi
fi

# ---------- 5) 디렉토리 무결성 점검 ----------
log "디렉토리 무결성 확인"
required=(README.md pyproject.toml datasets/data_catalog.csv obsidian/00_Index/Home.md
          src/python/aibio/__init__.py src/R/R/seurat_helpers.R)
miss=0
for f in "${required[@]}"; do
  [[ -e "$f" ]] && printf '  OK  %s\n' "$f" || { printf '  MISS %s\n' "$f"; miss=$((miss+1)); }
done
[[ "$miss" -eq 0 ]] && ok "필수 파일 ${#required[@]}개 모두 존재" || warn "$miss 개 누락"

# ---------- 6) 빈 데이터 디렉토리 .gitkeep 보강 ----------
log ".gitkeep 보강"
for d in data/raw data/interim data/processed data/external reports/figures reports/tables; do
  [[ -d "$d" && ! -f "$d/.gitkeep" ]] && touch "$d/.gitkeep" || true
done

# ---------- 7) 다음 단계 안내 ----------
cat <<'EOS'

================================================================
[NEXT STEPS]
1) 데이터셋 URL 라이브 검증:
     python scripts/verify_dataset_urls.py
2) 테스트:
     pytest tests/python -q
     Rscript -e 'testthat::test_dir("tests/R")'
3) GWAS / ENCODE 메타데이터 수집 (네트워크 허용 필요):
     python datasets/16_gwas_catalog_immune/scripts/download_gwas.py \
       --out datasets/16_gwas_catalog_immune/raw/associations.tsv
     python datasets/14_encode_chip/scripts/fetch_encode_metadata.py \
       --out datasets/14_encode_chip/metadata/encode_tf_tcell.tsv
4) Obsidian vault (선택, 데스크탑에서):
     open this folder in Obsidian: obsidian/
================================================================
EOS

ok "Setup 완료. Happy researching!"
