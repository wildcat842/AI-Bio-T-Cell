---
title: AI-Bio-T-Cell Home
created: 2026-05-18
updated: 2026-05-18
tags: [index, moc]
status: living
---

# AI-Bio-T-Cell Home

> **AI 가상 세포 × RIKEN ReapTEC × 복잡계 동역학**으로 T-Cell 면역을 모델링하는 프로젝트의 노트 진입점.

## 빠른 링크

- 코드 레포: https://github.com/wildcat842/AI-Bio-T-Cell
- 평가 보고서: [[../reports/deliverables/평가보고서_RIKEN_T-Cell_협업|평가보고서]]
- 데이터 카탈로그: `../datasets/data_catalog.csv`

## 4개 연구 토픽

- [[20_Topics/Topic1_Waddington_Attractor|토픽 1 - 소진 어트랙터 Waddington]] · `#topic/1` · 1순위 (병렬)
- [[20_Topics/Topic2_TCR_Foundation_Model|토픽 2 - TCR 레퍼토리 GFM]] · `#topic/2` · 4순위 (보류)
- [[20_Topics/Topic3_TME_Spatial|토픽 3 - TME 공간 가상 세포]] · `#topic/3` · 3순위 (조건부)
- [[20_Topics/Topic4_Enhancer_Regulatory_Network|토픽 4 - 인핸서 조절 네트워크]] · `#topic/4` · **1순위**

## 배경 개념 (MOC)

- [[10_Concepts/AI_Virtual_Cells]]
- [[10_Concepts/T_Cell_Exhaustion]]
- [[10_Concepts/ReapTEC_Enhancer_Atlas]]

## 방법론

- [[60_Methods/Flow_Matching]]
- [[60_Methods/Unbalanced_Schrodinger_Bridge]]
- [[60_Methods/DNABERT2_Embedding]]
- [[60_Methods/GNN_Enhancer_Network]]
- [[60_Methods/ReapTEC_Pipeline]]
- [[60_Methods/R_Python_Bridge]]

## 학습 자료

- [[60_Methods/R_Manual|R 매뉴얼 - 본 프로젝트 초보자 가이드]] · `#tutorial #language/R` — Seurat까지, VS Code 환경 기준

## 핵심 논문

- [[50_Literature/Oguchi2024_ReapTEC]] (RIKEN, Science 2024)
- [[50_Literature/Bunne2024_AI_Virtual_Cells]] (arXiv 2024)
- [[50_Literature/Daniel2022_Exhaustion]] (PMC11225711)

## 의사결정 기록 (ADR)

- [[70_Decisions/ADR-001_Tooling_Python_R_Obsidian]]

## 운영

- 일지: `30_Daily/` (Daily Notes 플러그인이 `_templates/Daily` 사용)
- 회의: `40_Meetings/`
- 템플릿: `_templates/`

## 협업 파트너

- RIKEN IMS Murakawa 팀 (ReapTEC)
- RIKEN IMS Nomura 팀 (T-cell exhaustion progenitor)
- RIKEN iTHEMS (복잡계 수학)
- RIKEN BDR AI Biology Lab (자동화 실험)
