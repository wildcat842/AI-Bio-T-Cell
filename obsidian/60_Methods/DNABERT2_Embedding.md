---
title: DNABERT-2 Enhancer Embedding
tags: [method, model/DNABERT-2, topic/4]
status: planning
---

# DNABERT-2 Enhancer Embedding

## 한 줄
RIKEN ReapTEC의 **62,803개 bidirectional enhancer** 좌표 → hg38 reference → **DNABERT-2 (BPE, 117M)**로 sequence embedding → GNN feature.

## 모델 선택 사유
| 모델 | 컨텍스트 | 본 프로젝트 적합도 |
| --- | --- | --- |
| **DNABERT-2-117M** | BPE, 변수 길이 | **★★★** (인핸서 평균 ~300 bp에 적합) |
| Nucleotide Transformer 500M | 6 kb | ★★☆ (더 큰 컨텍스트 필요 시) |
| HyenaDNA 1m | 1 Mb | ★☆☆ (TAD-scale, 토픽 3 후보) |
| Caduceus | 131 kb | ★★☆ (bidirectional 인핸서에 이론적 적합) |

→ **DNABERT-2 1순위**, Nucleotide Transformer 2순위 (앙상블 시 보강)

## 파이프라인 (의사 코드)

```python
# 1. BED 좌표 + hg38 FASTA -> sequence
genome = pyfaidx.Fasta("data/external/hg38.fa")
seqs = [str(genome[chr][start:end]) for chr, start, end in btc_enhancers_bed]

# 2. DNABERT-2 tokenize + embed
tok = AutoTokenizer.from_pretrained("zhihan1996/DNABERT-2-117M", trust_remote_code=True)
mdl = AutoModel.from_pretrained("zhihan1996/DNABERT-2-117M", trust_remote_code=True).cuda().eval()
embeddings = batch_embed(seqs, batch_size=16)  # (62803, 768) - mean pooled

# 3. Save for GNN consumption
np.save("data/processed/enhancer_dnabert2_embed.npy", embeddings)
```

## 자원
- GPU: 24 GB VRAM 권장 (RTX 4090 / A5000)
- 시간: 62K 인핸서 inference ~1-3시간
- 저장: 62803 × 768 × 4B ≈ 193 MB (fp32) / 96 MB (fp16)

## 후속
- HeteroData의 `data["enhancer"].x`로 직접 투입
- 다른 features (chromatin marks, expression)와 concat
- (선택) DNABERT-2 fine-tune (T-cell enhancer specific) — 24 GB로는 LoRA 또는 작은 batch만

## 관련
- [[../20_Topics/Topic4_Enhancer_Regulatory_Network]]
- [[../50_Literature/Oguchi2024_ReapTEC]]
- `reports/deliverables/environment_design.md` §3
