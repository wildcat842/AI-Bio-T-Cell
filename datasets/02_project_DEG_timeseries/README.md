# 02 - 프로젝트 DEG 시계열 (P0, T1)

## 개요
- 본 프로젝트가 자체 보유하고 있는 T-Cell 상태 전이 DEG (Differentially Expressed Gene) 시계열 데이터.
- 시점: L7 → L14 → L21 → L35 → L60 (Day 단위 또는 라운드 단위, 내부 문서 확인 필요)
- 토픽 1 (T-Cell 소진 어트랙터 Waddington 재구성)의 핵심 학습 데이터.

## 데이터 위치
- 원본 데이터: 별도 내부 스토리지에 위치 (본 디렉토리에는 미러링 또는 심볼릭 링크만 보관).
- 본 폴더에는 메타데이터, 전처리 산출물(AnnData)만 보관.

## TODO (M1-M3)
- [ ] `목록.xlsx`의 sketch와 정합하여 sample manifest 작성
- [ ] AnnData(.h5ad) 표준 포맷으로 변환
- [ ] Cell Ontology(CL) 기반 cell type annotation 적용
- [ ] 시점 라벨을 `obs["timepoint"]` (Categorical: L7/L14/L21/L35/L60)로 정규화
- [ ] 외부 reference (Tabula Sapiens, Daniel 2022)와 batch correction 가능성 검토

## 모델링 활용
- 토픽 1의 Flow Matching / Unbalanced Schrödinger Bridge 학습의 시계열 axis.
- 토픽 4 모델의 perturbation validation set (enhancer SNP → DEG 변화 예측 검증).
