---
title: R 패키지 관리 - 의존성 지옥 탈출
tags: [technote, R, package-management, conda, bioconductor, renv]
status: living
created: 2026-05-25
---

# R 패키지 관리 — 의존성 지옥 탈출

> 본 프로젝트처럼 **conda env + Seurat + Bioconductor + GitHub-only 패키지**가 섞이면 `install.packages()` 한 줄로는 자주 실패. 이 노트는 어떤 경로로 어떤 패키지를 깔아야 가장 적게 깨지는지를 정리.

## 0. 핵심 결정 트리 (이것만 봐도 됨)

```
패키지가 필요할 때 — 어디서 받아야 하나?

  │
  ├─ conda-forge에 있나? ──── 예 ──→ ① mamba install -c conda-forge r-<name>
  │  (https://anaconda.org/conda-forge/repo 검색)
  │
  ├─ Bioconductor에 있나? ──── 예 ──→ ② BiocManager::install("<name>")
  │  (Seurat 이외 single-cell, GenomicRanges 등)        또는
  │                                  ③ mamba install -c bioconda bioconductor-<name>
  │
  ├─ CRAN에만 있나? ─────────── 예 ──→ ④ install.packages("<name>")
  │  (예전 install.packages 한 줄)
  │
  └─ GitHub에만 있나? ──────── 예 ──→ ⑤ remotes::install_github("user/repo")
     (sceasy, SeuratDisk 등)
```

→ **항상 ① 먼저 시도, 안 되면 ②, ③, ④, ⑤ 순으로 내려갑니다.**

## 1. 왜 `install.packages()` 만으로는 부족한가

기존 방식:
```r
install.packages("ggplot2")
```

문제점:
- CRAN만 검색 (Bioconductor·GitHub 패키지 못 받음)
- **source에서 컴파일** → 시스템 라이브러리(`-llzma`, `-licu` 등) 없으면 실패
- 모든 의존성도 source로 빌드 → 빌드 시간 매우 김 (1-30분)
- 컴파일 실패 시 사용자가 시스템 패키지 설치해야 하지만 sudo 없으면 불가

대표적 실패 예시 (본 프로젝트에서 실제 본 것):
```
ld: cannot find -llzma: No such file or directory
collect2: error: ld returned 1 exit status
ERROR: compilation failed for package 'rpy2-rinterface'
```

→ **conda-forge는 미리 빌드된 바이너리**라 즉시 설치 + 시스템 lib도 같이 끌어옴.

## 2. 우선순위 ① — conda-forge (R 패키지 절대 다수)

### 검색
```bash
# 패키지 이름 확인
mamba search -c conda-forge "r-seurat" 2>&1 | head -10
# 또는 웹: https://anaconda.org/conda-forge/r-seurat
```

### 설치
```bash
# 항상 env 활성화 먼저
conda activate AI-Bio-T-Cell

# 하나
mamba install -c conda-forge r-ggplot2 -y

# 여러 개 (한 번에 묶어서 solver가 일관성 보장)
mamba install -c conda-forge r-ggplot2 r-dplyr r-tidyr -y
```

### conda-forge 명명 규칙
| R 패키지 | conda-forge 이름 |
| --- | --- |
| `ggplot2` | `r-ggplot2` |
| `Seurat` | `r-seurat` (소문자!) |
| `dplyr` | `r-dplyr` |
| `Signac` | `r-signac` |
| `tidyverse` | `r-tidyverse` |
| `data.table` | `r-data.table` |
| `reticulate` | `r-reticulate` |

→ **항상 `r-` 접두사 + 소문자.**

### 환경 재현성 — environment.yml에 명시
새로 깐 패키지가 있으면 다음 setup 때 자동 적용되도록:
```yaml
dependencies:
  - r-ggplot2
  - r-dplyr
  # ...
```

## 3. 우선순위 ② — BiocManager (Bioconductor 패키지)

