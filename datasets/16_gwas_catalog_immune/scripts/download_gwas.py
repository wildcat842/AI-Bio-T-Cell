#!/usr/bin/env python3
"""GWAS Catalog REST API에서 18개 면역 매개 질환 association 다운로드.

사용법:
    python download_gwas.py --out associations.tsv
"""
import argparse
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("[ERROR] pip install requests --break-system-packages")
    sys.exit(1)

# 18 immune-mediated diseases - EFO IDs (확정은 NHGRI-EBI EFO 검색 필요)
EFO_TRAITS = {
    "RA": "EFO_0000685",
    "SLE": "EFO_0002690",
    "Crohn": "EFO_0000384",
    "UC": "EFO_0000729",
    "T1D": "EFO_0001359",
    "MS": "EFO_0003885",
    "Psoriasis": "EFO_0000676",
    "AS": "EFO_0003898",
    "Asthma": "EFO_0000270",
    "Celiac": "EFO_0001060",
    "AtopicDerm": "EFO_0000274",
    "Vitiligo": "EFO_0004208",
    "Graves": "EFO_0004237",
    "Hashimoto": "EFO_1001055",
    "Sarcoidosis": "EFO_0000690",
    "Behcet": "EFO_1001084",
    "Sjogren": "EFO_0000699",
    "JIA": "EFO_0002609",
}

GWAS_BASE = "https://www.ebi.ac.uk/gwas/rest/api"


def fetch_for_trait(efo_id):
    url = f"{GWAS_BASE}/efoTraits/{efo_id}/associations"
    r = requests.get(url, headers={"accept": "application/json"}, timeout=60)
    r.raise_for_status()
    return r.json()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="associations.tsv")
    args = ap.parse_args()
    out = Path(args.out)
    with out.open("w", encoding="utf-8") as fh:
        fh.write("trait_short\tefo_id\trsId\tpvalue\tchromosome\tposition\treported_gene\n")
        for short, efo in EFO_TRAITS.items():
            try:
                data = fetch_for_trait(efo)
            except Exception as e:
                print(f"[WARN] {short} ({efo}): {e}", file=sys.stderr)
                continue
            for a in data.get("_embedded", {}).get("associations", []):
                for snp in a.get("snps", []):
                    fh.write(
                        f"{short}\t{efo}\t{snp.get('rsId','')}\t"
                        f"{a.get('pvalue','')}\t"
                        f"{snp.get('chromosome','')}\t"
                        f"{snp.get('position','')}\t"
                        f"{','.join(g.get('geneName','') for g in snp.get('genes',[]))}\n"
                    )
            print(f"[INFO] {short} 완료")
    print(f"[INFO] {out} 저장")


if __name__ == "__main__":
    main()
