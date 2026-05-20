---
title: GNN Enhancer Regulatory Network
tags: [method, model/GNN, topic/4]
status: planning
---

# GNN for Enhancer Regulatory Network

## 한 줄
**PyTorch Geometric (PyG)**의 HeteroData로 enhancer-gene-TF 이질 그래프를 만들고, GATConv/HGT 등 attention 기반 메시지 패싱으로 인핸서가 어떤 유전자를 조절하는지 학습.

## 그래프 스키마

```
Nodes:
  enhancer (62,803)   - features: DNABERT-2 (768) + expression (136) + chromatin (10-50)
  gene     (~25,000)  - features: expression (136) + GO (32) + protein embed (선택)
  TF       (~1,500)   - features: JASPAR motif (32) + expression (136)

Edges (typed):
  enhancer --proximity--> gene     [score: distance, ABC, Micro-C contact]
  enhancer --bound_by---> TF        [score: ChIP-seq overlap depth]
  gene     --coexpressed_with--> gene  [score: Spearman]
  TF       --regulates--> gene      [score: TF-target consensus]
```

## 모델 후보
| 모델 | 적합도 | 비고 |
| --- | --- | --- |
| HeteroConv + GATConv | ★★★ | 베이스라인 |
| HGT (Heterogeneous Graph Transformer) | ★★★ | 이질 그래프 SOTA 중 하나 |
| RGCN | ★★☆ | 보수적, 안정적 |
| Graphormer-like | ★★☆ | global attention, 큰 메모리 필요 |

## 학습 목표
1. **Edge prediction**: 새로운 enhancer-gene edge가 진짜인가?
2. **Node regression**: enhancer activity → target gene expression 예측
3. **Perturbation prediction (Diffusion)**: enhancer를 KO하면 transcriptome이 어떻게 변하나?

## PyG 셋업 (CUDA 12.x)

```bash
pip install torch_geometric
pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv \
  -f https://data.pyg.org/whl/torch-2.4.0+cu124.html
```

## 관련
- [[../20_Topics/Topic4_Enhancer_Regulatory_Network]]
- [[DNABERT2_Embedding]]
- `reports/deliverables/environment_design.md` §4
