---
title: R Manual - 본 프로젝트 초보자 가이드
tags: [tutorial, language/R, beginner, seurat, vscode]
status: living
created: 2026-05-21
---

# R Manual - 본 프로젝트 초보자 가이드

> **목적**: 본 프로젝트(AI-Bio-T-Cell, RIKEN ReapTEC)에서 사용할 R의 핵심만 정리. Python 경험이 있다는 가정 하의 빠른 입문서.
> **환경**: conda env `AI-Bio-T-Cell` 내부의 R 4.3 + Seurat 5, VS Code Remote-SSH.

## 0. R을 왜 쓰는가 (본 프로젝트 한정)

- **Dryad ReapTEC 데이터**가 Seurat `.rds` 형식
- **Seurat / Signac**은 단일 세포 + chromatin 분석의 사실상 표준
- **Bioconductor**(`GenomicRanges`, `rtracklayer`, `SingleCellExperiment`)가 게놈 데이터 처리의 표준
- AI 모델(DNABERT-2, GNN, Flow Matching) 학습은 Python에서, 데이터 전처리는 R에서 → 두 언어 협업

전체 흐름은 [[R_Python_Bridge]] 참조.

## 1. 가장 기본 (15분)

### 1.1 변수와 할당

R에는 `<-`가 관례입니다 (`=`도 작동하지만 함수 인자랑 헷갈리므로 비추천).

```R
x <- 42                  # 숫자
name <- "Sojung"         # 문자열
flag <- TRUE             # 논리값 (T도 가능하지만 비추천)

# Python 비교
# x = 42
```

### 1.2 벡터 (가장 중요)

R의 모든 것은 사실상 벡터입니다. Python의 `list`/`numpy.array`와 비슷.

```R
v <- c(1, 2, 3, 4, 5)     # c() = "combine"
length(v)                  # 5
v[1]                       # 1   ← 1-based indexing! (Python은 0-based)
v[1:3]                     # 1 2 3
v[c(1,3)]                  # 1 3 (특정 위치)
v[v > 2]                   # 3 4 5 (논리 인덱싱)

# 벡터화 연산 (모든 원소에 동시 적용)
v * 2                      # 2 4 6 8 10
v + c(10, 20, 30, 40, 50)  # 11 22 33 44 55

# 시퀀스 생성
seq(1, 10)                 # 1 2 3 ... 10
1:10                       # 1 2 3 ... 10 (동일)
seq(0, 1, by = 0.2)        # 0.0 0.2 0.4 0.6 0.8 1.0
```

| Python | R |
| --- | --- |
| `len(x)` | `length(x)` |
| `x[0]` | `x[1]` ← 1-based! |
| `x[0:3]` | `x[1:3]` |
| `[i*2 for i in x]` | `x * 2` (벡터화) |

### 1.3 데이터 프레임 (Python의 DataFrame과 같음)

```R
df <- data.frame(
  gene   = c("CD3D", "CD8A", "PDCD1"),
  expr   = c(5.2, 3.1, 0.8),
  marker = c(TRUE, TRUE, FALSE)
)
df

# 접근
df$gene                    # 열 추출 (Python의 df['gene'])
df[1, ]                    # 첫 행
df[, "expr"]               # expr 열
df[df$expr > 2, ]          # 필터
nrow(df); ncol(df)         # 행/열 수
colnames(df); rownames(df)
```

### 1.4 list (이종 컨테이너)

Python의 `dict`와 비슷:

```R
result <- list(
  name = "experiment1",
  values = c(1, 2, 3),
  fitted = TRUE,
  model = lm(expr ~ marker, data = df)
)
result$name
result$values
result[["model"]]          # 동일
names(result)              # "name" "values" "fitted" "model"
```

### 1.5 함수 정의

```R
square <- function(x) {
  return(x^2)
}
# 또는 마지막 식이 자동 반환:
square <- function(x) x^2

# 호출
square(5)                  # 25
square(x = 5)              # 동일

# 기본값
add <- function(a, b = 10) a + b
add(3)                     # 13
add(3, b = 5)              # 8
```

### 1.6 제어 흐름

