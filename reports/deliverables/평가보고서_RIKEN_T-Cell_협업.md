# RIKEN 복잡계 연구소 협업 T-Cell 연구 토픽 평가 보고서

**작성일**: 2026-05-16
**작성자**: AI Bio 프로젝트팀 (Sojung Kim)
**대상 제안서**: `RIKEN_복잡계_연구소_협업_T-Cell_특화_연구_토픽_제안.pdf`
**평가 기준**:
- AI Virtual Cells 프레임워크 (arXiv:2409.11654v2, Bunne et al. 2024)
- RIKEN Oguchi et al. 2024 (Science, ReapTEC) 실험 역량
- 데이터 가용성·접근성·전처리 비용
- 12~24개월 내 산출물 가시성

---

## 1. 종합 권고 (Executive Summary)

본 협업 제안서는 RIKEN IMS/iTHEMS/BDR의 강점(ReapTEC 인핸서 아틀라스, 비선형 동역학 이론, 자동화 실험 인프라)과 본 연구팀의 AI 가상 세포 방법론(확산 모델·플로우 매칭·GNN)을 결합한 **4개의 차별화된 연구 토픽**을 제시한다. 각 토픽의 과학적 타당성과 데이터 요구사항을 검토한 결과, 다음과 같은 결론에 도달했다.

| 우선순위 | 토픽 | 권고 | 핵심 근거 |
| --- | --- | --- | --- |
| **1순위 (즉시 착수)** | 토픽 4: T-Cell 인핸서 조절 네트워크 생성형 AI | **강력 추진** | RIKEN 자체 데이터(ReapTEC) 직접 활용 → 협업 진입 장벽 최저, 6~9개월 내 초기 성과 가능, 자가면역 타겟 발굴 임팩트 높음 |
| **2순위 (병렬 추진)** | 토픽 1: T-Cell 소진 어트랙터 Waddington 경관 재구성 | **강력 추진** | iTHEMS 복잡계 수학팀과의 시너지가 가장 큰 차별화 토픽. AI Virtual Cells 비전 논문의 핵심 도전과제(state/perturbation/context)에 부합 |
| **3순위 (12개월 후)** | 토픽 3: TME 공간 가상 세포 모델 | 조건부 진행 | HEST-1k 등 외부 공개 데이터 활용 가능하나, BDR 공간 오믹스 데이터 접근 협약이 선행되어야 차별성 확보 |
| **4순위 (장기)** | 토픽 2: TCR 레퍼토리 그래프 기초 모델 | 보류/장기 검토 | 난이도 ★★★★★, Fugaku 슈퍼컴퓨터 의존, 18개월+ 소요. 토픽 1/4 성과 확보 후 재평가 권장 |

**핵심 권고**: 토픽 4 (단기 가시성) + 토픽 1 (장기 차별성)의 **병렬 추진 (12개월 동시)** 전략을 채택하되, 두 토픽이 모두 ReapTEC 아틀라스를 공통 입력으로 활용한다는 점에서 **데이터 전처리 파이프라인 통합**을 1순위 인프라 과제로 설정한다.

---

## 2. AI Virtual Cells 프레임워크에 비춘 과학적 타당성

Bunne et al. 2024 (arXiv:2409.11654v2)는 AI 가상 세포의 세 가지 핵심 표현 축으로 **State (세포 상태)**, **Perturbation (교란 반응)**, **Context (조직·환경 맥락)**를 제시한다. 4개 토픽을 이 프레임워크에 매핑하면 다음과 같다.

### 2.1 토픽별 AI Virtual Cell 매핑

**토픽 1 (T-Cell 소진 어트랙터)** → **State 축 강화**
- Waddington 경관 재구성은 AI 가상 세포의 "high-fidelity cell state representation" 목표와 정확히 일치한다.
- Unbalanced Flow Matching (Pariset 2023, Tong 2024)을 T-Cell exhaustion에 적용한 사례는 아직 보고되지 않음 → **novelty 매우 높음**.
- Daniel et al. 2022의 progenitor exhausted 분기(divergent) 발견을 정량화·예측 가능한 모델로 전환하는 의의가 크다.
- **잠재적 위험**: Unbalanced Schrödinger Bridge의 학습 수렴 안정성, 세포 증식/사멸 정량화의 ground truth 부재.

