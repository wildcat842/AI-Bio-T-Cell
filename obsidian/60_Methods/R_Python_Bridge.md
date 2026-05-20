---
title: R ↔ Python Bridge
tags: [method, infrastructure, bridge]
status: living
---

# R ↔ Python Bridge

## 한 줄
Seurat `.rds`(R) ↔ AnnData `.h5ad`(Python) 사이의 양방향 변환 표준.

## 추천 경로 (단방향, R → Python, 한 번 변환)

```
Seurat .rds ──[sceasy::convertFormat]──> .h5ad
                                            │
                                            ├── scanpy / anndata (Python)
                                            ├── mudata (멀티모달)
                                            ├── PyG dataset (GNN 입력)
                                            └── torchcfm dataset (Flow Matching)
```

## 도구 비교

| 도구 | 방향 | 장점 | 단점 |
| --- | --- | --- | --- |
| sceasy | R→Py (메인) | 한 줄, Seurat assay/dim reduc 보존 | reticulate 의존 (Python 경로 명시 필요) |
| SeuratDisk | R→Py (폴백) | 매우 안정, 대용량 우수 | h5Seurat 중간 단계 필요 |
| anndata2ri | Py←R (대안) | rpy2 사용, Python에서 직접 호출 | 의존성 무겁고 SCE 기반이라 Seurat에서는 한 단계 변환 더 |
| zellkonverter | R Bioc | SCE ↔ AnnData 표준 | Seurat → SCE 변환 추가 필요 |

## 본 프로젝트 표준
1. **변환 스크립트**: `datasets/01_reaptec_atlas/scripts/rds_to_h5ad.R` (sceasy 우선, SeuratDisk 폴백)
2. **저장 포맷**: `.h5ad` (gzip 압축, AnnData 0.10+)
3. **검증**: `verify_h5ad.py`로 shape/obs/var/layers/raw vs normalized sanity check
4. **Python 사용**: `scanpy.read_h5ad(..., backed="r")` (메모리 절약)

## reticulate 셋업 (R 측에서 Python 경로 명시)

```r
# .Renviron 또는 R 스크립트 상단
Sys.setenv(RETICULATE_PYTHON = "~/miniconda3/envs/AI-Bio-T-Cell/bin/python")
library(reticulate)
use_condaenv("AI-Bio-T-Cell", required = TRUE)
py_config()  # Python 경로 확인
```

## 디버깅 체크리스트
- [ ] sceasy 설치 후 `reticulate::py_module_available("anndata")` 가 TRUE인가
- [ ] Seurat 객체 버전 (Seurat 4 vs 5) - `UpdateSeuratObject()` 필요할 수 있음
- [ ] DefaultAssay가 의도한 assay인가
- [ ] 변환 후 obs/var 컬럼 이름이 Python에서 사용 가능한 문자만 포함하는가

## 관련
- [[../70_Decisions/ADR-001_Tooling_Python_R_Obsidian]]
- [[../20_Topics/Topic4_Enhancer_Regulatory_Network]]
- `reports/deliverables/environment_design.md` §2