```R
# if-else
if (x > 0) {
  "positive"
} else if (x == 0) {
  "zero"
} else {
  "negative"
}

# for
for (i in 1:5) {
  print(i^2)
}

# 그러나 R에선 보통 벡터화/apply 사용:
sapply(1:5, function(i) i^2)   # c(1, 4, 9, 16, 25)
```

### 1.7 NA, NULL, NaN

- `NA` = 결측치 (missing) — 가장 자주 만남
- `NULL` = 비어있음 (Python의 None)
- `NaN` = Not a Number (0/0 같은 결과)

```R
v <- c(1, NA, 3)
is.na(v)                   # FALSE TRUE FALSE
mean(v)                    # NA (NA 전파!)
mean(v, na.rm = TRUE)      # 2 (NA 제거)
```

→ **R에서 NA 처리는 거의 모든 함수에서 명시적으로 `na.rm = TRUE`** 또는 `na.omit(df)` 필요.

## 2. 자주 쓰는 함수들 (cheat-sheet)

### 데이터 탐색
```R
str(obj)            # 객체 구조 (Python의 type + dir + 일부)
summary(obj)        # 기술통계
head(df, 10)        # 처음 10개
tail(df, 10)        # 마지막 10개
dim(df)             # 차원
class(obj)          # 클래스
object.size(obj)    # 메모리 사용량
```

### 변환
```R
as.numeric(x); as.character(x); as.factor(x); as.matrix(df); as.data.frame(m)
```

### 통계
```R
mean(x); median(x); sd(x); var(x); min(x); max(x); range(x); quantile(x)
cor(x, y); cor(df)              # 상관행렬
t.test(x, y); wilcox.test(x, y)
```

### 입출력
```R
df <- read.csv("file.csv")
write.csv(df, "out.csv", row.names = FALSE)
saveRDS(obj, "model.rds")
obj <- readRDS("model.rds")     # ← 본 프로젝트에서 가장 자주 쓸 명령
```

## 3. tidyverse (현대적 R)

base R도 좋지만 본 프로젝트 환경에 깔린 **tidyverse**가 더 읽기 쉽습니다.

```R
library(tidyverse)         # dplyr, ggplot2, readr, tidyr, ... 한꺼번에

# 파이프 |> (R 4.1+) 또는 %>% (magrittr)
df |>
  filter(expr > 1) |>       # 조건 필터
  mutate(log_expr = log2(expr + 1)) |>  # 새 컬럼
  arrange(desc(expr)) |>    # 정렬
  select(gene, log_expr) |> # 컬럼 선택
  head(5)

# 그룹별 집계
df |>
  group_by(marker) |>
  summarize(mean_expr = mean(expr), n = n())
```

| Python (pandas) | R (dplyr) |
| --- | --- |
| `df[df.expr > 1]` | `df |> filter(expr > 1)` |
| `df.assign(log_e=np.log2(df.expr+1))` | `df |> mutate(log_e = log2(expr+1))` |
| `df.sort_values("expr", ascending=False)` | `df |> arrange(desc(expr))` |
| `df.groupby("marker").mean()` | `df |> group_by(marker) |> summarize_all(mean)` |

## 4. 시각화 (ggplot2)

```R
library(ggplot2)
ggplot(df, aes(x = gene, y = expr, fill = marker)) +
  geom_bar(stat = "identity") +
  labs(title = "Gene expression", y = "log2(expr+1)") +
  theme_minimal()

# Seurat 객체용 - 내장 plot 함수가 더 편함
DimPlot(seurat_obj, group.by = "celltype")
FeaturePlot(seurat_obj, features = c("CD3D", "CD8A"))
VlnPlot(seurat_obj, features = "PDCD1")
```

## 5. S4 객체 = Seurat 객체

Python의 클래스 인스턴스와 비슷하지만 syntax가 다릅니다.

```R
library(Seurat)
obj <- readRDS("datasets/01_reaptec_atlas/processed/seurat_objects/some.rds")

# 객체 구조 보기
class(obj)                  # "Seurat"
slotNames(obj)              # @ 로 접근 가능한 슬롯들
obj@meta.data |> head()     # 셀 메타데이터 (data.frame)
obj@assays                  # assay들 (RNA, ATAC, etc.)

# 더 친숙한 인터페이스 (accessor 함수)
Idents(obj) |> table()                # 현재 cluster 분포
DefaultAssay(obj)                      # 기본 assay
Assays(obj)                            # 모든 assay 이름
Cells(obj) |> length()                 # cell 수
Features(obj) |> length()              # gene 수
GetAssayData(obj, slot = "counts")     # raw counts 매트릭스 (sparse)
GetAssayData(obj, slot = "data")       # log-normalized
```