Bioconductor의 single-cell / 게놈 분석 패키지. 본 프로젝트에선 `GenomicRanges`, `rtracklayer`, `SingleCellExperiment` 등.

### 두 가지 경로 — bioconda vs BiocManager

**경로 A (권장)** — bioconda 채널 (conda 통합, 빠름):
```bash
conda activate AI-Bio-T-Cell
mamba install -c bioconda bioconductor-genomicranges -y
```

명명 규칙: `bioconductor-<lowercase>`.

**경로 B** — R에서 BiocManager (필요 시):
```r
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("GenomicRanges")
```

### Bioconductor 버전 — R 버전과 묶임
- R 4.3 → Bioconductor 3.18
- R 4.4 → Bioconductor 3.19
- 잘못 매치하면 의존성 해결 안 됨

→ conda env에서 R 4.3을 쓰면 bioconda의 bioconductor-* 도 자동으로 3.18 버전을 잡습니다.

## 4. 우선순위 ③ — install.packages (CRAN 전용 패키지)

conda-forge에 없고 Bioconductor에도 없는 패키지만:

```r
install.packages("aRomatic", repos = "https://cloud.r-project.org")
```

주의:
- **`repos =` 명시 권장** (mirror 자동 선택이 실패할 때 있음)
- 컴파일 실패 시 시스템 lib 의존성 확인 → 보통 conda-forge에 해당 lib도 있음
- `~/.libPaths()` 첫 항목이 conda env의 R library여야 함 (확인: `.libPaths()`)

### 컴파일 의존성 해결 패턴

CRAN 패키지가 빌드 시 `-llzma`, `-lpcre`, `-licu` 등 system lib 필요할 때:
```bash
# 1) conda env에 해당 system lib 설치
mamba install -c conda-forge xz pcre2 icu libxml2 -y

# 2) 그 후 R에서 재시도
Rscript -e 'install.packages("the_pkg")'
```

이미 본 환경에 `xz`, `bzip2`, `zlib`, `pcre2`, `icu`, `compilers`가 들어있으므로 대부분 작동.

## 5. 우선순위 ④ — remotes::install_github (GitHub-only)

본 프로젝트의 `sceasy`, `SeuratDisk`처럼 CRAN에 안 올라온 패키지:

```r
# remotes 자체는 conda-forge에 있음
# mamba install -c conda-forge r-remotes -y

# GitHub에서 설치
remotes::install_github("cellgeni/sceasy",
                        upgrade = "never",       # 기존 의존성 유지
                        build_vignettes = FALSE) # 빌드 시간 단축
```

옵션 설명:
- **`upgrade = "never"`**: 의존성 패키지를 강제로 업데이트 안 함 (안전)
- `upgrade = "always"`: 모두 최신으로 (위험, 다른 게 깨질 수 있음)
- `upgrade = "ask"`: 매번 물어봄

### branch / tag 명시
```r
# 특정 commit 핀
remotes::install_github("user/repo@v1.2.3")
remotes::install_github("user/repo@<git_sha>")
remotes::install_github("user/repo@dev")          # branch
```

### 본 프로젝트의 GitHub 패키지
- `cellgeni/sceasy` — Seurat ↔ AnnData 변환
- `mojaveazure/seurat-disk` (== SeuratDisk) — h5Seurat ↔ h5ad
- 자동 설치 스크립트: `datasets/01_reaptec_atlas/scripts/install_r_bridge.R`

## 6. 우선순위 ⑤ — renv (프로젝트 단위 lock)

협업자 간 R 패키지 버전을 정확히 일치시키고 싶을 때.

```r
# 프로젝트 폴더 안에서
renv::init()                    # 초기화 (renv/ 폴더 + renv.lock 생성)
renv::snapshot()                # 현재 설치된 패키지를 lock 파일에 기록
renv::status()                  # lock vs 실제 비교
renv::restore()                 # lock에 따라 정확한 버전 재설치
```

