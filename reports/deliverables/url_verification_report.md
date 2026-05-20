# Dataset URL Verification Report

**Run at**: 2026-05-20T21:12:09  
**Catalog**: `datasets/data_catalog.csv` (19 datasets)  
**Verifier**: `scripts/verify_dataset_urls.py`

## Summary

- Live (2xx/3xx): **16**
- Broken (>=400): **0**
- Placeholder/non-HTTP: **3**

## Detail

| # | Dataset | Topic | URL | HTTP | Final URL | Note |
|---|---|---|---|---|---|---|
| P0 | RIKEN ReapTEC T-Cell Atlas | T1+T4 | https://www.science.org/doi/10.1126/science.add8394 | 200 | - |  |
| P0 | Project DEG Time Series | T1+T4 | internal | - | - | non-URL placeholder |
| P1 | Daniel et al. 2022 Divergent Exhaustion | T1 | https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE201088 | 200 | - |  |
| P1 | 10x Genomics PBMC Multiome | T1 | https://www.10xgenomics.com/datasets | 200 | - |  |
| P2 | Tabula Sapiens T-cells subset | T1 | https://tabula-sapiens.sf.czbiohub.org/ | 200 | - |  |
| P3 | VDJdb | T2 | https://vdjdb.cdr3.net/ | 200 | https://vdjdb.com/ |  |
| P3 | IEDB | T2 | https://www.iedb.org/ | 200 | - |  |
| P3 | 10x Genomics Vdj-T | T2 | https://www.10xgenomics.com/resources/datasets | 200 | https://www.10xgenomics.com/datasets |  |
| P3 | BertTCR Training Data | T2 | GEO (per PMC11342255) | - | - | non-URL placeholder |
| P2 | HEST-1k | T3 | https://huggingface.co/datasets/MahmoodLab/hest | 200 | - |  |
| P2 | TCGA TIL Atlas | T3 | https://portal.gdc.cancer.gov/ | 200 | - |  |
| P2 | Barkley et al. 2022 Pan-cancer T | T3 | GEO (per paper) | - | - | non-URL placeholder |
| P2 | CODEX HuBMAP | T3 | https://datadryad.org/ | 200 | - |  |
| P0 | ENCODE TF ChIP-seq | T4 | https://www.encodeproject.org/ | 200 | - |  |
| P0 | GTEx v8 eQTL | T4 | https://gtexportal.org/ | 200 | https://gtexportal.org/home/index.html |  |
| P0 | GWAS Catalog Immune Diseases | T4 | https://www.ebi.ac.uk/gwas/ | 200 | - |  |
| P1 | FANTOM5 CAGE | T4 | https://fantom.gsc.riken.jp/5/ | 200 | - |  |
| P1 | Roadmap Epigenomics | T4 | https://egg2.wustl.edu/roadmap/ | 200 | - |  |
| P1 | Open Targets Genetics | T4 | https://genetics.opentargets.org/ | 200 | https://platform.opentargets.org/?from=genetics |  |
