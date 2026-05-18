# Architecture

```
                ┌────────────────────────────────────────────┐
                │  Obsidian vault (obsidian/)               │
                │  ── 개념·논문·토픽·일지·ADR (markdown)    │
                └────────────────────────────────────────────┘
                              ▲
                              │ wikilink
                              │
┌─────────────────────────────┴─────────────────────────────┐
│                     AI-Bio-T-Cell (git repo)              │
├─────────────────────────────────────────────────────────────┤
│  datasets/                  ← 19개 데이터셋 메타 + 카탈로그│
│  data/  (raw/processed/...) ← 로컬 분석 데이터 (gitignored)│
│                                                            │
│  src/python/aibio/          ← Python 패키지               │
│    ├ data/ (registry)                                      │
│    ├ preprocessing/ (scanpy 기반)                          │
│    ├ models/ (Flow Matching, GNN, Diffusion)               │
│    ├ eval/                                                 │
│    └ utils/                                                │
│  src/R/R/                   ← Seurat/Signac/Bioc 헬퍼     │
│                                                            │
│  notebooks/python/  ← Jupyter                              │
│  notebooks/R/       ← Rmd                                  │
│                                                            │
│  experiments/<run>/ ← 실험 단위 (config + 결과)           │
│  reports/deliverables/ ← 평가 보고서·슬라이드             │
│  tests/python /R/   ← pytest / testthat                    │
│  .github/workflows/ ← CI (Python + R)                      │
└─────────────────────────────────────────────────────────────┘
```

## 데이터 흐름

1. **데이터 카탈로그** (`datasets/data_catalog.csv`)가 모든 데이터셋의 single source of truth.
2. `aibio.data.registry`가 카탈로그를 파싱하여 Python에서 path lookup 제공.
3. R 쪽에서는 `here::here()` + `datasets/<idx>_<name>/processed/` 규약을 따름.
4. 학습 결과·체크포인트는 `experiments/<run>/runs/`에 저장 (gitignored).
5. 최종 figure/table은 `reports/figures/`, `reports/tables/`에 저장 (git 커밋).

## 의존성 그래프

```
torchcfm ─┐
torch    ─┼─→ aibio.models.flow_matching ─→ experiments/topic1/
torch_geometric ─→ (future) aibio.models.gnn ─→ experiments/topic4/
DNABERT ──────────→ (future) aibio.models.dnabert ─→ experiments/topic4/

scanpy / anndata ─→ aibio.preprocessing / aibio.data
Seurat / Signac ──→ src/R/R/
GenomicRanges ────→ src/R/R/enhancer_analysis.R
```