### Seurat 워크플로우 (간단 버전)

```R
library(Seurat)

# 1) 로드
obj <- readRDS("path/to/seurat.rds")

# 2) (이미 처리됐다면 생략) - 표준 전처리
obj <- NormalizeData(obj)
obj <- FindVariableFeatures(obj, nfeatures = 2000)
obj <- ScaleData(obj)
obj <- RunPCA(obj, npcs = 50)
obj <- FindNeighbors(obj, dims = 1:30)
obj <- FindClusters(obj, resolution = 0.5)
obj <- RunUMAP(obj, dims = 1:30)

# 3) 탐색
DimPlot(obj, group.by = "seurat_clusters", label = TRUE)
DimPlot(obj, group.by = "celltype", label = TRUE)
FeaturePlot(obj, features = c("CD3D", "CD8A", "FOXP3", "PDCD1"))

# 4) Differential expression
markers <- FindAllMarkers(obj, only.pos = TRUE, min.pct = 0.25)
markers |> group_by(cluster) |> top_n(5, avg_log2FC)

# 5) Cell subset
cd8 <- subset(obj, subset = celltype == "CD8 T cell")
```

## 6. 패키지 관리

```R
# 설치 (한 번만)
install.packages("ggplot2")                          # CRAN
BiocManager::install("GenomicRanges")                # Bioconductor
remotes::install_github("mojaveazure/seurat-disk")   # GitHub

# 로드 (스크립트마다)
library(ggplot2)              # 없으면 에러
require(ggplot2)              # 없으면 FALSE 반환 (덜 사용)

# 버전 확인
packageVersion("Seurat")
sessionInfo()                  # 환경 전체 정보 (논문에 첨부할 때 유용)
```

## 7. VS Code R extension 사용법

이미 [[../30_Daily/2026-05-22]] 에서 다뤘지만 핵심만 다시:

| 작업 | 단축키 |
| --- | --- |
| 콘솔 시작 | `Ctrl+Shift+P` → "R: Create R Terminal" |
| **한 줄 실행** | **`Ctrl+Enter`** (90% 사용) |
| 전체 파일 실행 | `Ctrl+Shift+Enter` |
| `<-` 자동 삽입 | `Alt+-` |
| `%>%` 자동 삽입 | `Ctrl+Shift+M` |
| 함수 도움말 | 커서 위치 후 `F1` |
| Workspace 보기 | `Ctrl+Shift+P` → "R: Show Workspace Viewer" |
| 플롯 패널 | 자동 (httpgd) |

## 8. 본 프로젝트의 R 파일 구조

```
src/R/R/                          # 재사용 가능한 함수 (라이브러리)
├── seurat_helpers.R              # preprocess_seurat, subset_t_cells
├── signac_helpers.R              # preprocess_signac (ATAC-seq)
└── enhancer_analysis.R           # overlap_snps_with_enhancers (GenomicRanges)

src/R/scripts/                    # 일회성 분석 스크립트
└── 01_load_reaptec.R             # ReapTEC processed atlas 로딩

datasets/01_reaptec_atlas/scripts/
├── rds_to_h5ad.R                 # Seurat -> AnnData 변환
└── install_r_bridge.R            # sceasy/SeuratDisk 설치

notebooks/R/                      # 탐색용 Rmd
└── 01_seurat_exhaustion.Rmd
```

### 사용 예

```R
# 프로젝트 함수 로드 (어디서든)
source("src/R/R/seurat_helpers.R")
source("src/R/R/enhancer_analysis.R")

# 또는 here::here()로 안전한 경로
library(here)
source(here("src", "R", "R", "seurat_helpers.R"))

# 함수 사용
obj <- readRDS(here("datasets/01_reaptec_atlas/processed/seurat_objects/foo.rds"))
obj <- preprocess_seurat(obj, min_features = 500, max_mt_pct = 15)
DimPlot(obj)
```

