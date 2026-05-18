#!/bin/bash
# ReapTEC processed atlas - 공개 SI 다운로드 스크립트
# 사용법: bash download_processed.sh
#
# 주의: Science SI 직접 링크는 자동 차단될 수 있음. 수동 다운로드 후 본 폴더의 raw/에 위치시키는 것 권장.

set -e
TARGET_DIR="$(dirname "$0")/../processed"
mkdir -p "$TARGET_DIR"

echo "[INFO] Target dir: $TARGET_DIR"
echo "[INFO] Oguchi et al. 2024 Science SI는 자동 다운로드가 제한되는 경우가 있습니다."
echo "[INFO] 다음 URL에서 수동 다운로드 후 ./processed/에 위치시켜 주세요:"
echo "       https://www.science.org/doi/10.1126/science.add8394 (Supplementary Materials)"
echo "[INFO] 대안 1: RIKEN FANTOM/OmicsNote 미러"
echo "       https://fantom.gsc.riken.jp/"
echo "[INFO] 대안 2: ZENBU 게놈 브라우저 export"
echo "       https://fantom.gsc.riken.jp/zenbu/"

# 향후 RIKEN OmicsNote에 공개 다운로드 URL이 확정되면 wget 명령을 여기에 추가
# wget -P "$TARGET_DIR" https://example.org/reaptec_enhancers.bed.gz

echo "[INFO] 다운로드 완료 후 processed/ 내 파일을 확인하세요."
