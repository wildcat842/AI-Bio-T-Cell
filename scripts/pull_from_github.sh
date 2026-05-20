#!/bin/bash
# pull_from_github.sh
# 일상 작업용: GitHub에서 변경사항을 받아오고 (필요 시) 의존성 자동 재설치.
# - pyproject.toml 또는 environment.yml가 바뀌었으면 conda/pip 재설치
# - renv.lock이 바뀌었으면 renv::restore 재실행
#
# 사용: bash scripts/pull_from_github.sh [--branch main]

set -euo pipefail
BRANCH="main"
if [[ "${1:-}" == "--branch" ]]; then
  if [[ -z "${2:-}" ]]; then
    echo "Usage: $0 [--branch <branch>]"
    exit 1
  fi
  BRANCH="$2"
fi

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

# 0) 안전 점검
git diff --quiet || { echo "워킹트리에 미커밋 변경이 있습니다. 먼저 commit/stash 후 다시 시도하세요."; exit 1; }

# 1) 변경 감지를 위해 pull 전 hash 저장
hash_before_py="$(git rev-parse HEAD:pyproject.toml 2>/dev/null || echo none)"
hash_before_env="$(git rev-parse HEAD:environment.yml 2>/dev/null || echo none)"
hash_before_renv="$(git rev-parse HEAD:renv.lock 2>/dev/null || echo none)"
hash_before_req="$(git rev-parse HEAD:requirements.txt 2>/dev/null || echo none)"

# 2) pull
log "git fetch + pull --ff-only origin $BRANCH"
git fetch origin "$BRANCH"
git pull --ff-only origin "$BRANCH"

# 3) 변경 감지
hash_after_py="$(git rev-parse HEAD:pyproject.toml 2>/dev/null || echo none)"
hash_after_env="$(git rev-parse HEAD:environment.yml 2>/dev/null || echo none)"
hash_after_renv="$(git rev-parse HEAD:renv.lock 2>/dev/null || echo none)"
hash_after_req="$(git rev-parse HEAD:requirements.txt 2>/dev/null || echo none)"

py_changed=0; r_changed=0
[[ "$hash_before_py"   != "$hash_after_py"   ]] && py_changed=1
[[ "$hash_before_env"  != "$hash_after_env"  ]] && py_changed=1
[[ "$hash_before_req"  != "$hash_after_req"  ]] && py_changed=1
[[ "$hash_before_renv" != "$hash_after_renv" ]] && r_changed=1

# 4) 자동 재설치
if [[ "$py_changed" -eq 1 ]]; then
  log "Python 의존성이 변경되었습니다. 재설치 중..."
  if command -v conda >/dev/null && [[ -n "${CONDA_DEFAULT_ENV:-}" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
    python -m pip install -e ".[dev,ml]" || python -m pip install -e ".[dev]"
  elif [[ -d .venv ]]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
    python -m pip install -e ".[dev,ml]" || python -m pip install -e ".[dev]"
  else
    echo "  WARN: conda env / .venv 미감지. 수동 설치: pip install -e \".[dev,ml]\""
  fi
fi

if [[ "$r_changed" -eq 1 ]]; then
  log "renv.lock이 변경되었습니다. renv::restore 실행 중..."
  if command -v Rscript >/dev/null; then
    Rscript -e 'renv::restore(prompt = FALSE)' || echo "  WARN: renv::restore 실패"
  fi
fi

log "pull 완료. 최근 커밋:"
git --no-pager log --oneline -5