## 9. R ↔ Python 브릿지 (필요할 때만)

```R
library(reticulate)
# 같은 conda env의 Python 사용
use_condaenv("AI-Bio-T-Cell", required = TRUE)

# Python 모듈 import (R 안에서)
sc <- import("scanpy")
ad <- import("anndata")

# AnnData 객체 만들기 from R data
adata <- ad$AnnData(X = as.matrix(GetAssayData(obj, slot = "counts")))
adata$write_h5ad("out.h5ad")

# 또는 sceasy로 한 줄 변환
sceasy::convertFormat(obj, from = "seurat", to = "anndata",
                      outFile = "out.h5ad", main_layer = "counts")
```

자세한 건 [[R_Python_Bridge]] 참조.

## 10. 자주 막히는 점 (FAQ)

| 증상 | 원인 / 해결 |
| --- | --- |
| `Error in library(X) : there is no package called 'X'` | 설치 안 됨. `install.packages("X")` |
| `Error in eval(predvars, data, env) : ...` | data.frame 컬럼 이름 오타 (대소문자 주의) |
| 함수가 작동 안 함 | 같은 이름의 함수가 여러 패키지에 있음. `dplyr::filter()`처럼 명시 |
| `Error: vector memory exhausted (limit reached?)` | RAM 부족. .rds 너무 큼. subset으로 분할 |
| Plot이 안 보임 | `httpgd::hgd()` 호출 또는 VS Code의 `r.plot.useHttpgd: true` |
| 한글 깨짐 | `Sys.setlocale("LC_ALL", "ko_KR.UTF-8")` |
| `<-` 와 `=` 차이? | 할당엔 `<-` (관례), 함수 인자엔 `=` (`f(x = 5)`) |
| 1-based vs 0-based 헷갈림 | R은 무조건 1부터. `v[1]`이 첫 원소. |
| `df$column` vs `df[["column"]]` | 거의 동일. `df[["column_var"]]`처럼 변수로 컬럼명 지정할 때만 `[[]]` 필수 |
| reticulate가 `activate: No such file ... CondaError` 출력 | **cosmetic 경고** — 무시 가능. 자세한 내용은 §13 참조 |

## 11. 본 프로젝트에서 가장 자주 쓸 패턴

### A. Seurat .rds 빠른 탐색
```R
obj <- readRDS("datasets/01_reaptec_atlas/processed/seurat_objects/foo.rds")
print(obj)                           # 한 줄 요약
head(obj@meta.data)
table(obj$celltype)                  # 셀 타입 분포
DimPlot(obj, group.by = "celltype")
```

### B. 특정 셀 서브셋
```R
cd8 <- subset(obj, subset = celltype == "CD8 T cell")
exhausted <- subset(obj, subset = exhaustion_score > 0.5)
```

### C. 마커 유전자 발현 비교
```R
VlnPlot(obj, features = c("TCF7", "PDCD1", "TOX", "HAVCR2"),
        group.by = "celltype", ncol = 2)
```

### D. enhancer-SNP overlap (본 프로젝트 핵심)
```R
source("src/R/R/enhancer_analysis.R")
enhancers <- rtracklayer::import("datasets/01_reaptec_atlas/processed/bed/btc_enhancers.bed")
snps <- read.csv("datasets/16_gwas_catalog_immune/raw/associations.tsv", sep = "\t")
overlaps <- overlap_snps_with_enhancers(enhancers, snps)
table(overlaps$trait)
```

### E. Seurat → AnnData (한 번만)
```bash
Rscript datasets/01_reaptec_atlas/scripts/rds_to_h5ad.R --max_size_gb 4
```

## 12. 학습 경로 추천

본 프로젝트 진행에 필요한 순서:

1. **Today (30분)**: 본 노트의 §1~3 (기본 문법 + tidyverse)
2. **Week 1 (1시간)**: §5 (Seurat 객체 다루기), 실제 .rds 로딩
3. **Week 2 (1시간)**: §6 (시각화), §11 (프로젝트 패턴)
4. **이후**: 필요할 때 §9 (R-Python bridge)

