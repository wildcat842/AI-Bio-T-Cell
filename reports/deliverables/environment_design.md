# Research Environment Design - AI-Bio-T-Cell

**작성일**: 2026-05-19
**대상 연구**: RIKEN ReapTEC atlas 기반 T-Cell 면역 연구 (토픽 1+4 우선)
**핵심 도전**:
1. **R 중심 데이터 (Seurat .rds, 22 GB)** ↔ **Python 중심 ML (DNABERT-2, GNN, Flow Matching)** 통합
2. 62,803개 enhancer의 DNA 서열 임베딩 + 조절 네트워크 그래프 학습
3. 재현 가능한 의존성 관리 (4-5명 협업, conda + renv)

## 1. 결론 - 권장 스택 한 페이지

| Layer | Stack | 비고 |
| --- | --- | --- |
| OS | Ubuntu 22.04 LTS (또는 24.04) | RIKEN/대학 컴퓨팅 표준 |
| GPU runtime | NVIDIA driver 550+ / CUDA 12.4 / cuDNN 9 | PyTorch 2.4 호환 |
| Python | **3.12.12** (현재 환경) | `pyproject.toml`의 `requires-python=">=3.10,<3.13"` |
| Python env mgr | **conda (mamba)** + `pyproject.toml` editable install | environment.yml에 명시됨 |
| R | **4.3+** (system or conda-forge) | Bioconductor 3.18 호환 |
| R env mgr | **renv** | `renv.lock`으로 재현성 |
| **R↔Python bridge** | **sceasy** + **anndata2ri** + **reticulate** / **rpy2** | 양방향 변환 |
| 단일 세포 (Python) | scanpy 1.10+, anndata 0.10+, mudata | AnnData가 lingua franca |
| 단일 세포 (R) | Seurat 5+, Signac 1.13+, SingleCellExperiment | Dryad .rds 호환 |
| 게놈 region | GenomicRanges (R), pyranges/bedtools (Py) | enhancer-SNP overlap |
| **DNA LM** | **DNABERT-2** (HuggingFace) ± Nucleotide Transformer | enhancer sequence embedding |
| **GNN** | **PyTorch Geometric (PyG) 2.5+** + DGL 보조 | enhancer-gene-TF graph |
| Generative | torchcfm (Flow Matching), diffusers (Diffusion) | 토픽 1 trajectory, 토픽 4 perturbation |
| Training | PyTorch Lightning 2.4+ | 멀티 GPU + WandB |
| Storage | NVMe SSD ≥ 500 GB (raw) + 1 TB (working) | Dryad 22 GB unzip 후 ~30-40 GB |
| Note | Obsidian vault for shared notes (`obsidian/`) | 협업자 공유용 |

## 2. R ↔ Python 브릿지 - 가장 중요한 결정

Dryad의 ReapTEC 데이터는 **Seurat .rds** 형태입니다. 본 프로젝트의 ML 코드 대부분은 Python(PyTorch)이므로, 데이터를 **AnnData (.h5ad)** 로 1회 변환한 뒤 양쪽 모두에서 사용하는 전략을 권장합니다.

### 2.1 권장 패키지 매트릭스

| 도구 | 언어 | 역할 | 추천 점수 |
| --- | --- | --- | --- |
| **sceasy** | R | `convertFormat(seurat → anndata)` 한 줄 변환 | **★★★ (1순위)** |
| **SeuratDisk** | R | SaveH5Seurat → Convert(h5ad) (대용량 안정) | **★★★** (sceasy 실패 시 폴백) |
| **anndata2ri** | Python | R SingleCellExperiment → Python AnnData (rpy2 기반) | ★★☆ |
| **reticulate** | R | R에서 Python 함수 호출 (sceasy 의존) | ★★★ |
| **rpy2** | Python | Python에서 R 함수 호출 (드물게 사용) | ★☆☆ |
| **mudata** | Python | 멀티 모달 컨테이너 (RNA + ATAC + enhancer) | **★★★** (토픽 4에서 핵심) |

### 2.2 데이터 흐름 다이어그램

