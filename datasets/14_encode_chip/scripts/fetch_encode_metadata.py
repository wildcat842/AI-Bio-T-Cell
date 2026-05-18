#!/usr/bin/env python3
"""ENCODE Portal REST API에서 T-cell 관련 TF ChIP-seq 메타데이터를 수집.

사용법:
    python fetch_encode_metadata.py --out metadata.tsv

주의:
    실제 다운로드는 별도 wget 스크립트로 수행. 본 스크립트는 manifest만 생성.
"""
import argparse
import json
import sys
from pathlib import Path

try:
    import requests  # noqa
except ImportError:
    print("[ERROR] requests 패키지가 필요합니다: pip install requests --break-system-packages")
    sys.exit(1)


ENCODE_SEARCH = "https://www.encodeproject.org/search/"
HEADERS = {"accept": "application/json"}


def fetch(biosample_terms):
    params = {
        "type": "Experiment",
        "assay_title": "TF ChIP-seq",
        "status": "released",
        "biosample_ontology.term_name": biosample_terms,
        "format": "json",
        "limit": "all",
    }
    r = requests.get(ENCODE_SEARCH, params=params, headers=HEADERS, timeout=60)
    r.raise_for_status()
    return r.json()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="metadata.tsv")
    args = ap.parse_args()
    terms = [
        "CD4-positive, alpha-beta T cell",
        "CD8-positive, alpha-beta T cell",
        "naive thymus-derived CD4-positive, alpha-beta T cell",
        "Jurkat clone E61",
        "thymus",
    ]
    data = fetch(terms)
    out = Path(args.out)
    with out.open("w", encoding="utf-8") as fh:
        fh.write("accession\tassay_title\ttarget\tbiosample_term\tdate_released\n")
        for exp in data.get("@graph", []):
            fh.write(
                f"{exp.get('accession','')}\t"
                f"{exp.get('assay_title','')}\t"
                f"{(exp.get('target',{}) or {}).get('label','')}\t"
                f"{(exp.get('biosample_ontology',{}) or {}).get('term_name','')}\t"
                f"{exp.get('date_released','')}\n"
            )
    print(f"[INFO] {out} 작성 완료 ({len(data.get('@graph', []))} experiments)")


if __name__ == "__main__":
    main()
