# 14 - ENCODE TF ChIP-seq (P0, T4)

## 개요
- ENCODE Portal에서 제공하는 T-cell / hematopoietic lineage 관련 전사인자(TF) ChIP-seq 데이터.
- 인핸서-TF 결합 매핑의 기준 reference.

## 접근
- 공개 (CC0)
- URL: https://www.encodeproject.org/

## 권장 필터
- Assay: ChIP-seq
- Biosample classification: cell line / primary cell
- Biosample term: CD4-positive helper T cell, CD8-positive T cell, Jurkat, Thymus 등
- File format: bigWig (signal), bed narrowPeak (peaks)

## TODO
- [ ] ENCODE REST API로 T-cell 관련 ChIP-seq 메타데이터 일괄 수집
- [ ] TF별 peak set 다운로드 (Top 50 TF 우선)
- [ ] ReapTEC enhancer coordinates와 overlap 계산 (`scripts/overlap_enhancers.py`)

## 모델링 활용
- 토픽 4: GNN regulatory network에서 enhancer ↔ TF ↔ target gene 트리플의 edge feature.