본 프로젝트는 이미 `renv.lock`을 git에 commit. 새 협업자는:
```bash
git clone ... && cd AI-Bio-T-Cell
Rscript -e 'if(!requireNamespace("renv",quietly=TRUE)) install.packages("renv"); renv::restore()'
```

단점: conda env와 중복 관리되므로 신중히 사용. **본 프로젝트는 conda 우선, renv는 보조** (특수 버전 필요 시만).

## 7. 의존성 오류 디버깅 cheat-sheet

### 증상별 진단

```r
# A. "there is no package called 'X'"
# 진단: 설치 안 됨
.libPaths()                       # 어디서 찾는지
find.package("X")                  # 어느 경로에 있는지
installed.packages()[, "Package"]  # 전체 설치 목록
```

```r
# B. "package 'X' was installed by an R version with different internals; ...."
# 진단: R 버전 불일치 - 다른 R로 설치된 패키지가 보임
.libPaths()                       # 두 개 이상 보이면 정리 필요
Sys.getenv("R_LIBS_USER")          # 사용자 라이브러리 경로
# 해결: conda env의 R 라이브러리 경로만 남기기
```

```r
# C. "lazy-load database '...' is corrupt"
# 진단: 패키지 파일 손상
remove.packages("X")              # 우선 제거
mamba install -c conda-forge r-X --force-reinstall -y   # 재설치
```

```r
# D. "dependency 'Y' is not available for package 'X'"
# 진단: Y가 CRAN에 없거나 Bioconductor용
# 해결: Y가 어디 있는지 확인
BiocManager::available("Y")        # Bioc에 있나?
# 있으면: BiocManager::install("Y")
# 또는 conda: mamba install -c bioconda bioconductor-Y
```

```r
# E. "package 'X' is not available (for R version 4.3)"
# 진단: 해당 R 버전용 빌드 없음
# 해결: R 버전 업데이트 또는 다른 패키지
```

```r
# F. 컴파일 에러 (ld: cannot find -lXXX)
# 진단: 시스템 lib 부재
# 해결: conda env에 해당 lib 추가
# 예: -llzma → mamba install -c conda-forge xz
#     -licuuc → mamba install -c conda-forge icu
```

## 8. 본 프로젝트 권장 흐름 (실전)

새로운 R 패키지 `foo`가 필요할 때:

```bash
# Step 1: conda-forge에 있나?
mamba search -c conda-forge "r-foo" 2>&1 | head -3

# Step 2: 있으면 conda로 설치
mamba install -c conda-forge r-foo -y

# Step 3: 없으면 Bioconductor 확인
mamba search -c bioconda "bioconductor-foo" 2>&1 | head -3
# 있으면
mamba install -c bioconda bioconductor-foo -y

# Step 4: 둘 다 없으면 R 안에서 CRAN
Rscript -e 'install.packages("foo", repos="https://cloud.r-project.org")'

# Step 5: 컴파일 실패 시 - 에러 메시지의 -lXXX 라이브러리 conda로 설치
# 그 후 Step 4 재시도

# Step 6: CRAN에도 없으면 GitHub
Rscript -e 'remotes::install_github("user/foo", upgrade="never")'

# 매번: environment.yml에 추가 (재현성)
```

## 9. 본 프로젝트 conda env에 이미 깔린 R 패키지

`environment.yml` 발췌:
```yaml
- r-base=4.3              # R 본체
- r-essentials            # tidyverse 등 표준 묶음
- r-renv
- r-remotes
- r-devtools
- r-testthat
- r-here
- r-optparse
- r-matrix
- r-reticulate            # R-Python bridge
- r-seurat>=5.0           # Seurat 5
- r-signac>=1.13          # scATAC
- r-tidyverse
- r-data.table
- r-future
- r-future.apply
- bioconductor-genomicranges
- bioconductor-rtracklayer
- bioconductor-singlecellexperiment
- bioconductor-summarizedexperiment
- bioconductor-biocparallel
- bioconductor-zellkonverter      # SCE <-> AnnData
- bioconductor-rhdf5
- rpy2                            # Python에서 R 호출
- anndata2ri                      # R SCE -> Python AnnData
```

