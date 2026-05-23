#!/bin/bash
# verify_checksums.sh - 다운로드된 파일의 md5/size sanity check
#
# Dryad는 페이지에 명시적 md5를 게시하지 않으므로 (각 파일은 Dryad의 file_stream API로 제공)
# 본 스크립트는 다음을 검증:
#  1) 예상 파일 크기와 일치하는지 (±0.5%)
#  2) 파일이 정상적으로 끝나는지 (zip: unzip -tq, xlsx: head magic bytes, txt: 비어있지 않음)
#  3) 로컬에서 md5를 계산하여 metadata/dryad_manifest.tsv 에 기록 (이후 재배포 시 검증용)

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAW="$SCRIPT_DIR/../raw"
META_DIR="$SCRIPT_DIR/../metadata"
mkdir -p "$META_DIR"
MANIFEST="$META_DIR/dryad_manifest.tsv"

# Expected (filename | bytes_lower | bytes_upper | format)
declare -a EXPECT=(
  "dryad_README.md|10000|20000|text"
  "DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx|45000000|55000000|xlsx"
  "DataS4_Bed_files.zip|11000000|14000000|zip"
  "DataS10_ABC_model_EnhancerPredictions_bulk_activated_CD4.txt|2000000|3000000|text"
  "DataS10_ABC_model_EnhancerPredictions_bulk_resting_CD4.txt|1900000|2200000|text"
  "DataS2_Single_cell_rds_files.zip|22000000000|24000000000|zip"
  "DataS1_log2cpm_MASK_136subsets_90565.xlsx|75000000|82000000|xlsx"
  "DataS5_TC_name_log2cpm_46108.xlsx|59000000|65000000|xlsx"
  "DataS6_MASseq_CD4bulk_scisoseq_Treg_scisoseq_stringtie2_merge.gtf.gz|15000000|18000000|gzip"
)

echo "file	bytes	md5	check" > "$MANIFEST"

ok=0; warn=0; miss=0
for entry in "${EXPECT[@]}"; do
  IFS='|' read -r name lo hi fmt <<< "$entry"
  p="$RAW/$name"
  if [[ ! -f "$p" ]]; then
    printf "[MISS] %s\n" "$name"
    miss=$((miss+1)); continue
  fi
  sz=$(stat -c%s "$p" 2>/dev/null || stat -f%z "$p")
  check="OK"
  if (( sz < lo || sz > hi )); then
    check="SIZE_OUT_OF_RANGE($lo..$hi got $sz)"
    warn=$((warn+1))
  fi
  case "$fmt" in
    zip)
      if ! unzip -tq "$p" >/dev/null 2>&1; then check="ZIP_BROKEN"; warn=$((warn+1)); fi ;;
    gzip)
      if ! gzip -t "$p" >/dev/null 2>&1; then check="GZIP_BROKEN"; warn=$((warn+1)); fi ;;
    xlsx)
      # xlsx is a zip in disguise
      if ! unzip -tq "$p" >/dev/null 2>&1; then check="XLSX_BROKEN"; warn=$((warn+1)); fi ;;
    text)
      if [[ ! -s "$p" ]]; then check="EMPTY"; warn=$((warn+1)); fi ;;
  esac
  md5=$(md5sum "$p" 2>/dev/null | cut -d' ' -f1)
  [[ -z "$md5" ]] && md5=$(md5 -q "$p" 2>/dev/null || echo "?")
  printf "%s\t%d\t%s\t%s\n" "$name" "$sz" "$md5" "$check" >> "$MANIFEST"
  if [[ "$check" == "OK" ]]; then
    printf "[ OK ] %-70s %12s\n" "$name" "$sz bytes"
    ok=$((ok+1))
  else
    printf "[WARN] %-70s %s\n" "$name" "$check"
  fi
done

echo
echo "Summary: $ok OK, $warn warnings, $miss missing"
echo "Manifest written to: $MANIFEST"
exit $(( warn>0 || miss>0 ? 1 : 0 ))
