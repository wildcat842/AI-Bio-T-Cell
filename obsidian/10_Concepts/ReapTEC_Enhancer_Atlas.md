---
title: ReapTEC Enhancer Atlas
tags: [concept, data/reaptec]
ref: "Oguchi et al. 2024, Science, doi:10.1126/science.add8394"
---

# RIKEN ReapTEC T-Cell Enhancer Atlas

## 개요
- **ReapTEC** = **Reactive 5' end Profiling for Transcribed Enhancer Catalog**
- ~1,000,000 인간 helper T 세포에서 **63,000개 활성 transcribed bidirectional enhancer** 발견
- **18개 면역 매개 질환** GWAS와 cross-reference → 606개 enhancer가 질환과 연결

## 왜 중요한가
- 기존 enhancer annotation(ChromHMM 등)은 chromatin mark에 의존 → false positive 많음
- ReapTEC은 **transcribed** enhancer만 포착 → 인과적 신호 강함
- GWAS hit의 ~80%가 비코딩 영역 → enhancer 매핑이 신약 타겟 발굴의 missing link

## 본 프로젝트에서의 역할
- 토픽 4: GNN regulatory network의 enhancer 노드 (P0 데이터)
- 토픽 1: 세포 상태 표현의 추가 feature

## 접근
- Processed atlas: Science 2024 SI (open)
- Raw FASTQ: RIKEN DDBJ/EGA (MTA 필요)

## 관련
- [[../20_Topics/Topic4_Enhancer_Regulatory_Network]]
- [[../50_Literature/Oguchi2024_ReapTEC]]
- `datasets/01_reaptec_atlas/`
