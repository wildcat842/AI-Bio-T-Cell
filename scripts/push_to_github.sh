#!/bin/bash
# push_to_github.sh
# 사용법:
#   cd /path/to/AI-Bio-T-Cell
#   bash scripts/push_to_github.sh
#
# 사전 조건:
#   - git 설치, GitHub 인증 (https 토큰 / SSH 키 / gh CLI)

set -e
REPO="https://github.com/wildcat842/AI-Bio-T-Cell.git"

echo "[1/5] git status (short)"
git status --short | head -10
echo

echo "[2/5] git log"
git log --oneline -5
echo

echo "[3/5] remote 설정"
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REPO"
  echo "  origin added: $REPO"
else
  cur=$(git remote get-url origin)
  if [ "$cur" != "$REPO" ]; then
    git remote set-url origin "$REPO"
    echo "  origin updated: $REPO"
  else
    echo "  origin already set: $cur"
  fi
fi
echo

echo "[4/5] LFS init (선택)"
if command -v git-lfs >/dev/null 2>&1; then
  git lfs install
  git lfs track "*.pdf" "*.xlsx" "*.docx" "*.pptx" "*.png" "*.h5" "*.h5ad" "*.rds" 2>/dev/null || true
  echo "  LFS tracking 설정됨"
else
  echo "  WARN: git-lfs 미설치 (https://git-lfs.com)"
fi
echo

echo "[5/5] push"
git push -u origin main
echo
echo "[OK] Pushed to $REPO"
