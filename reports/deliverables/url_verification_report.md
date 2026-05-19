# Dataset URL Verification Report

**Generated**: 2026-05-18
**Catalog**: `datasets/data_catalog.csv` (19 datasets)
**Auto-test script**: `scripts/verify_dataset_urls.py` (run locally for live HTTP check)

## Methodology

This report combines two checks.

1. **Sandbox live-HTTP** (May 18, 2026): `scripts/verify_dataset_urls.py` was run from the build sandbox. The network proxy is restricted to Anthropic domains only (`*.anthropic.com`, `claude.com`), so every external URL returned a CONNECT 403 / "network policy" error. **Live status is therefore inconclusive from the sandbox.**
2. **Knowledge-based review** of URL structure, host stability, recommended deep-links, license, and access tier. This forms the substantive part of the report.

Users should run `python scripts/verify_dataset_urls.py` from their own (unrestricted) network to obtain live HTTP codes. The script writes its raw output to the appendix at the bottom of this file.

## Summary table

| # | Dataset | URL in catalog | Endpoint type | Expected status | Access tier | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| 01 | RIKEN ReapTEC T-Cell Atlas | https://www.science.org/doi/10.1126/science.add8394 | Publisher DOI landing | 200 (full text behind login) | Mixed | Add deep-link to Supplementary Materials when available; raw FASTQ on DDBJ/EGA (MTA) |
| 02 | Project DEG Time Series | `internal` | Internal | n/a | Internal | Not a URL; documented under `datasets/02_project_DEG_timeseries/README.md` |
| 03 | Daniel et al. 2022 Exhaustion | https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE201088 | GEO accession | 200 | Open | Accession `GSE201088` should be confirmed against the paper's data availability statement |
| 04 | 10x Genomics PBMC Multiome | https://www.10xgenomics.com/datasets | Catalog landing | 200 (anti-bot may force 403 for HEAD) | Open (with login) | Recommend deep link to specific PBMC 10K Multiome dataset page once selected |
| 05 | Tabula Sapiens T-cells subset | https://tabula-sapiens.sf.czbiohub.org/ | Portal landing | 200 | Open (CC-BY-4.0) | Working alternative: https://cellxgene.cziscience.com/ search "Tabula Sapiens" |
| 06 | VDJdb | https://vdjdb.cdr3.net/ | Portal landing | 200 | Open (CC-BY-4.0) | Static download: https://github.com/antigenomics/vdjdb-db/releases (release tarballs) |
| 07 | IEDB | https://www.iedb.org/ | Portal landing | 200 | Open with terms | Bulk export: https://www.iedb.org/database_export_v3.php |
| 08 | 10x Genomics Vdj-T | https://www.10xgenomics.com/resources/datasets | Catalog landing | 200 (redirects to /datasets) | Open (with login) | Same caveats as #04 |
| 09 | BertTCR Training Data | `GEO (per PMC11342255)` | Placeholder | n/a | Open | Confirm accession from PMC11342255 SI; replace placeholder with `https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSExxxxxx` |
| 10 | HEST-1k | https://huggingface.co/datasets/MahmoodLab/hest | HF Dataset | 200 | CC-BY-NC-SA-4.0 | Download via `datasets` library or `huggingface-cli download MahmoodLab/hest` |
| 11 | TCGA TIL Atlas | https://portal.gdc.cancer.gov/ | NIH GDC portal | 200 | Mixed | TIL fractions: https://gdc.cancer.gov/about-data/publications/panimmune (Thorsson 2018) |
| 12 | Barkley et al. 2022 Pan-cancer T | `GEO (per paper)` | Placeholder | n/a | Open | Confirm accession from Nat Genet 2022 paper SI (likely series prefix `GSE154763`-class) |
| 13 | CODEX HuBMAP | https://datadryad.org/ | Dryad landing | 200 | CC0 | More specific: https://portal.hubmapconsortium.org/ search lymphoid CODEX |
| 14 | ENCODE TF ChIP-seq | https://www.encodeproject.org/ | Portal landing | 200 | CC0 | Recommended deep-link: https://www.encodeproject.org/search/?type=Experiment&assay_title=TF+ChIP-seq&biosample_ontology.term_name=CD4-positive%2C+alpha-beta+T+cell |
| 15 | GTEx v8 eQTL | https://gtexportal.org/ | Portal landing | 200 (redirects to /home/) | Mixed | Deep link: https://gtexportal.org/home/datasets - V8 Single-Tissue eQTL files |
| 16 | GWAS Catalog Immune Diseases | https://www.ebi.ac.uk/gwas/ | EBI portal | 200 | Open | REST API base: https://www.ebi.ac.uk/gwas/rest/api - used by `download_gwas.py` |
| 17 | FANTOM5 CAGE | https://fantom.gsc.riken.jp/5/ | RIKEN FANTOM | 200 | CC-BY-4.0 | Datasets index: https://fantom.gsc.riken.jp/5/datafiles/latest/ |
| 18 | Roadmap Epigenomics | https://egg2.wustl.edu/roadmap/ | WashU mirror | 200 | Open | Portal: https://egg2.wustl.edu/roadmap/web_portal/index.html |
| 19 | Open Targets Genetics | https://genetics.opentargets.org/ | Portal | 200 (sunset merge ongoing) | CC0 | OT Genetics is being merged into Open Targets Platform - https://platform.opentargets.org/. Verify before relying on the standalone Genetics API |