→ 이 목록에 있는 건 **이미 설치되어 import 가능**. `Rscript -e 'requireNamespace("ggplot2")'` 등으로 확인 가능.

## 10. 자주 막히는 함정

| 함정 | 해결 |
| --- | --- |
| 시스템 R(`/usr/bin/R`)과 conda R(`~/miniforge3/envs/.../bin/R`)이 섞임 | `which R` 확인. conda 활성 시 conda 것이어야 함. |
| `Sys.getenv("R_LIBS_USER")`에 ~/R/x86_64-pc-linux-gnu/4.3 같은 시스템 경로가 있음 | 그 경로에 깔린 옛 패키지가 우선될 수 있음. `unset R_LIBS_USER` 또는 그 경로 비우기 |
| 같은 패키지 두 버전 (conda + R install.packages) | `find ~/miniforge3 ~/R -name "DESCRIPTION" -path "*/foo/*"` 두 군데 있으면 conda 것만 남기기 |
| Bioconductor 버전 불일치 | R 4.3 = Bioc 3.18, 4.4 = 3.19. conda 동일 채널이면 자동 맞춤 |
| 회사/학교 네트워크에서 install.packages 차단 | `chooseCRANmirror()` 또는 `repos="http://..."` 명시 (사내 미러) |

## 11. 본인이 실수로 잘못 깔았을 때 - 청소

```bash
# A. R 사용자 라이브러리 (~/R/x86_64-pc-linux-gnu/4.3) 통째 정리
mv ~/R ~/R.bak.$(date +%Y%m%d)    # 백업
# 다음 R 세션은 conda 라이브러리만 사용

# B. conda env의 특정 R 패키지 재설치
mamba install -c conda-forge r-seurat --force-reinstall -y

# C. 모든 R 패키지 캐시 정리 (conda 측)
mamba clean -a -y
```

## 12. 자주 쓰는 한 줄

```bash
# 현재 env의 R 패키지 목록
Rscript -e '.libPaths(); print(rownames(installed.packages()))' | head -50

# 특정 패키지 위치
Rscript -e 'find.package("Seurat")'

# 한 줄 설치 (conda-forge 우선, 실패 시 CRAN, 그래도 실패 시 GitHub)
install_pkg() {
  local pkg=$1
  mamba install -c conda-forge "r-${pkg,,}" -y 2>/dev/null \
    || Rscript -e "install.packages('$pkg', repos='https://cloud.r-project.org')" 2>/dev/null \
    || echo "Manual install needed for $pkg"
}
install_pkg ggplot2
install_pkg Seurat
```

## 13. 관련 노트

- [[R_Manual]] §6 (패키지 관리) — 기본 install/load 명령
- [[Memory_and_Swap_Management]] — 큰 패키지 빌드 시 메모리 부족
- [[R_Python_Bridge]] — reticulate + sceasy 설치 패턴
- `datasets/01_reaptec_atlas/scripts/install_r_bridge.R` — sceasy/SeuratDisk 실전 설치 스크립트
- `environment.yml` — 본 프로젝트 R 패키지 spec
- `renv.lock` — 정확한 버전 lock (재현성)

## 한 줄

> R 패키지는 **항상 conda-forge 먼저 시도** (`mamba install -c conda-forge r-<name>`), 안 되면 bioconda, 그래도 안 되면 R 안에서 `install.packages()` 또는 `BiocManager::install()`, GitHub-only 패키지만 `remotes::install_github()`. **`install.packages("X")` 단독은 컴파일 실패의 주범**이므로 본 프로젝트 conda env가 있는 한 1순위가 아닙니다.
