# 01 - RIKEN ReapTEC T-Cell Enhancer Atlas (P0, T1+T4 핵심)

## Citation
Oguchi, A., Komatsu, S., Suzuki, A., Terao, C., Yamamoto, K., **Murakawa, Y.** et al. (2024). "An atlas of transcribed enhancers across helper T cell diversity for decoding human diseases." *Science*. doi: [10.1126/science.add8394](https://www.science.org/doi/10.1126/science.add8394)

## 핵심 정보
- **ReapTEC** = Reactive 5' end Profiling for Transcribed Enhancer Catalog
- **5' scRNA-seq**을 활용하여 gene expression과 enhancer activity를 동시 프로파일링
- 활성 bidirectional transcribed enhancer **62,803개** (논문의 "63K") × **136 subsets**
- 인간 CD4+ T cell의 cellular heterogeneity, differentiation trajectory, 면역 질환 유전성 연결
- **단일 세포 chromatin + 5' RNA + IsoSeq + Micro-C** 멀티오믹 통합

## 데이터 소스

### Primary - Dryad (전체 supplementary data, 161.66 GB)
- DOI: [10.5061/dryad.pk0p2ngwx](https://datadryad.org/dataset/doi:10.5061/dryad.pk0p2ngwx)
- 라이선스: CC0 1.0 (Dryad 기본)
- 발행일: 2024-04-22

| File | Size | 본 프로젝트 우선순위 |
| --- | --- | --- |
| `DataS1_log2cpm_MASK_136subsets_90565.xlsx` | 77.63 MB | P1 (gene matrix) |
| **`DataS2_Single_cell_rds_files.zip`** | **22.07 GB** | **P0 (Seurat .rds 단일 세포)** |
| **`DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx`** | **48.46 MB** | **P0 (enhancer matrix - 토픽4 학습 입력)** |
| **`DataS4_Bed_files.zip`** | **12.21 MB** | **P0 (enhancer 게놈 좌표 BED)** |
| `DataS5_TC_name_log2cpm_46108.xlsx` | 61.63 MB | P1 (transcription cluster) |
| `DataS6_MASseq_..._stringtie2_merge.gtf.gz` | 16.82 MB | P1 (IsoSeq 어노테이션) |
| `DataS7_Micro-C_*.hic / .mcool` | 16-44 GB each | P2 (3D contact, 4개 파일 ~115 GB) |
| `DataS8_*loop*.bedpe / .loop` | <5 MB each | P2 (Micro-C loops) |
| `DataS9_Region_Capture_Micro-C_*.Rds` | 1-10 GB each | P2 (region capture, 6개 파일 ~25 GB) |
| `DataS10_ABC_model_*.txt` | ~2 MB each | **P0 (ABC enhancer-gene 예측 - 토픽4)** |
| `README.md` | 13 KB | P0 (반드시 함께 다운로드) |

**권장 첫 다운로드 (~22.2 GB)**: DataS2 + DataS3 + DataS4 + DataS10 + Dryad README → 토픽4 prototype 충분.

### Secondary - 논문 Supplementary
- Science 2024 SI: https://www.science.org/doi/10.1126/science.add8394

### Pipeline - MurakawaLab/ReapTEC GitHub
- Repository: https://github.com/MurakawaLab/ReapTEC
- 5' scRNA-seq → gene expression + enhancer activity 동시 추출 파이프라인
- 본 데이터는 이 파이프라인의 산출물. 자체 raw FASTQ를 분석하지 않는다면 사용 불필요.

### Tertiary - Raw FASTQ (controlled access)
- DDBJ / EGA (Murakawa팀 직접 컨택 + MTA 필요)
- 본 프로젝트에서는 우선 processed atlas (Dryad)로 진행

## 로컬 디렉토리 구조

```
datasets/01_reaptec_atlas/
├── README.md                       (본 파일)
├── raw/                            (.gitignored - Dryad 다운로드)
│   ├── DataS2_Single_cell_rds_files.zip
│   ├── DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx
│   ├── DataS4_Bed_files.zip
│   ├── DataS10_*.txt
│   └── dryad_README.md
├── processed/                      (.gitignored - 변환 산출물)
│   ├── seurat_objects/             (unzip된 .rds)
│   ├── h5ad/                       (.rds → AnnData 변환 결과)
│   ├── enhancers.bed               (BED 통합본)
│   └── enhancer_expression.parquet (.xlsx → parquet)
├── metadata/
│   ├── dryad_manifest.tsv          (파일·크기·체크섬)
│   └── subset_136_metadata.csv     (subset 라벨, lineage)
└── scripts/
    ├── download_dryad.sh           (aria2c/curl 다운로드)
    ├── verify_checksums.sh         (md5 검증)
    ├── unzip_and_organize.sh       (raw/ → processed/)
    ├── rds_to_h5ad.R               (Seurat → AnnData 변환)
    ├── verify_h5ad.py              (Python에서 sanity check)
    └── download_processed.sh       (legacy - Science SI용, 미사용)
```

## 다운로드 워크플로우

```bash
# 0) 디스크 공간 확인 (최소 50 GB 여유: 22 GB 다운로드 + 22 GB unzip + 변환 산출물)
df -h $(pwd)

# 1) P0 파일 다운로드 (~22.2 GB)
bash datasets/01_reaptec_atlas/scripts/download_dryad.sh --tier p0

# 2) 체크섬 검증
bash datasets/01_reaptec_atlas/scripts/verify_checksums.sh

# 3) unzip 및 정리
bash datasets/01_reaptec_atlas/scripts/unzip_and_organize.sh

# 4) .rds → .h5ad 변환 (R, 메모리 큰 머신 권장)
Rscript datasets/01_reaptec_atlas/scripts/rds_to_h5ad.R \
  --in processed/seurat_objects \
  --out processed/h5ad

# 5) Python에서 sanity check
python datasets/01_reaptec_atlas/scripts/verify_h5ad.py
```

## 하드웨어 요구사항 (이 데이터셋 기준)

| 단계 | RAM | 디스크 | 시간 (참고) |
| --- | --- | --- | --- |
| 다운로드 22 GB | 4 GB | 25 GB | 30~120분 (네트워크 의존) |
| Unzip + .rds 로드 (Seurat) | **64 GB+** | 50 GB | 10~30분 |
| .rds → .h5ad 변환 | **96 GB+** (전체 한번에) 또는 16 GB (subset별) | +30 GB | 30~90분 |
| Python backed-mode 분석 | 16-32 GB | - | 즉시 |
| DNABERT-2 enhancer embedding (62K) | 16 GB + **GPU 24 GB+** | +5 GB | 1-3시간 |

자세한 환경 설계는 [`../../reports/deliverables/environment_design.md`](../../reports/deliverables/environment_design.md) 참조.

## 활용 (토픽 매핑)

- **토픽 4** (인핸서 조절 네트워크): DataS3 (matrix) + DataS4 (BED) + DataS10 (ABC predictions) → DNABERT-2 임베딩 + GNN 학습의 핵심 입력
- **토픽 1** (소진 어트랙터): DataS2 (Seurat .rds) → AnnData 변환 → Flow Matching trajectory의 추가 모달리티
- **토픽 3** (TME 공간): Micro-C 3D contact (DataS7-9) → 공간 모델의 prior 그래프 구조

## TODO

- [ ] `download_dryad.sh` 실행 → P0 4파일 22.2 GB 다운로드
- [ ] `verify_checksums.sh`로 md5 일치 확인
- [ ] Dryad 자체 README.md 정독
- [ ] DataS2 unzip → 개별 .rds 파일 개수·크기 매니페스트 작성
- [ ] `rds_to_h5ad.R` 실행 → 활성 conda env에서 결과 검증
- [ ] (선택) Micro-C 데이터(DataS7-9) 다운로드 — 토픽 3 시작 시점에
