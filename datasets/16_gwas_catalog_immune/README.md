# 16 - GWAS Catalog (18 immune-mediated diseases) (P0, T4)

## 개요
- NHGRI-EBI GWAS Catalog의 면역 매개 질환 SNP-trait association summary statistics.
- ReapTEC enhancer coordinates와 SNP overlap → 인핸서-질환 연결의 핵심 입력.

## 접근
- URL: https://www.ebi.ac.uk/gwas/
- 라이선스: Open (summary stats), individual-level은 별도 dbGaP/EGA

## 18개 면역 매개 질환 (ReapTEC 논문 cross-reference)
RA, SLE, IBD (Crohn's + UC), T1D, MS, Psoriasis, AS, Asthma, Allergy, Celiac, Atopic dermatitis, Vitiligo, AITD (Graves' + Hashimoto's), Sarcoidosis, Behçet, Sjögren, JIA, PBC (예시 - ReapTEC 논문 supplementary 확정 필요)

## TODO
- [ ] GWAS Catalog REST API로 18개 질환의 association 일괄 다운로드
- [ ] EFO trait ID 매핑 표 작성 (`metadata/efo_mapping.tsv`)
- [ ] LD-expanded SNP set 생성 (PLINK 또는 LDproxy, EUR/EAS population별)
- [ ] ReapTEC enhancer BED와 intersect 분석 → `processed/snp_enhancer_overlap.tsv`

## 모델링 활용
- 토픽 4: GNN regulatory network의 disease-relevant subgraph 추출, perturbation 시나리오 생성.