```
Dryad
  └── DataS2_Single_cell_rds_files.zip (22 GB)
        │
        │ unzip
        ▼
  processed/seurat_objects/*.rds   ← R에서 직접 읽기 (Seurat / Signac)
        │
        │ rds_to_h5ad.R (sceasy)
        ▼
  processed/h5ad/*.h5ad            ← Python에서 직접 읽기 (scanpy / mudata)
        │
        ├── PyG dataset wrapper  → GNN 학습 (토픽 4)
        ├── torchcfm dataset      → Flow Matching (토픽 1)
        └── DNABERT-2 tokenizer + (DataS4 BED → genome FASTA → sequence)  → enhancer embedding
```

### 2.3 설치 명령 (`scripts/setup_linux_remote.sh` 또는 수동)

**Python (활성 conda env `AI-Bio-T-Cell`)**:
```bash
pip install -e ".[dev,ml,bridge]"   # bridge = anndata2ri, rpy2 추가 (아래 pyproject.toml 패치)
# DNABERT-2 (HuggingFace에서 가중치만 다운로드)
pip install transformers triton einops
# PyTorch Geometric (CUDA 12.x 휠 인덱스)
pip install torch_geometric
pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv \
    -f https://data.pyg.org/whl/torch-2.4.0+cu124.html
```

**R (renv 기반)**:
```r
# 본 프로젝트의 renv.lock이 이미 Seurat/Signac/Bioc 패키지를 포함
renv::restore()

# 브릿지 패키지 추가
install.packages("reticulate")
remotes::install_github("cellgeni/sceasy")
remotes::install_github("mojaveazure/seurat-disk")    # SeuratDisk
BiocManager::install("zellkonverter")                  # SCE ↔ AnnData (대안)

renv::snapshot()  # renv.lock 갱신
```

## 3. DNABERT-2 셋업 (enhancer sequence embedding)

DNABERT (v1, k-mer)는 2021년 발표 이후 DNABERT-2 (2024, BPE tokenizer)로 진화했습니다. 본 프로젝트에서는 **DNABERT-2**를 1순위로, **Nucleotide Transformer**(InstaDeep/Meta)를 대안으로 사용합니다.

### 3.1 모델 옵션

| 모델 | 파라미터 | 컨텍스트 | HuggingFace ID | 추천 용도 |
| --- | --- | --- | --- | --- |
| DNABERT-2-117M | 117M | 변수(BPE) | `zhihan1996/DNABERT-2-117M` | **인핸서 sequence embedding (기본)** |
| Nucleotide Transformer (500M / 2.5B) | 500M~2.5B | 6 kb | `InstaDeepAI/nucleotide-transformer-500m-1000g` | 더 큰 컨텍스트 필요 시 |
| HyenaDNA | 6.6M~7M | 1 Mb (long) | `LongSafari/hyenadna-large-1m-seqlen-hf` | 토픽3 (TAD scale) |
| Caduceus | 4-8M | 131 kb | `kuleshov-group/caduceus-ps_seqlen-131k-d_model-256` | bidirectional/RC equivariant 실험 |

### 3.2 인핸서 sequence 추출 파이프라인

```python
# 1) DataS4 BED 좌표 + hg38 FASTA → sequence
import pyfaidx, pandas as pd
genome = pyfaidx.Fasta("data/external/hg38.fa")
enh = pd.read_csv("datasets/01_reaptec_atlas/processed/bed/btc_enhancers.bed", sep="\t",
                  names=["chr","start","end","name","score","strand"])
def extract(row):
    s = str(genome[row.chr][row.start:row.end])
    return s if row.strand == "+" else str(genome[row.chr][row.start:row.end].reverse.complement)
enh["seq"] = enh.apply(extract, axis=1)

# 2) DNABERT-2 임베딩
from transformers import AutoTokenizer, AutoModel
import torch
tok = AutoTokenizer.from_pretrained("zhihan1996/DNABERT-2-117M", trust_remote_code=True)
mdl = AutoModel.from_pretrained("zhihan1996/DNABERT-2-117M", trust_remote_code=True).cuda().eval()
def embed(seqs, batch=16):
    out = []
    for i in range(0, len(seqs), batch):
        ids = tok(seqs[i:i+batch], return_tensors="pt", padding=True, truncation=True, max_length=512).to("cuda")
        with torch.no_grad():
            h = mdl(**ids).last_hidden_state.mean(dim=1)  # mean-pool
        out.append(h.cpu().float().numpy())
    return np.vstack(out)
embeddings = embed(enh["seq"].tolist())  # (62803, 768)
```

