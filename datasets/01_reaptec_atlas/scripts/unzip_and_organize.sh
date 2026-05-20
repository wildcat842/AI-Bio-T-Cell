#!/bin/bash
# unzip_and_organize.sh - raw/ → processed/ 구조 정리
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAW="$SCRIPT_DIR/../raw"
PROC="$SCRIPT_DIR/../processed"
mkdir -p "$PROC/seurat_objects" "$PROC/bed" "$PROC/abc"

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

# 1) DataS2 (Seurat .rds) unzip
if [[ -f "$RAW/DataS2_Single_cell_rds_files.zip" ]]; then
  log "Unzipping DataS2 (22 GB)..."
  unzip -o -d "$PROC/seurat_objects" "$RAW/DataS2_Single_cell_rds_files.zip"
  log "DataS2 unzipped: $(find "$PROC/seurat_objects" -name '*.rds' -o -name '*.Rds' | wc -l) .rds files"
fi

# 2) DataS4 (BED files) unzip
if [[ -f "$RAW/DataS4_Bed_files.zip" ]]; then
  log "Unzipping DataS4 BED files..."
  unzip -o -d "$PROC/bed" "$RAW/DataS4_Bed_files.zip"
  log "BED files: $(find "$PROC/bed" -name '*.bed' -o -name '*.bedpe' | wc -l) files"
fi

# 3) ABC predictions
for f in "$RAW"/DataS10_ABC_model_*.txt; do
  [[ -f "$f" ]] && cp -v "$f" "$PROC/abc/"
done

# 4) Optional: xlsx → parquet (Python required)
if command -v python3 >/dev/null 2>&1 && [[ -f "$RAW/DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx" ]]; then
  log "Converting DataS3 xlsx → parquet (for faster Python access)"
  python3 - <<PY
import pandas as pd
from pathlib import Path
src = Path("$RAW/DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx")
dst = Path("$PROC/enhancer_expression.parquet")
# 첫 sheet 기준 변환 (필요 시 sheet_name 조정)
df = pd.read_excel(src, sheet_name=0)
df.to_parquet(dst, engine="pyarrow", compression="snappy")
print(f"OK: {dst}  shape={df.shape}  size_mb={dst.stat().st_size/1e6:.1f}")
PY
fi

log "DONE. processed/ contents:"
ls -lh "$PROC"
