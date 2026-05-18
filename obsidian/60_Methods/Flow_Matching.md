---
title: Flow Matching
tags: [method, generative-model]
---

# Flow Matching

## 한 줄
연속 정규화 흐름(CNF)의 simulation-free 학습 방법. 두 분포 사이의 시간-의존 벡터장을 학습한다.

## 핵심
- Conditional Flow Matching (Lipman 2023, Tong 2024)
- Minibatch Optimal Transport coupling이 학습 효율을 크게 개선
- Diffusion model 대비 sampling 속도 빠름

## 본 프로젝트 활용
- 토픽 1: T-cell 상태 전이 (Naive → Effector → TPEX → TEX) trajectory 학습

## 도구
- `torchcfm` (Tong 2024)
- `flow_matching` (Meta, 2024)

## 참고
- Lipman et al. 2023 "Flow Matching for Generative Modeling" ICLR
- Tong et al. 2024 "Improving and Generalizing Flow-Based Generative Models" TMLR