권장 GPU: **24 GB VRAM** (RTX 4090 / A5000) 이상. 62K enhancer 임베딩은 1~3시간 소요.

## 4. GNN 셋업 (인핸서 조절 네트워크)

### 4.1 그래프 스키마 (heterogeneous)

```
Nodes:
  enhancer (62,803)  features = [DNABERT-2 embed (768), chromatin marks (10-50), expr (136)]
  gene     (~25,000) features = [expr (136), GO embeddings (32), ...]
  TF       (~1,500)  features = [JASPAR motif PWM-derived (32), expr]

Edges:
  enhancer ─PROXIMITY─> gene       (BED proximity, ABC model score, Micro-C contact)
  enhancer ─BINDING──> TF          (ENCODE ChIP-seq overlap)
  gene     ─COEXP────> gene        (Spearman / WGCNA module)
  TF       ─REGULATES─> gene       (TF→target consensus)
```

### 4.2 코드 스켈레톤

```python
import torch
from torch_geometric.data import HeteroData
from torch_geometric.nn import HeteroConv, GATConv

data = HeteroData()
data["enhancer"].x = torch.from_numpy(enhancer_features).float()
data["gene"].x = torch.from_numpy(gene_features).float()
data["tf"].x = torch.from_numpy(tf_features).float()
data["enhancer", "regulates", "gene"].edge_index = torch.from_numpy(eg_edges).long()
data["enhancer", "regulates", "gene"].edge_attr  = torch.from_numpy(eg_abc_scores).float()
# ... 다른 edge types

class HeteroGAT(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.conv = HeteroConv({
            ("enhancer","regulates","gene"): GATConv((-1,-1), 128, add_self_loops=False),
            ("enhancer","bound_by","tf"):     GATConv((-1,-1), 128, add_self_loops=False),
            ("tf","regulates","gene"):        GATConv((-1,-1), 128, add_self_loops=False),
        }, aggr="sum")
        # ...
```

## 5. 하드웨어 권장 (62K enhancer + 22 GB rds 가정)

### 5.1 단일 워크스테이션 (1인 연구 단계)
- CPU: AMD Ryzen 9 7950X / Intel i9-14900K (16 core+)
- RAM: **128 GB DDR5** (Seurat .rds 전체 메모리 적재 + headroom)
- GPU: **RTX 4090 24 GB** (DNABERT-2 fine-tune + GNN 학습)
- SSD: 2 TB NVMe (raw + processed + checkpoint)
- 보조: 4 TB HDD (Dryad 백업, Micro-C 데이터)

### 5.2 서버 / 클러스터 (협업·확장 단계)
- 8x A100 40 GB 또는 4x H100 80 GB (DDP 학습)
- 1 TB RAM (Seurat 전체 한 번에 + 다중 사용자)
- 10 TB NVMe RAID (raw zone) + 별도 객체 스토리지 (results)
- InfiniBand HDR (멀티노드)

### 5.3 RIKEN Fugaku (토픽 2 활성화 시)
- ARM A64FX → PyTorch 1.x branch + ARM 호환 빌드 필요
- 대규모 grid search / hyperparameter sweep용
- 토픽 2 (TCR foundation model)에서 검토

### 5.4 최소 가능 설정 (학생/검증)
- RTX 3060 12 GB + 32 GB RAM → DNABERT-2 inference (학습 불가)
- subset별로 .rds를 잘라서 변환·분석 (`rds_to_h5ad.R --max_size_gb 4`)

## 6. 재현성·협업 체크리스트

- [x] `pyproject.toml` - Python 의존성 명시 (3.12 타겟)
- [x] `environment.yml` - conda env 재현
- [x] `DESCRIPTION` + `renv.lock` - R 의존성 재현
- [ ] **추가 권장**: `bridge` 옵션 그룹 (anndata2ri, rpy2) → 본 보고서 §7
- [ ] **추가 권장**: `Dockerfile` (선택, 클러스터 배포 시) → 향후 작업
- [ ] **추가 권장**: `Snakefile` 또는 `nextflow.config` (데이터 → 모델 파이프라인) → 향후 작업
- [x] Obsidian vault - 공동 노트
- [x] GitHub Actions CI - Python (ruff+pytest) + R (testthat)
- [x] Git LFS 설정 (`.gitattributes`)
- [x] `.gitignore` - 대용량 데이터 제외

