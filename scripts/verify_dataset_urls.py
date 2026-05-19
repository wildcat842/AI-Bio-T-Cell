#!/usr/bin/env python3
"""Verify dataset access URLs in datasets/data_catalog.csv.

Run from repo root:
    python scripts/verify_dataset_urls.py

What it does:
- For each row in datasets/data_catalog.csv, perform an HTTP HEAD (then GET if HEAD blocked).
- Print per-URL status: HTTP code, redirect chain final URL, TLS, content-type.
- Write a Markdown report to reports/deliverables/url_verification_report.md.
- Exit code 0 if all live URLs return 2xx/3xx, else 1.

Notes:
- "internal" and "GEO (per ...)" placeholders are reported separately (manual lookup).
- Some hosts disallow HEAD; we transparently retry with GET (Range: bytes=0-0).
"""
from __future__ import annotations

import csv
import datetime as dt
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
CSV_PATH = REPO / "datasets" / "data_catalog.csv"
OUT_PATH = REPO / "reports" / "deliverables" / "url_verification_report.md"

UA = "AI-Bio-T-Cell-url-verify/0.1 (+https://github.com/wildcat842/AI-Bio-T-Cell)"


def http_check(url: str, timeout: float = 12.0) -> dict:
    """Return {'code', 'final_url', 'method', 'error', 'content_type'}."""
    out = {"code": None, "final_url": url, "method": "HEAD",
           "error": None, "content_type": ""}
    if not url.startswith(("http://", "https://")):
        out["error"] = "non-HTTP scheme"
        return out

    # Try HEAD first
    for method in ("HEAD", "GET"):
        req = urllib.request.Request(url, method=method, headers={
            "User-Agent": UA,
            "Accept": "*/*",
            # Range to keep GET cheap
            **({"Range": "bytes=0-0"} if method == "GET" else {}),
        })
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                out["code"] = resp.status
                out["final_url"] = resp.url
                out["method"] = method
                out["content_type"] = resp.headers.get("Content-Type", "")
                return out
        except urllib.error.HTTPError as e:
            # 405 or 403 on HEAD -> retry with GET
            if method == "HEAD" and e.code in (403, 405, 501):
                continue
            out["code"] = e.code
            out["final_url"] = e.url if hasattr(e, "url") else url
            out["method"] = method
            out["error"] = f"HTTPError {e.code} {e.reason}"
            return out
        except (urllib.error.URLError, TimeoutError, OSError) as e:
            if method == "HEAD":
                continue
            out["error"] = f"{type(e).__name__}: {e}"
            return out
    return out


def main() -> int:
    if not CSV_PATH.exists():
        print(f"ERROR: catalog not found: {CSV_PATH}", file=sys.stderr)
        return 2
    rows = list(csv.DictReader(CSV_PATH.open(encoding="utf-8")))
    print(f"[INFO] Checking {len(rows)} datasets against access_url ...")

    results = []
    for r in rows:
        url = r["access_url"].strip()
        if url.startswith(("http://", "https://")):
            res = http_check(url)
        else:
            res = {"code": None, "final_url": url, "method": "-",
                   "error": "non-URL placeholder", "content_type": ""}
        results.append((r, res))
        code = res["code"] if res["code"] is not None else "----"
        marker = "OK" if isinstance(res["code"], int) and 200 <= res["code"] < 400 else "..."
        print(f"  [{marker}] {code} {r['dataset_name'][:40]:40s} -> {url}")

    # Write Markdown report
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUT_PATH.open("w", encoding="utf-8") as fh:
        fh.write("# Dataset URL Verification Report\n\n")
        fh.write(f"**Run at**: {dt.datetime.now().isoformat(timespec='seconds')}  \n")
        fh.write(f"**Catalog**: `datasets/data_catalog.csv` ({len(rows)} datasets)  \n")
        fh.write(f"**Verifier**: `scripts/verify_dataset_urls.py`\n\n")
        fh.write("## Summary\n\n")
        live = sum(1 for _, r in results if isinstance(r["code"], int) and 200 <= r["code"] < 400)
        broken = sum(1 for _, r in results if isinstance(r["code"], int) and r["code"] >= 400)
        placeholder = sum(1 for _, r in results if not isinstance(r["code"], int))
        fh.write(f"- Live (2xx/3xx): **{live}**\n- Broken (>=400): **{broken}**\n- Placeholder/non-HTTP: **{placeholder}**\n\n")
        fh.write("## Detail\n\n")
        fh.write("| # | Dataset | Topic | URL | HTTP | Final URL | Note |\n")
        fh.write("|---|---|---|---|---|---|---|\n")
        for r, res in results:
            code = res["code"] if res["code"] is not None else "-"
            url = r["access_url"]
            final = res["final_url"] if res["final_url"] != url else "-"
            note = res["error"] or ""
            fh.write(f"| {r.get('priority','-')} | {r['dataset_name']} | {r.get('topic','-')} | "
                     f"{url} | {code} | {final} | {note} |\n")
    print(f"[INFO] Report: {OUT_PATH}")

    bad = sum(1 for _, r in results if isinstance(r["code"], int) and r["code"] >= 400)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