추가 자료:
- [R for Data Science (Hadley Wickham, 무료)](https://r4ds.hadley.nz/) — tidyverse 표준 교과서
- [Seurat tutorial (PBMC)](https://satijalab.org/seurat/articles/pbmc3k_tutorial.html) — Seurat 공식 입문
- [Bioconductor OSCA 책](https://bioconductor.org/books/release/OSCA/) — single-cell 표준
- [Advanced R (Hadley)](https://adv-r.hadley.nz/) — 깊이 있는 R 이해

## 13. reticulate cosmetic 경고 (Miniforge env 사용 시)

본 프로젝트 conda env에서 `reticulate::import()` 또는 `py_config()` 호출 시 다음 출력이 항상 나타납니다:

```
/tmp/Rtmpxxxxxx/fileXXXX.sh: line 1: /home/lucia/miniforge3/envs/AI-Bio-T-Cell/bin/activate: No such file or directory
CondaError: Run 'conda init' before 'conda activate'
Warning messages:
1: In normalizePath(file.path(dirname(conda), "activate")) :
  path[1]=".../bin/activate": No such file or directory
```

### 결론: 무시하세요. 실제 작동에 0% 영향.

마지막에 `anndata 0.x.x scanpy 1.x.x all OK` 같은 정상 출력이 나오면 모든 것이 정상입니다.

### 왜 발생하나

1. `reticulate::import()`가 내부에서 conda env "친절한 활성화"를 시도
2. **Anaconda 배포에는** `<env>/bin/activate` 스크립트가 존재 → 정상
3. **Miniforge에서는** activate가 `~/miniforge3/bin/activate` 단 한 곳에만 있음 → 위 경로에 파일 없음 → bash가 stderr에 "No such file" 출력
4. `RETICULATE_PYTHON`이 이미 설정되어 있어 실제 Python 바인딩은 정상 → 작업 진행

→ 이건 R warning이 아니라 **bash가 직접 출력하는 stderr** 이므로 R의 `suppressWarnings()`로 막을 수 없습니다.

### 영향 없는 작업들

| 작업 | 영향 |
| --- | --- |
| `library(Seurat)`, Seurat 객체 조작 | ❌ (reticulate 안 씀) |
| `sceasy::convertFormat()` (`.rds → .h5ad`) | ❌ 정상 동작 |
| `reticulate::import()` 자체 | ❌ 마지막에 `OK` 나오면 성공 |
| Python 측 `import scanpy, anndata` | ❌ |
| DNABERT-2 임베딩, GNN 학습 | ❌ (R 안 씀) |

### 깨끗하게 보고 싶으면 — `scripts/r_quiet.sh` 래퍼

본 프로젝트에 포함된 래퍼로 cosmetic 출력만 필터링합니다 (진짜 에러는 그대로 통과):

```bash
# 일반 Rscript 대신
bash scripts/r_quiet.sh -e '
suppressMessages(library(reticulate))
ad <- import("anndata")
cat("anndata:", ad$`__version__`, "OK\n")
'
```

자세한 사용법은 `scripts/README.md` 참조.

### 협업자에게 알릴 점

새 협업자가 처음 봤을 때 놀랄 수 있으므로:
- 이 노트(§13)의 링크를 공유
- 또는 `bash scripts/r_quiet.sh` 사용 권장
- 또는 R Manual의 12단계 학습 코스 따라가면서 자연스럽게 익숙해짐

## 관련 노트
- [[R_Python_Bridge]] — R↔Python 변환 표준
- [[DNABERT2_Embedding]] — Python 측 작업 (인핸서 임베딩)
- [[GNN_Enhancer_Network]] — Python 측 작업 (그래프 학습)
- [[ReapTEC_Pipeline]] — 데이터 출처
- `src/R/R/seurat_helpers.R` — 본 프로젝트 R 헬퍼 함수
- `scripts/r_quiet.sh` — reticulate cosmetic 경고 필터링 래퍼

## 한 줄 요약

> R은 **벡터·data.frame·S4 객체**가 핵심이고, 본 프로젝트에서 가장 자주 쓸 명령은 `readRDS()`로 Seurat 객체 로드 → `DimPlot()`/`VlnPlot()`/`subset()` 으로 탐색 → `sceasy::convertFormat()`로 AnnData 변환 — 이 흐름입니다. 그 외 모든 것은 필요할 때 검색·LLM에 물어보면서 익히면 충분합니다.
