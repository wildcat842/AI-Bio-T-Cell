# 01 - RIKEN ReapTEC T-Cell Enhancer Atlas (P0, T1+T4 핵심)

## 인용
Oguchi, M., Murakawa, Y., et al. (2024). "An atlas of transcribed enhancers across helper T cell diversity for decoding human diseases." *Science*. doi:10.1126/science.add8394

## 개요
- ReapTEC(Reactive 5' end Profiling for Transcribed Enhancer Catalog) 기술로 발견된 약 63,000개 활성 양방향(transcribed bidirectional) enhancer.
- 인간 helper T 세포 다양성을 가로지르는 약 1,000,000개 세포 규모.
- 18개 면역 매개 질환(SLE, RA, IBD, T1D, MS, AS 등)의 GWAS 신호와 cross-referenced.
- RIKEN IMS Murakawa팀의 대표 자원.

## 접근
- **Processed atlas (open)**: Science 2024 Supplementary Materials, RIKEN OmicsNote (FANTOM 산하)
  - URL: https://www.science.org/doi/10.1126/science.add8394
- **Raw FASTQ (controlled)**: DDBJ / EGA (RIKEN MTA 필요)
- **Browser**: ZENBU genome browser (RIKEN)

## 라이선스
- Processed atlas: CC-BY-4.0 (논문 SI 기준)
- Raw FASTQ: Controlled access (MTA 협상 필요)

## 디렉토리
```
01_reaptec_atlas/
├── README.md              # 본 파일
├── raw/                   # (MTA 후 채워짐, .gitignored)
├── processed/             # SI tables, bedGraph, bigBed
├── metadata/              # sample manifest, disease ontology mapping
└── scripts/
    └── download_processed.sh   # 공개 SI 다운로드 자동화
```

## TODO (M1-M3)
- [ ] Science SI에서 enhancer coordinates (bedGraph) 다운로드
- [ ] 18개 면역 질환 GWAS overlap table 정리
- [ ] RIKEN OmicsNote 메타데이터(JSON) 수집
- [ ] Murakawa팀 MTA 협상 시작 (raw cellular-level data 접근)

## 모델링 활용 (토픽 매핑)
- **토픽 4 (인핸서 조절 네트워크)**: DNABERT enhancer sequence embedding의 학습 corpus + GNN regulatory network의 노드.
- **토픽 1 (소진 어트랙터)**: T cell subset별 enhancer 활성 패턴을 cell state representation의 추가 feature로 활용.
