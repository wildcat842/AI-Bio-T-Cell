---
title: "Topic 4 - 인핸서 조절 네트워크 생성형 AI"
priority: 1
duration_months: 12
status: planning
tags: [topic, topic/4, method/dnabert, method/gnn, method/diffusion, data/reaptec]
---

# Topic 4 - T-Cell 인핸서 조절 네트워크 생성형 AI

## 한 줄
RIKEN ReapTEC 63K 인핸서를 노드로 하는 조절 네트워크를 GNN으로 학습하고, **Diffusion model**로 SNP 도입 시 transcriptome 변화를 예측.

## 목표
- 자가면역 18개 질환별 인핸서-유전자-질환 인과 그래프 학습
- in-silico perturbation으로 신규 치료 타겟 후보 50개 도출
- RIKEN AIP 신약 발견 유닛과 연계

## 핵심 가설
- ReapTEC의 transcribed bidirectional enhancer는 chromatin only enhancer보다 인과적 신호가 강하다.
- DNABERT seq embedding + GNN structure embedding의 dual 표현이 perturbation 예측에서 single 표현을 능가한다.

## 입력 데이터
- [[../10_Concepts/ReapTEC_Enhancer_Atlas|RIKEN ReapTEC]] (P0, MTA 필요)
- ENCODE TF ChIP-seq (P0, open)
- GTEx v8 eQTL whole-blood/spleen (P0, summary open)
- GWAS Catalog 18 immune diseases (P0, open)
- FANTOM5 CAGE (P1, cross-reference)
- Open Targets Genetics L2G (P1)

## 방법
- DNABERT enhancer sequence embedding (Ji 2021)
- GNN regulatory network (PyTorch Geometric)
- Conditional Diffusion perturbation
- 검증: reporter assay (RIKEN 실험팀)

## 산출물
- Cell Genomics 또는 Nature Genetics급 논문
- 자가면역 신규 치료 타겟 후보 목록
- in-silico perturbation tool (Python package)

## RIKEN 시너지
- IMS Murakawa 팀 직접 협업 (ReapTEC 데이터)
- IMS Laboratory for Autoimmune Diseases (타겟 검증)
- RIKEN AIP AI 신약 발견 협력 유닛

## 마일스톤
- [ ] M1-M3 - ReapTEC processed atlas 다운로드, ENCODE/GTEx/GWAS 정합
- [ ] M3-M6 - DNABERT enhancer embedding, GNN baseline
- [ ] M6-M9 - Diffusion perturbation, 후보 SNP 50개
- [ ] M9-M12 - Cell Genomics 투고

## 위험
| 위험 | 영향 | 완화 |
| --- | --- | --- |
| ReapTEC raw MTA 지연 | 매우 큼 | 1-3개월에 processed atlas로 prototype |
| 인핸서-질환 인과성 검증 부재 | 중 | RIKEN 실험팀과 reporter assay |