**토픽 4 (인핸서 조절 네트워크)** → **Perturbation 축 강화**
- 63,000개 ReapTEC 인핸서와 18개 면역 질환 GWAS의 인과적 연결은 "in-silico perturbation prediction"의 모범 사례가 될 수 있다.
- DNABERT (Ji 2021) 임베딩 + GNN regulatory network + Diffusion model perturbation은 검증된 모듈의 조합으로 **실현 가능성 매우 높음**.
- **차별점**: 기존 enhancer-gene linkage 연구(ABC model, EpiMap)는 정적 mapping에 머무름. 본 토픽은 SNP 도입 시 transcriptome 변화를 생성형으로 예측 → 신약 타겟 발굴까지 연결.
- **잠재적 위험**: ReapTEC 데이터의 raw access 협약 필요, GWAS-enhancer 인과성 검증의 실험적 한계.

**토픽 3 (TME 공간 복잡계)** → **Context 축 강화**
- STELLAR (Brbic 2022) + HEST (HEST-1k) + 확산 모델 perturbation의 조합은 기술적으로 견고하지만, **공개 HEST-1k 활용 시 RIKEN 시너지가 약함**.
- BDR의 3D 공간 오믹스 데이터 또는 IMS CODEX 이미징 데이터 접근이 협약된다면 차별성이 크게 상승.
- **잠재적 위험**: 공간 데이터의 batch effect, ICI 반응 데이터의 표본 크기 제약.

**토픽 2 (TCR 레퍼토리)** → **State + Perturbation의 collective dynamics**
- 개념적으로 가장 야심차나, 레퍼토리의 ground truth dynamics(시계열) 데이터가 매우 제한적이다.
- BertTCR (PMC11342255), VDJdb, IEDB만으로는 collective dynamics 학습이 어렵고, **HLA-restricted antigen specificity가 데이터셋 간 불균질**.
- Fugaku 활용은 R-CCS 협약·자원 할당이 별도 협상 과제. **18개월+ 일정에 risk premium 추가**.

### 2.2 RIKEN 시너지 매트릭스

| 토픽 | IMS Murakawa팀 | iTHEMS 수학팀 | BDR 자동화팀 | R-CCS Fugaku | 종합 |
| --- | --- | --- | --- | --- | --- |
| 1. 소진 어트랙터 | ◯ (Nomura팀 협업) | ◎ (어트랙터 안정성) | △ (검증 실험) | △ | **★★★★★** |
| 2. TCR 레퍼토리 | ◯ (자가면역 TCR) | ◯ (네트워크 위상) | × | ◎ (대규모 학습) | ★★★☆☆ |
| 3. TME 공간 | ◯ (CODEX) | × | ◎ (3D 공간 오믹스) | △ | ★★★★☆ |
| 4. 인핸서 네트워크 | ◎ (ReapTEC 직접) | △ | × | △ | **★★★★★** |

토픽 1과 4가 RIKEN의 **다부서 협업**을 가장 효과적으로 활용한다.

---

## 3. 데이터 요구사항 분석

### 3.1 공통 인프라 데이터 (토픽 1/4 공통)

| 데이터 | 유형 | 규모 | 접근 비용 | 협약 필요 |
| --- | --- | --- | --- | --- |
| RIKEN ReapTEC T-Cell Atlas | bidirectional enhancer × cell × disease | ~63K enhancers × ~1M cells × 18 diseases | 공개 부분 + raw 접근 협약 | **YES** (IMS Murakawa팀) |
| 프로젝트 보유 DEG 시계열 | bulk/scRNA, L7→L60 | 내부 | 0 | NO (보유) |
| ENCODE ChIP-seq (TF binding) | bedGraph, narrowPeak | ~수 TB (필터링 시 ~50 GB) | 공개 (CC0) | NO |
| GTEx v8 eQTL | tabular | ~10 GB | 공개 | NO |
| GWAS Catalog (18 immune diseases) | tabular | <1 GB | 공개 | NO |

### 3.2 토픽 1 추가 데이터

| 데이터 | 출처 | 비고 |
| --- | --- | --- |
| Daniel et al. 2022 scRNA-seq | GEO GSE201088 (PMC11225711 기반) | T-cell exhaustion divergent trajectory, mouse LCMV |
| 10x PBMC Multiome | 10x Genomics datasets | scRNA + ATAC + TCR-seq 동시 측정, ~10K cells |
| Tabula Sapiens / HCA T-cells | CZ CellxGene | human reference atlas, batch correction용 |

### 3.3 토픽 4 추가 데이터

| 데이터 | 출처 | 비고 |
| --- | --- | --- |
| FANTOM5 CAGE | RIKEN FANTOM | 인핸서 활성도 cross-reference |
| Roadmap Epigenomics | NIH | chromatin state segmentation |
| Open Targets Genetics | EMBL-EBI | GWAS-gene linkage 메타스코어 |

