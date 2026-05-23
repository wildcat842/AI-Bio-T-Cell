#!/bin/bash
# download_dryad.sh
# RIKEN ReapTEC atlas (Oguchi 2024) - Dryad doi:10.5061/dryad.pk0p2ngwx
#
# 사용:
#   bash download_dryad.sh                    # 기본: P0 tier (~22.2 GB)
#   bash download_dryad.sh --tier p0          # P0 (DataS2/S3/S4/S10 + README)
#   bash download_dryad.sh --tier p0+matrix   # P0 + DataS1/S5/S6 (~158 MB 추가)
#   bash download_dryad.sh --tier all         # 전체 161.66 GB (위험)
#   bash download_dryad.sh --file DataS3      # 특정 파일만
#   bash download_dryad.sh --resume           # 중단된 다운로드 이어받기
#
# 의존: aria2c (권장, 멀티커넥션) 또는 curl
# 위치: 본 스크립트는 datasets/01_reaptec_atlas/scripts/ 에서 실행
#       결과물은 ../raw/ 에 저장됨

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAW_DIR="$SCRIPT_DIR/../raw"
mkdir -p "$RAW_DIR"

TIER="p0"
SPECIFIC_FILE=""
RESUME_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier)    TIER="$2"; shift 2 ;;
    --file)    SPECIFIC_FILE="$2"; shift 2 ;;
    --resume)  RESUME_ONLY=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1"; exit 2 ;;
  esac
done

# ---- file inventory (Dryad version Apr 22, 2024) ----
# Format: NAME|FILE_STREAM_ID|SIZE_BYTES_HUMAN|TIER
FILES=(
  # README (always download)
  "dryad_README.md|3085547|13K|p0"

  # P0 - enhancer matrix, BED, ABC predictions, single-cell rds
  "DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx|3085521|48.46M|p0"
  "DataS4_Bed_files.zip|3085522|12.21M|p0"
  "DataS10_ABC_model_EnhancerPredictions_bulk_activated_CD4.txt|3085539|2.49M|p0"
  "DataS10_ABC_model_EnhancerPredictions_bulk_resting_CD4.txt|3085540|2.03M|p0"
  "DataS2_Single_cell_rds_files.zip|3085542|22.07G|p0"

  # P1 - bulk-like matrices, IsoSeq
  "DataS1_log2cpm_MASK_136subsets_90565.xlsx|3085541|77.63M|p1"
  "DataS5_TC_name_log2cpm_46108.xlsx|3085523|61.63M|p1"
  "DataS6_MASseq_CD4bulk_scisoseq_Treg_scisoseq_stringtie2_merge.gtf.gz|3085524|16.82M|p1"

  # P2 - Micro-C loops (small)
  "DataS8_Micro-C_HiCCUPS_loop_bulk_activated_CD4.bedpe|3085538|3.55M|p2small"
  "DataS8_Micro-C_HiCCUPS_loop_bulk_resting_CD4.bedpe|3085536|4.09M|p2small"
  "DataS8_Micro-C_mustache_loop_bulk_activated_CD4.loop|3085535|4.21M|p2small"
  "DataS8_Micro-C_mustache_loop_bulk_resting_CD4.loop|3085537|4.66M|p2small"

  # P2 - Region Capture Micro-C (medium)
  "DataS9_Region_Capture_Micro-C_LAG3_1kb_chicago_results.Rds|3085529|1.45G|p2"
  "DataS9_Region_Capture_Micro-C_Tfh_1kb_chicago_results.Rds|3085531|2.10G|p2"
  "DataS9_Region_Capture_Micro-C_Th17_1kb_chicago_results.Rds|3085530|1.91G|p2"
  "DataS9_Region_Capture_Micro-C_Treg_1kb_chicago_results.Rds|3085528|2.37G|p2"
  "DataS9_Region_Capture_Micro-C_bulk_activated_CD4_1kb_chicago_results.Rds|3085532|6.31G|p2"
  "DataS9_Region_Capture_Micro-C_bulk_resting_CD4_1kb_chicago_results.Rds|3085533|10.39G|p2"

  # P3 - Micro-C contact maps (LARGE, ~115 GB total)
  "DataS7_Micro-C_bulk_activated_CD4_contact_map.hic|3085534|16.67G|p3"
  "DataS7_Micro-C_bulk_activated_CD4_contact_map.mcool|3085526|44.44G|p3"
  "DataS7_Micro-C_bulk_resting_CD4_contact_map.hic|3085527|15.09G|p3"
  "DataS7_Micro-C_bulk_resting_CD4_contact_map.mcool|3085525|38.63G|p3"
)

BASE_URL="https://datadryad.org/downloads/file_stream"

# Determine which files to download
selected=()
for entry in "${FILES[@]}"; do
  IFS='|' read -r name id size tier <<< "$entry"
  if [[ -n "$SPECIFIC_FILE" ]]; then
    [[ "$name" == *"$SPECIFIC_FILE"* ]] && selected+=("$entry")
  else
    case "$TIER" in
      p0)         [[ "$tier" == "p0" ]] && selected+=("$entry") ;;
      p0+matrix) [[ "$tier" == "p0" || "$tier" == "p1" ]] && selected+=("$entry") ;;
      p2)         [[ "$tier" == "p0" || "$tier" == "p1" || "$tier" == "p2" || "$tier" == "p2small" ]] && selected+=("$entry") ;;
      all)        selected+=("$entry") ;;
    esac
  fi
done

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "No files matched (tier=$TIER, file=$SPECIFIC_FILE)"
  exit 1
fi

# Summary
echo "============================================================"
echo "Dryad ReapTEC download (tier=$TIER)"
echo "Target: $RAW_DIR"
echo "Files:  ${#selected[@]}"
for entry in "${selected[@]}"; do
  IFS='|' read -r name id size tier <<< "$entry"
  printf "  %-70s %8s\n" "$name" "$size"
done
echo "============================================================"

# Confirmation
read -r -p "Proceed? [y/N] " ans
[[ "${ans,,}" != "y" && "${ans,,}" != "yes" ]] && { echo "Aborted."; exit 0; }

# Choose downloader
if command -v aria2c >/dev/null 2>&1; then
  DOWNLOADER="aria2c"
  echo "[INFO] using aria2c (multi-connection, resume)"
elif command -v curl >/dev/null 2>&1; then
  DOWNLOADER="curl"
  echo "[INFO] using curl (single connection)"
else
  echo "ERR: neither aria2c nor curl found. install: sudo apt install aria2 -y"
  exit 1
fi

# Download
for entry in "${selected[@]}"; do
  IFS='|' read -r name id size tier <<< "$entry"
  url="$BASE_URL/$id"
  out="$RAW_DIR/$name"

  if [[ -f "$out" && "$RESUME_ONLY" -eq 0 ]]; then
    echo "[SKIP] $name (already exists, --resume를 쓰면 강제 검증)"
    continue
  fi

  echo ""
  echo "[GET ] $name  ($size)"
  echo "       $url"
  if [[ "$DOWNLOADER" == "aria2c" ]]; then
    aria2c --continue=true --max-connection-per-server=8 --split=8 \
           --min-split-size=20M --console-log-level=warn --summary-interval=10 \
           --dir "$RAW_DIR" --out "$name" "$url"
  else
    curl -L --fail --retry 5 --retry-delay 10 --continue-at - \
         -o "$out" "$url"
  fi
done

echo ""
echo "[DONE] Downloads completed at: $RAW_DIR"
echo "       Next: bash scripts/verify_checksums.sh"
ls -lh "$RAW_DIR" | tail -n +2
