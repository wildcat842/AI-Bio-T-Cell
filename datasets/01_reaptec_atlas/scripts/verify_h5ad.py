#!/usr/bin/env python3
"""verify_h5ad.py - Python에서 변환된 .h5ad 파일 sanity check.

사용:
    python verify_h5ad.py                          # 기본: processed/h5ad/*.h5ad
    python verify_h5ad.py --dir custom/path/
    python verify_h5ad.py --backed                 # 큰 파일은 backed='r' 로

검증 항목:
- 파일 정상 열기
- shape (cells x genes)
- obs / var columns
- layers / obsm / varm 키
- 결측 / NaN 비율
- raw counts vs log-normalized 추정
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import anndata as ad
    import numpy as np
except ImportError as e:
    print(f"[ERR] anndata 또는 numpy가 필요합니다: {e}\n"
          f"      pip install anndata numpy 또는 conda env 활성화 후 재시도.",
          file=sys.stderr)
    sys.exit(2)


def inspect(path: Path, backed: bool = False) -> dict:
    print(f"\n=== {path.name} ({path.stat().st_size / 1e9:.2f} GB) ===")
    a = ad.read_h5ad(path, backed="r" if backed else None)
    info = {
        "shape": a.shape,
        "obs_columns": list(a.obs.columns)[:15],
        "var_columns": list(a.var.columns)[:15],
        "layers": list(a.layers.keys()),
        "obsm": list(a.obsm.keys()),
        "varm": list(a.varm.keys()),
        "uns_top": list(a.uns.keys())[:10],
    }
    print(f"  shape       : {info['shape']}  (cells x genes)")
    print(f"  obs columns : {info['obs_columns']}")
    print(f"  var columns : {info['var_columns']}")
    print(f"  layers      : {info['layers']}")
    print(f"  obsm        : {info['obsm']}")
    print(f"  varm        : {info['varm']}")
    print(f"  uns (top10) : {info['uns_top']}")

    # Sniff a small block to estimate counts vs log-normalized
    if backed:
        block = a.X[:200, :200]
    else:
        block = a.X[:200, :200]
    if hasattr(block, "toarray"):
        block = block.toarray()
    block = np.asarray(block, dtype=float)

    info["block_min"] = float(np.nanmin(block))
    info["block_max"] = float(np.nanmax(block))
    info["block_mean"] = float(np.nanmean(block))
    info["pct_integers"] = float(np.mean(block == np.floor(block)))
    info["pct_nonzero"] = float(np.mean(block > 0))

    looks_counts = info["pct_integers"] > 0.95 and info["block_max"] > 10
    print(f"  block stats : min={info['block_min']:.3f} max={info['block_max']:.3f} "
          f"mean={info['block_mean']:.3f}  int%={info['pct_integers']*100:.0f}  nz%={info['pct_nonzero']*100:.0f}")
    print(f"  inferred    : {'raw counts' if looks_counts else 'normalized (log/cpm/etc.)'}")
    info["looks_counts"] = looks_counts

    if backed:
        a.file.close()
    return info


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=None,
                    help="Directory of .h5ad files (default: processed/h5ad relative to this script)")
    ap.add_argument("--backed", action="store_true",
                    help="Open in backed mode (memory-safe for large files)")
    args = ap.parse_args()

    if args.dir:
        d = Path(args.dir)
    else:
        d = Path(__file__).resolve().parent.parent / "processed" / "h5ad"

    if not d.exists():
        print(f"[ERR] directory not found: {d}", file=sys.stderr)
        return 1
    files = sorted(d.glob("*.h5ad"))
    if not files:
        print(f"[WARN] no .h5ad files in {d}")
        return 1
    print(f"[INFO] inspecting {len(files)} .h5ad files in {d}")
    for f in files:
        try:
            inspect(f, backed=args.backed)
        except Exception as e:
            print(f"[ERR] {f.name}: {type(e).__name__}: {e}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
