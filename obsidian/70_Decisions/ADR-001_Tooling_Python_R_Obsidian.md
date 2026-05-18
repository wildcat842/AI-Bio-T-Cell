---
title: "ADR-001 - Python + R + Obsidian 도구 결정"
date: 2026-05-18
status: accepted
deciders: [Sojung Kim]
tags: [decision, adr]
---

# ADR-001 - Python + R + Obsidian 도구 결정

## 컨텍스트
- 본 프로젝트는 단일 세포·벌크 RNA-seq·ATAC-seq·공간 오믹스를 다룬다.
- 딥러닝 모델(Flow Matching, GNN, Diffusion)은 Python 생태계가 표준.
- 단일 세포 quality control·시각화·일부 GenomicRanges 분석은 R(Seurat, Signac, Bioconductor)이 표준.
- 공동 연구 노트는 RIKEN 협업자들과 공유 필요.

## 결정
1. **Python**을 ML/딥러닝의 1순위 언어로 사용 (`src/python/aibio/`).
2. **R**을 단일 세포 전처리, Seurat/Signac 분석, 일부 통계 모델링에 사용 (`src/R/`).
3. **Obsidian**을 공동 노트·문헌·의사결정 기록의 1순위 도구로 사용 (`obsidian/`).
4. 의존성 관리: Python은 `pyproject.toml` + conda env, R은 `renv` + DESCRIPTION.
5. CI: GitHub Actions로 Python(ruff+pytest) / R(testthat) 양쪽 검증.

## 대안 검토
- **All-Python (scvi-tools)**: Seurat 생태계의 일부 기능 부재, 협업자 onboarding 부담.
- **All-R (BPCells 등)**: 딥러닝 모델 구현 비용 높음.
- **Notion/Confluence vs Obsidian**: Obsidian은 markdown + git 기반 → 코드 레포와 통합 우수, 오프라인.

## 결과
- 두 언어 병행 비용은 있지만, 각 생태계 strength를 활용 가능.
- Obsidian + git의 조합으로 노트가 코드 변경 history와 함께 추적됨.

## 관련
- [[../../README]]
- [[../README|Obsidian vault README]]
