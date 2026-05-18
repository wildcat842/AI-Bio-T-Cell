#!/bin/bash
# push_to_github.sh - AI-Bio-T-Cell -> GitHub 초기 push (Unix)
#
# 사용법:
#   cd /path/to/AI-Bio-T-Cell
#   bash scripts/push_to_github.sh

set -e
REPO="https://github.com/wildcat842/AI-Bio-T-Cell.git"
BRANCH="main"

echo "=== AI-Bio-T-Cell -> GitHub initial push ==="
echo "Repo  : $REPO"
echo "Branch: $BRANCH"
echo

# [0/6] 깨진 .git 자동 정리
if [ -d .git ]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[0/6] 기존 git repo 사용"
    SKIP_INIT=1
  else
    echo "[0/6] 손상된 .git 제거"
    rm -rf .git
    SKIP_INIT=0
  fi
else
  SKIP_INIT=0
fi

if [ "$SKIP_INIT" -ne 1 ]; then
  echo "[1/6] git init -b $BRANCH"
  git init -b "$BRANCH"
  git config user.email "sojung.kim.nca@gmail.com"
  git config user.name "Sojung Kim"
fi
echo

echo "[2/6] git add -A"
git add -A
echo "  Staged: $(git diff --cached --numstat | wc -l) files"
echo

if ! git rev-parse HEAD >/dev/null 2>&1; then
  echo "[3/6] 초기 커밋"
  git commit -m "Initial commit - AI-Bio-T-Cell project scaffold

- Project structure for AI Virtual Cells x RIKEN ReapTEC T-Cell research
- 19 dataset catalog (datasets/) with READMEs and download scripts
- Python (aibio package) and R (Seurat/Signac helpers) source code
- Obsidian vault for shared research notes (4 topics, concepts, ADR)
- GitHub Actions CI for Python (ruff+pytest) and R (testthat)
- Evaluation report, data catalog, summary slides under reports/deliverables/"
else
  echo "[3/6] 변경사항 커밋 (있을 때만)"
  git diff --cached --quiet || git commit -m "Update project files"
fi
echo

echo "[4/6] remote origin 설정"
if git remote get-url origin >/dev/null 2>&1; then
  if [ "$(git remote get-url origin)" != "$REPO" ]; then
    git remote set-url origin "$REPO"
    echo "  origin 갱신: $REPO"
  else
    echo "  origin 이미 설정됨"
  fi
else
  git remote add origin "$REPO"
  echo "  origin 추가"
fi
echo

echo "[5/6] LFS init (선택)"
if command -v git-lfs >/dev/null 2>&1; then
  git lfs install
  git lfs track "*.pdf" "*.xlsx" "*.docx" "*.pptx" "*.png" "*.h5" "*.h5ad" "*.rds" 2>/dev/null || true
  echo "  LFS tracking 설정됨"
else
  echo "  WARN: git-lfs 미설치"
fi
echo

echo "[6/6] git push -u origin $BRANCH"
git push -u origin "$BRANCH"
echo
echo "[OK] Done. Repo: $REPO"
