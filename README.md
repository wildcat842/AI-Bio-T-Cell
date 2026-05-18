# AI-Bio-T-Cell

**AI 가상 세포(AI Virtual Cells) × RIKEN ReapTEC × iTHEMS 복잡계 동역학을 결합한 T-Cell 면역 연구 프로젝트**

본 레포지토리는 RIKEN 복잡계 연구소(IMS / iTHEMS / BDR)와의 협업 과제를 수행하기 위한 코드·데이터 카탈로그·노트·산출물을 통합 관리합니다.

## 핵심 연구 토픽 (병렬 추진 권장)

| 우선순위 | 토픽 | 핵심 방법론 | 산출물 |
| --- | --- | --- | --- |
| 1순위 | **토픽 4** - T-Cell 인핸서 조절 네트워크의 생성형 AI | DNABERT + GNN + Diffusion perturbation | Cell Genomics급 논문 + 자가면역 타겟 후보 |
| 1순위 (병렬) | **토픽 1** - T-Cell 소진 Waddington 어트랙터 재구성 | Unbalanced Schrödinger Bridge + Flow Matching | Nature Methods급 논문 + Python/R 패키지 |
| 3순위 | 토픽 3 - TME 공간 가상 세포 모델 | STELLAR + HEST + 확산 모델 | Nature Cancer급 (조건부) |
| 4순위 (보류) | 토픽 2 - TCR 레퍼토리 그래프 기초 모델 | GNN + Transformer | Nature Immunology급 (Fugaku 확보 시) |

상세 평가는 [reports/deliverables/평가보고서_RIKEN_T-Cell_협업.md](reports/deliverables/평가보고서_RIKEN_T-Cell_협업.md) 참조.

## 레포지토리 구조

```
AI-Bio-T-Cell/
├── README.md                          # 본 파일
├── LICENSE                            # MIT
├── CITATION.cff                       # 인용 방법
├── pyproject.toml                     # Python 패키지/도구 설정 (PEP 621)
├── requirements.txt                   # pip fallback
├── environment.yml                    # Conda 환경
├── DESCRIPTION                        # R 패키지 메타데이터
├── renv.lock                          # R 의존성 잠금 (renv)
├── Makefile                           # 공통 작업 자동화
├── .gitignore / .gitattributes        # 대용량 제외 + Git LFS 설정
│
├── data/                              # 로컬 분석 데이터 (gitignored)
│   ├── raw/                            원본 (불변)
│   ├── interim/                        중간 처리물
│   ├── processed/                      분석 ready
│   └── external/                       외부 참고 데이터
│
├── datasets/                          # 데이터셋 카탈로그 (구조만 커밋, 데이터는 gitignored)
│   ├── README.md
│   ├── data_catalog.csv               # 19개 데이터셋 메타데이터
│   ├── 01_reaptec_atlas/ ... 19_opentargets/
│   └── .gitignore
│
├── src/
│   ├── python/aibio/                  # Python 패키지 (data/models/preprocessing/eval/utils)
│   ├── python/scripts/                # 일회성 Python 스크립트
│   ├── R/R/                           # R 함수 (Seurat/Signac 헬퍼)
│   └── R/scripts/                     # R 분석 스크립트
│
├── notebooks/
│   ├── python/                        # Jupyter 노트북
│   └── R/                             # Rmd 노트북
│
├── experiments/                       # 실험 단위 폴더 (config + 결과 + 로그)
│   └── _template/
│
├── reports/
│   ├── figures/
│   ├── tables/
│   └── deliverables/                  # 평가 보고서·슬라이드·카탈로그 등
│
├── tests/
│   ├── python/                        # pytest
│   └── R/                             # testthat
│
├── obsidian/                          # Obsidian vault (공동 노트)
│   ├── .obsidian/                     # vault 설정
│   ├── 00_Index/                       Home, MOC (Map of Contents)
│   ├── 10_Concepts/                    배경 개념
│   ├── 20_Topics/                      토픽별 작업 노트
│   ├── 30_Daily/                       일지 (daily notes)
│   ├── 40_Meetings/                    회의록
│   ├── 50_Literature/                  논문 노트
│   ├── 60_Methods/                     방법론
│   ├── 70_Decisions/                   ADR (Architecture Decision Records)
│   └── _templates/                     템플릿
│
├── references/                        # 핵심 참고 PDF/엑셀 (LFS)
│
├── docs/                              # 외부 공개용 문서
│
├── scripts/                           # 레포 자동화 스크립트 (git/CI 등)
└── .github/workflows/                 # CI: Python(pytest+ruff) / R(devtools::check)
```

## 빠른 시작

### Python 환경
```bash
# 옵션 A: conda
conda env create -f environment.yml
conda activate aibio

# 옵션 B: pip + venv
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
```

### R 환경
```r
# renv로 의존성 복원 (renv 미설치 시 install.packages("renv"))
renv::restore()

# 또는 수동 설치
install.packages(c("Seurat", "Signac", "tidyverse", "BiocManager", "devtools", "testthat"))
BiocManager::install(c("GenomicRanges", "SingleCellExperiment", "rtracklayer"))
```

### Obsidian 노트 열기
1. Obsidian 설치 (https://obsidian.md)
2. "Open folder as vault" → `AI-Bio-T-Cell/obsidian/` 선택
3. 시작점: `00_Index/Home.md`

자세한 사용은 [obsidian/README.md](obsidian/README.md) 참조.

## 데이터 거버넌스

본 프로젝트는 다음 원칙을 따릅니다 (CLAUDE.md 기준).

- **대규모 데이터**: 폴더 구조와 메타데이터만 커밋, 원본은 `.gitignore` 처리
- **통제 접근 데이터** (ReapTEC raw 등): MTA 협상 후 별도 보관 위치 사용
- **공개 데이터 (.h5ad 등)**: Git LFS 또는 외부 스토리지 (Zenodo/HuggingFace)
- **개인정보 포함 데이터**: IRB/윤리위 승인 범위 내에서만 사용

상세는 [datasets/README.md](datasets/README.md) 참조.

## 협업·기여

- 회의록: `obsidian/40_Meetings/`
- 의사결정 기록(ADR): `obsidian/70_Decisions/`
- 일일 진행: `obsidian/30_Daily/`
- 코드 변경: Pull Request 기반, CI 통과 필수 (Python: ruff+pytest, R: devtools::check)

## 라이선스

- 코드: MIT (LICENSE 참조)
- 노트·문서: CC-BY-4.0
- 데이터셋: 각 데이터셋의 원본 라이선스를 따름 (`datasets/*/README.md` 참조)

## 인용

본 프로젝트를 인용할 때는 [CITATION.cff](CITATION.cff)를 참조해 주세요.

## 연락

- 책임자: Sojung Kim (sojung.kim.nca@gmail.com)
- 협업 파트너: RIKEN IMS (Murakawa팀, Nomura팀), iTHEMS, BDR
