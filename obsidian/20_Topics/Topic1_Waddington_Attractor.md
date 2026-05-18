---
title: "Topic 1 - T-Cell 소진 Waddington 어트랙터"
priority: 1
duration_months: 12
status: planning
tags: [topic, topic/1, method/flow-matching]
---

# Topic 1 - T-Cell 소진 어트랙터 Waddington 경관 재구성

## 한 줄
T-Cell 소진을 다중 안정 어트랙터로 보고, **Unbalanced Schrödinger Bridge** + Flow Matching으로 Waddington 경관을 재구성한다.

## 목표
- Naive → Effector → Progenitor Exhausted (TPEX) → Terminal Exhausted (TEX) 전이를 정량 모델링
- 각 어트랙터의 안정성과 전이 장벽 계산
- TPEX 유지 조건 예측 모델 도출

## 핵심 가설
- 세포 증식·사멸을 명시적으로 모델링하면 불균형 질량 수송 하의 trajectory 학습이 안정적이다.
- iTHEMS와의 비선형 동역학 이론 결합으로 어트랙터의 수학적 정합성을 높일 수 있다.

## 입력 데이터
- [[../10_Concepts/ReapTEC_Enhancer_Atlas|ReapTEC]] enhancer activity (보조 feature)
- Daniel 2022 (PMC11225711) divergent trajectory scRNA-seq
- 프로젝트 보유 DEG 시계열 (L7→L60)
- 10x PBMC Multiome (healthy baseline)

## 방법
- [[../60_Methods/Flow_Matching|Flow Matching]] (TorchCFM)
- [[../60_Methods/Unbalanced_Schrodinger_Bridge|UDSB]] (Pariset 2023)
- Aligned DSB (Somnath 2023)

## 산출물
- Python/R 패키지 (어트랙터 재구성)
- Nature Methods급 논문 1편
- TPEX 유지 조건 예측 모델

## RIKEN 시너지
- iTHEMS 비선형 동역학 팀 (어트랙터 안정성 분석)
- IMS Nomura 팀 (진보 소진 발견 후속)
- BDR (검증 실험 자동화)

## 마일스톤
- [ ] M1-M3 - Daniel 2022 + 프로젝트 DEG AnnData 통합
- [ ] M3-M6 - TorchCFM baseline trajectory 학습
- [ ] M6-M9 - UDSB 도입, TPEX 안정성 정량화
- [ ] M9-M12 - 논문 투고 준비

## 위험
| 위험 | 영향 | 완화 |
| --- | --- | --- |
| UDSB 수렴 불안정 | 큼 | TorchCFM baseline 우선, UDSB는 ablation |
| 세포 증식/사멸 ground truth 부재 | 중 | proliferation marker 기반 proxy |