### 3.4 데이터 거버넌스 이슈

- **ReapTEC raw 접근**: Oguchi 2024 publication은 processed atlas만 공개. cellular-level raw FASTQ는 EGA controlled access 또는 RIKEN DDBJ 보호 영역에 위치할 가능성. **MTA(Material Transfer Agreement) 협상이 협업의 critical path**.
- **GWAS individual-level data**: 대부분 dbGaP 또는 EGA controlled. summary statistics만 우선 활용 권장.
- **개인정보·윤리**: 환자 유래 TIL 데이터(TCGA 등)는 IRB 면제 범위 내 사용 확인 필요.

---

## 4. 위험·완화 전략

| 위험 | 가능성 | 영향 | 완화 |
| --- | --- | --- | --- |
| ReapTEC raw 데이터 MTA 지연 | 중 | 매우 큼 | 1~3개월차에 공개 processed atlas 만으로 prototype 구축 → MTA 체결 후 확장 |
| Unbalanced Schrödinger Bridge 수렴 불안정 | 중 | 큼 | TorchCFM (Tong 2024) baseline 우선 확보 → UDSB는 ablation으로 추가 |
| 인핸서-질환 인과성 검증 부재 | 높음 | 중 | RIKEN 실험팀과 reporter assay 후속 실험 설계 |
| Fugaku 자원 할당 실패 (토픽 2) | 높음 | 매우 큼 | 토픽 2 보류 의사결정 정당화 근거 |
| 데이터 표준화/메타데이터 불일치 | 높음 | 중 | CZ CellxGene Cellxgene-Schema, OBO Cell Ontology 채택 |

---

## 5. 12개월 로드맵 (권고안)

```
M1-M3 (기반):
  - ReapTEC processed atlas 다운로드/정합
  - 프로젝트 DEG 시계열 → AnnData/MuData 통합 포맷 정리
  - 공개 Daniel 2022, 10x Multiome 통합 전처리
  - MTA 협상 시작 (IMS Murakawa팀, IMS Nomura팀)

M3-M6 (토픽 4 prototype):
  - DNABERT + ReapTEC enhancer embedding 학습
  - GNN regulatory network (enhancer-gene) baseline
  - GWAS overlap analysis 자가면역 18개 질환

M3-M6 (토픽 1 prototype):
  - TorchCFM으로 Daniel 2022 naive→effector→exhausted 학습
  - iTHEMS와 어트랙터 분석 합동 워크샵 (월 1회)

M6-M9 (확장):
  - 토픽 4 diffusion perturbation 모델 추가, 후보 SNP 50개 도출
  - 토픽 1 UDSB 도입, progenitor exhausted 안정성 분석
  - 중간 결과: bioRxiv preprint × 2

M9-M12 (검증·논문):
  - RIKEN 실험팀과 in-silico → in-vitro 검증 사이클
  - 논문 submission 준비 (Cell Genomics / Nature Methods)
```

---

## 6. 부록 - 평가 체크리스트

- [x] AI Virtual Cells (Bunne 2024) 세 축(State/Perturbation/Context) 매핑 완료
- [x] RIKEN 4개 부서(IMS Murakawa/IMS Nomura/iTHEMS/BDR) 시너지 매트릭스 작성
- [x] 데이터 거버넌스(MTA, dbGaP, IRB) 이슈 식별
- [x] 위험·완화 전략 5개 항목 정리
- [x] 12개월 로드맵 마일스톤 4분기 정의
- [x] 데이터 카탈로그 별도 산출물(`데이터_카탈로그.csv`)로 정리

---

## 7. 참고문헌

1. Oguchi et al. (2024) "An atlas of transcribed enhancers across helper T cell diversity for decoding human diseases." *Science*. doi:10.1126/science.add8394
2. Bunne et al. (2024) "AI Virtual Cells: Priorities and Opportunities." arXiv:2409.11654v2
3. Daniel et al. (2022) "Divergent clonal differentiation trajectories of T cell exhaustion." (PMC11225711)
4. Pariset et al. (2023) "Unbalanced Diffusion Schrödinger Bridge." arXiv:2306.09099
5. Tong et al. (2024) "Improving and Generalizing Flow-Based Generative Models with Minibatch Optimal Transport." TMLR
6. Brbic et al. (2022) "Annotation of spatially resolved single-cell data with STELLAR." *Nature Methods*
7. Ji et al. (2021) "DNABERT." *Bioinformatics*
8. Nomura, A. (2025) "Supporting 'exhausted' immune cells." RIKEN People, Dec 19, 2025