## 7. 권장 `pyproject.toml` / `DESCRIPTION` 추가 항목

### 7.1 pyproject.toml (`[project.optional-dependencies]`에 `bridge` 그룹 추가)

```toml
bridge = [
  "anndata2ri>=1.3",     # R SCE -> Python AnnData
  "rpy2>=3.5",            # Python에서 R 호출 (드물게)
  "pyfaidx>=0.7",         # FASTA random access (enhancer seq 추출)
  "pyranges>=0.0.129",    # BED/GTF arithmetic (R GenomicRanges와 페어)
  "pybigwig>=0.3",        # bigWig signal extraction
]
genome = [
  "biopython>=1.83",
  "pysam>=0.22",
  "intervaltree>=3.1",
]
```

### 7.2 DESCRIPTION (R)
```
Imports:
    Seurat (>= 5.0),
    Signac (>= 1.13),
    SeuratDisk,
    sceasy,
    reticulate (>= 1.30),
    zellkonverter,
    GenomicRanges,
    rtracklayer,
    SingleCellExperiment
```

### 7.3 ML 옵션 그룹 확장 (DNABERT-2)
```toml
ml = [
  "torch>=2.4",
  "torchvision>=0.19",
  "torch-geometric>=2.5",
  "transformers>=4.44",
  "tokenizers>=0.20",
  "triton>=3.0",            # DNABERT-2 흐름
  "einops>=0.8",
  "torchcfm>=1.0",
  "lightning>=2.4",
  "wandb>=0.18",
  "diffusers>=0.30",         # Topic 4 perturbation
]
```

## 8. 다음 4주 액션 플랜

| Week | 액션 | 검증 |
| --- | --- | --- |
| W1 | `download_dryad.sh --tier p0` (22 GB) + `verify_checksums.sh` | 5개 파일 모두 정상 unzip |
| W1 | `unzip_and_organize.sh` | seurat_objects/, bed/, abc/ 생성 |
| W2 | R 환경 셋업 (sceasy/SeuratDisk 설치) | `rds_to_h5ad.R --max_size_gb 4` 작동 |
| W2 | Python 환경에 `bridge`, `genome` 그룹 설치 | `python verify_h5ad.py` 통과 |
| W3 | DNABERT-2 임베딩 prototype (1000개 enhancer) | (62803, 768) numpy 저장 |
| W3 | PyG HeteroData 그래프 prototype | 작은 subset에서 GAT 학습 1 epoch |
| W4 | Obsidian 노트 갱신 + iTHEMS 첫 미팅 자료 준비 | obsidian/40_Meetings/2026-... |

## 9. 위험·이슈

| 이슈 | 영향 | 완화 |
| --- | --- | --- |
| `.rds` Seurat 객체가 Seurat 4 형식인 경우 | 중 | Seurat 5에서 `UpdateSeuratObject()` 호출 |
| 22 GB unzip 시 디스크 부족 | 중 | unzip 전 `df -h`, 별도 작업 디렉토리 |
| sceasy/SeuratDisk가 conda env Python을 못 찾음 | 높음 | `reticulate::use_python(...)` 명시, R에서 `Sys.setenv(RETICULATE_PYTHON=...)` |
| Micro-C 데이터(~115 GB)까지 받으면 디스크 부족 | 큼 | P2까지만 우선, 필요시 외부 스토리지 |
| DNABERT-2 GPU 메모리 부족 | 중 | gradient accumulation, fp16, batch_size 4 |
| Seurat 객체 cell type label이 자유 텍스트 | 중 | Cell Ontology 매핑 테이블 작성 (metadata/cell_ontology_map.tsv) |

## 10. 참고

- **Dryad page**: https://datadryad.org/dataset/doi:10.5061/dryad.pk0p2ngwx
- **ReapTEC pipeline**: https://github.com/MurakawaLab/ReapTEC
- **DNABERT-2**: https://huggingface.co/zhihan1996/DNABERT-2-117M
- **PyG**: https://pytorch-geometric.readthedocs.io/
- **sceasy**: https://github.com/cellgeni/sceasy
- **SeuratDisk**: https://github.com/mojaveazure/seurat-disk
- **Project notes**: `obsidian/10_Concepts/ReapTEC_Enhancer_Atlas.md`, `obsidian/60_Methods/`
