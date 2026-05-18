# 03 - Daniel et al. 2022 Divergent Exhaustion (P1, T1)

## 인용
Daniel, B., et al. (2022). "Divergent clonal differentiation trajectories of T cell exhaustion." (PMC11225711)

## 개요
- 마우스 LCMV chronic infection 모델에서 CD8+ T cell exhaustion의 분기(divergent) clonal differentiation trajectory를 보인 scRNA-seq.
- Progenitor exhausted (TPEX) ↔ Terminally exhausted (TEX) 분기점 정의.
- RIKEN Nomura 2025 finding의 학술적 기반.

## 접근
- GEO: 데이터 accession은 논문 본문/SI에서 확인 (예: GSE201088 류)
- URL: https://www.ncbi.nlm.nih.gov/geo/

## TODO
- [ ] GEO 정확한 accession 확정 후 raw counts + metadata 다운로드
- [ ] AnnData(.h5ad)로 변환, scanpy standard preprocessing
- [ ] 본 프로젝트 DEG 시계열과의 cell type label transfer 검토 (scANVI 또는 Tangram)

## 모델링 활용
- 토픽 1의 Naive → Effector → Progenitor Exhausted → Terminal Exhausted Waddington 경관 학습 기준 데이터.
