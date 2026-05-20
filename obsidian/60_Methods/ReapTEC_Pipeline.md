---
title: ReapTEC Pipeline
tags: [method, pipeline, ReapTEC]
ref: "MurakawaLab/ReapTEC (GitHub)"
status: notes
---

# ReapTEC Pipeline

## 한 줄
RIKEN Murakawa Lab의 **5' scRNA-seq 분석 파이프라인**. 5' end 위치를 정밀하게 호출하여 **gene expression**과 **bidirectional enhancer activity**를 동일 단일 세포에서 동시 추정한다.

## 핵심 아이디어
- 5' end CAGE 신호로부터 transcription start cluster (TC) 호출
- 양방향(bidirectional) TC가 인핸서의 전형적 시그니처 → 그 위치를 enhancer로 라벨링
- gene expression matrix와 enhancer expression matrix를 **동일 cell index**로 공급
- 결과: 한 세포에서 RNA + enhancer activity를 동시 측정

## 입력 / 출력
- 입력: 5' scRNA-seq FASTQ (10x 5' chemistry 등)
- 출력:
  - gene × cell expression matrix
  - bidirectional transcribed enhancer × cell matrix (~63K loci)
  - Seurat .rds 객체 (Dryad에 공개)

## 본 프로젝트에서의 사용
- 자체 FASTQ를 처리하지는 않음. **Dryad 공개 산출물을 직접 사용**.
- 단, 토픽 4의 prototype 학습 후 자체 데이터 분석이 필요해지면 RIKEN MTA + ReapTEC 파이프라인 직접 실행.

## 데이터 카탈로그
- 파일 인벤토리: `datasets/01_reaptec_atlas/README.md`
- Dryad: doi:10.5061/dryad.pk0p2ngwx (161.66 GB / P0 부분은 22.2 GB)

## 관련
- [[../10_Concepts/ReapTEC_Enhancer_Atlas]]
- [[../20_Topics/Topic4_Enhancer_Regulatory_Network]]
- [[../50_Literature/Oguchi2024_ReapTEC]]