## Findings

### Strengths
- 17 of 19 entries use stable, well-known scientific data portal URLs that have been reliable for years (Science DOI, GEO, EBI, ENCODE, GTEx, FANTOM, Roadmap, HuggingFace, Dryad, HuBMAP, 10x Genomics, CZ Biohub, NIH GDC).
- All HTTPS, no HTTP fallbacks.
- All 19 datasets have a corresponding directory README under `datasets/NN_*/` for fuller metadata.

### Issues to fix (recommended catalog edits)

1. **Row 09 (BertTCR)** and **Row 12 (Barkley)** carry placeholder strings instead of real GEO URLs. Confirm the accessions from the source papers' SI and replace.
2. **Row 19 (Open Targets Genetics)**: the standalone Genetics portal is being **sunset and merged into Open Targets Platform** (timeline announced in 2024-2025). Re-verify availability before relying on it; consider switching to https://platform.opentargets.org/ once the merge completes.
3. **Rows 04 and 08 (10x Genomics)**: both URLs point to the same catalog listing (`/resources/datasets` redirects to `/datasets`). Use specific dataset deep-links once you select the exact sample.
4. **Rows 04, 11, 13, 14, 15, 16, 17, 18, 19**: catalog stores the **landing page** rather than the actual download manifest. For automation, prefer the REST/API/release URLs listed under "Notes" above.
5. **Row 01 (ReapTEC)**: add a second `access_url_supplementary` column or update with the direct Science SI URL once retrieved, since the bare DOI page often hides the SI behind a paywall click.

### Sandbox HTTP results (informational)

All 17 HTTP-form URLs returned **proxy 403 (network policy)** in the build sandbox - this is a sandbox restriction, not a problem with the URLs themselves. See `scripts/verify_dataset_urls.py` and re-run locally for true live status. Two placeholders ("internal", "GEO (per ...)") are not URLs and are reported as such.

## Recommended next actions

1. **User-side live test** (5 min):
   ```bash
   cd /path/to/AI-Bio-T-Cell
   python scripts/verify_dataset_urls.py
   ```
   The script appends real HTTP codes and exits non-zero if any URL returns >=400.

2. **Catalog edits** (15 min):
   - Resolve GEO accessions for rows 09 and 12 from paper SI.
   - Update row 19 with the OT Platform alternative.
   - Consider adding a `download_endpoint` column for automation deep-links separate from human-friendly landing pages.

3. **Periodic re-check**: add a scheduled GitHub Actions job (weekly) that runs `verify_dataset_urls.py` and opens an issue on any HTTP >=400. The template is in `.github/workflows/python-ci.yml` and can be extended.

## Appendix - Auto-generated sandbox results

The first run of `scripts/verify_dataset_urls.py` from the sandbox produced the following raw output. Replace with your local run results to refresh.

```
[INFO] Checking 19 datasets against access_url ...
  [...] ---- RIKEN ReapTEC T-Cell Atlas               -> https://www.science.org/doi/10.1126/science.add8394
  [...] ---- Project DEG Time Series                  -> internal
  [...] ---- Daniel et al. 2022 Divergent Exhaustion  -> https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE201088
  [...] ---- 10x Genomics PBMC Multiome               -> https://www.10xgenomics.com/datasets
  [...] ---- Tabula Sapiens T-cells subset            -> https://tabula-sapiens.sf.czbiohub.org/
  [...] ---- VDJdb                                    -> https://vdjdb.cdr3.net/
  [...] ---- IEDB                                     -> https://www.iedb.org/
  [...] ---- 10x Genomics Vdj-T                       -> https://www.10xgenomics.com/resources/datasets
  [...] ---- BertTCR Training Data                    -> GEO (per PMC11342255)
  [...] ---- HEST-1k                                  -> https://huggingface.co/datasets/MahmoodLab/hest
  [...] ---- TCGA TIL Atlas                           -> https://portal.gdc.cancer.gov/
  [...] ---- Barkley et al. 2022 Pan-cancer T         -> GEO (per paper)
  [...] ---- CODEX HuBMAP                             -> https://datadryad.org/
  [...] ---- ENCODE TF ChIP-seq                       -> https://www.encodeproject.org/
  [...] ---- GTEx v8 eQTL                             -> https://gtexportal.org/
  [...] ---- GWAS Catalog Immune Diseases             -> https://www.ebi.ac.uk/gwas/
  [...] ---- FANTOM5 CAGE                             -> https://fantom.gsc.riken.jp/5/
  [...] ---- Roadmap Epigenomics                      -> https://egg2.wustl.edu/roadmap/
  [...] ---- Open Targets Genetics                    -> https://genetics.opentargets.org/
```

All `----` codes are sandbox CONNECT 403 from the network proxy. The URL strings themselves are syntactically valid (HTTPS, well-formed domain, stable hosts).
