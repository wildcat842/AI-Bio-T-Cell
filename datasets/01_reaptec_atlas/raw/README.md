이 사이트에 있는 README.md 파일임
https://datadryad.org/dataset/doi:10.5061/dryad.pk0p2ngwx


This repository contains Data S1 to S10. The detailed description is as follows.

**Data S1: Promoter-level gene expression (log2CPM) across 136 CD4+ T cell clusters.**
Promoters were defined as transcription start sites (TSSs) of protein-coding transcripts ±300 bp (hg38; GENCODE version 39 [‘primary assembly’]. scRNA-seq reads (TSS signals) mapped to the promoters were counted at TSS level in a strand-specific manner using the UCSC software bigWigAverageOverBed. Count normalization was based on counts per million (CPM). When count was converted to log2CPM, a prior count of 0.25 was added to the raw counts.

DataS1_log2cpm_MASK_136subsets_90565.xlsx: Expression data for promoter levels (listed in rows) for each of the 136 CD4+ T cell clusters (listed in columns). Count was converted to log2CPM.

**Data S2: RDS files of single-cell analyses.**

DataS2_Single_cell_rds_files.zip: There are 13 RDS files containing Seurat objects for single-cell data for human CD4+ T cell and subpopulations.

**Data S3: btcEnh expression levels (log2CPM) across 136 CD4+ T cell clusters.**
Bidirectionally transcribed candidate enhancers (btcEnhs) were identified by Read-level pre-filtering and transcribed enhancer call (ReapTEC). scRNA-seq reads (TSS signals) mapped to the btcEnhs were counted at TSS level using the UCSC software bigWigAverageOverBed. Count normalization was based on counts per million (CPM). When count was converted to log2CPM, a prior count of 0.25 was added to the raw counts.

DataS3_log2cpm_btcEnhs_filtered_136subsets_62803.xlsx: Expression data for btcEnh levels (listed in rows) for each of the 136 CD4+ T cell clusters (listed in columns). Count was converted to log2CPM.

**Data S4: BED files of bidirectionally transcribed candidate enhancers (btcEnhs) and ATAC peaks.**

DataS4_Bed_files.zip: There are 31 BED files of btcEnhs and ATAC peaks used for ChIP-seq enrichment and motif analyses, MENTR (Koido et al. Nat. Biomed. Eng. 2023) and linkage disequilibrium score regression analysis (Finucane et al. Nat. Genet. 2015).

F1_btcEnhs.bed: BED file of 62,803 btcEnhs identified across human CD4+ T cells using 5′ single-cell RNA-seq data in this study.
F6_ATACpeaks_all.bed: BED file of 218,508 ATAC peaks identified across human CD4+ T cells using snATAC-seq data in this study.
F7_ATACpeaks_pATAC_all.bed: BED file of 26,313 ATAC peaks located within ±300 bp around the 5′ end of the transcript (GENCODE v39) (= pATAC).
F8_ATACpeaks_dATAC_all.bed: BED file of 192,195 ATAC peaks located within ±300 bp around the 5′ end of the transcript (GENCODE v39) (= dATAC).
F9_ATACpeaks_pATAC_transcribed.bed: BED file of 22,519 transcribed pATAC peaks.
F10_ATACpeaks_pATAC_untranscribed.bed: BED file of 3,794 untranscribed pATAC peaks.
F11_ATACpeaks_dATAC_bidirectionally_transcribed.bed: BED file of 32,978 bidirectionally transcribed dATAC peaks.
F12_ATACpeaks_dATAC_bidirectionally_transcribed_count_high10.bed: BED file of 19,682 bidirectionally transcribed dATAC peaks (counts ≥ 10).
F13_ATACpeaks_dATAC_bidirectionally_transcribed_count_low10.bed: BED file of 13,296 bidirectionally transcribed dATAC peaks (counts < 10).
F14_ATACpeaks_dATAC_bidirectionally_transcribed_count_high100.bed: BED file of 6,193 bidirectionally transcribed dATAC peaks (counts ≥ 100).
F15_ATACpeaks_dATAC_bidirectionally_transcribed_count_low100.bed: BED file of 26,785 bidirectionally transcribed dATAC peaks (counts < 100).
F16_ATACpeaks_dATAC_unidirectionally_transcribed.bed: BED file of 70,580 unidirectionally transcribed dATAC peaks.
F17_ATACpeaks_dATAC_unidirectionally_transcribed_count_high10.bed: BED file of 21,191 unidirectionally transcribed dATAC peaks (counts ≥ 10).
F18_ATACpeaks_dATAC_unidirectionally_transcribed_count_low10.bed: BED file of 49,389 unidirectionally transcribed dATAC peaks (counts < 10).
F19_ATACpeaks_dATAC_unidirectionally_transcribed_count_high100.bed: BED file of 5,491 unidirectionally transcribed dATAC peaks (counts ≥ 100).
F20_ATACpeaks_dATAC_unidirectionally_transcribed_count_low100.bed: BED file of 65,089 unidirectionally transcribed dATAC peaks (counts < 100).
F21_ATACpeaks_dATAC_untranscribed.bed: BED file of 88,637 untranscribed dATAC peaks.
F22_Mask_file_equal_to_promoters.bed: BED files of 90,565 transcription start sites of protein-coding transcripts ±300 bp (hg38; GENCODE version 39 [‘primary assembly’]. This BED file is used as the mask file in the enhancer analysis.
F33_FANTOM5_hg38_enhancers.bed: BED file of 63,285 FANTOM5 enhancers.
F34_FANTOM5_hg38_enhancers_NOToverlap_with_CD4T_btcEnhs.bed: BED file of 53,981 FANTOM5 enhancers that don’t overlap with btcEnhs of CD4+ T cells (F1_btcEnhs.bed).
ATACpeaks_dATAC_bidirectionally_transcribed_count_high10andlow100.bed: BED file of 13,489 bidirectionally transcribed dATAC peaks (10 ≤ counts < 100).
ATACpeaks_dATAC_unidirectionally_transcribed_count_high10andlow100.bed: BED file of 15,700 unidirectionally transcribed dATAC peaks (10 ≤ counts < 100).
ForChIP_atlas_ATACpeaks_dATAC_bidirectionally_transcribed_count_high10andlow100_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 13,489 bidirectionally transcribed dATAC peak (10 ≤ counts < 100).
ForChIP_atlas_ATACpeaks_dATAC_unidirectionally_transcribed_count_high10andlow100_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 15,700 unidirectionally transcribed dATAC peak (10 ≤ counts < 100).
ForChIP_atlas_F11_ATACpeaks_dATAC_bidirectionally_transcribed_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 32,978 bidirectionally transcribed dATAC peak.
ForChIP_atlas_F13_ATACpeaks_dATAC_bidirectionally_transcribed_count_low10_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 13,296 bidirectionally transcribed dATAC peak (counts < 10).
ForChIP_atlas_F14_ATACpeaks_dATAC_bidirectionally_transcribed_count_high100_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 6,193 bidirectionally transcribed dATAC peak (counts ≥ 100).
ForChIP_atlas_F16_ATACpeaks_NOToverlap_Mask_unitc_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 70,580 unidirectionally transcribed dATAC peak.
ForChIP_atlas_F18_ATACpeaks_NOToverlap_Mask_unitc_low10_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 49,389 unidirectionally transcribed dATAC peak (counts < 10).
ForChIP_atlas_F19_ATACpeaks_NOToverlap_Mask_unitc_high100_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 5,491 unidirectionally transcribed dATAC peak (counts ≥ 100).
ForChIP_atlas_F21_ATACpeaks_dATAC_untranscribed_1000bp.bed: BED file of the regions obtained by extending ±500 bp from the midpoint of each 88,637 untranscribed dATAC peak.

**Data S5: Expression matrix (log2CPM) at robust TSS peaks across 136 CD4+ T cell clusters.**
TSS peaks were detected using scripts provided at https://github.com/anderssonrobin/enhancers/blob/master/scripts/bidir_enhancers with minor modifications. TSS peaks were generated by merging TSSs located within 10 bp of each other. Robust TSS peaks (with a cutoff of log2CPM ≥ 2 in at least one cluster) were named according to the nearest known transcript and numbered in ascending order from upstream to downstream of the transcript. scRNA-seq reads (TSS signals) mapped to the robust TSS peaks were counted at TSS level in a strand-specific manner using the UCSC software bigWigAverageOverBed. Count normalization was based on counts per million (CPM). When count was converted to log2CPM, a prior count of 0.25 was added to the raw counts.

DataS5_TC_name_log2cpm_46108.xlsx: Expression data for robust TSS peak levels (listed in rows) for each of the 136 CD4+ T cell clusters (listed in columns). Count was converted to log2CPM.

**Data S6: GTF file of de novo transcripts identified by 5´ MAS-seq.**
High-fidelity long reads (HiFi reads) were generated using CCS software version 6.3.0 (https://ccs.how) with default parameters. HiFi BAM files were processed using SMRT Link version 12 according to the guide (https://www.pacb.com/wp-content/uploads/SMRT_Link_MAS-Seq_troubleshooting_v12.0.pdf) to adapt to the 10x Genomics 5′ kit. We had the UMI+TSO trimmed together as a 23-bp component with the 16B-23U-T design. Reads with unencoded G at the 5′ ends were extracted from the scisoseq.mapped.bam file. Transcripts were assembled de novo using filtered scisoseq.mapped.bam files of circulating bulk CD4+ T cells and CD4+CD25+ T cells. Stringtie2 version 2.2.1 was used to assemble and merge transcripts for individual samples from each dataset with the --fr, -G, and -L options.

DataS6_MASseq_CD4bulk_scisoseq_Treg_scisoseq_stringtie2_merge.gtf.gz: GTF file generated by Stringtie2.

**Data S7: Contact maps of Micro-C data.**
Micro-C raw data were processed with the dovetail_tools pipeline (https://micro-c.readthedocs.io/en/latest/), which was provided for the analysis of Micro-C libraries using the Dovetail Micro-C Kit. In brief, reads were mapped to the human reference assembly hg38 using BWA-MEM with flags -5SP (http://bio-bwa.sourceforge.net/). Alignments were parsed and pairs were classified using the pairtools package (https://github.com/mirnylab/pairtools) to generate 4DN-compliant pairs files. Pairs with multiple hits, mapping quality score (MAPQ) ≤ 30, singleton, dangling end, or self-circle, and PCR duplicates were removed. Pairs classified as uniquely mapped or rescued chimeras with MAPQ > 30 on both sides were aggregated into contact matrices in the cooler format using the cooler package (https://github.com/open2c/cooler) at 1 kb. Output files containing all valid pairs were used for downstream analyses such as loop calling. 4DN-compliant pairs files were also converted to HIC files using the Juicer Tools package (https://github.com/aidenlab/juicer). Contact matrices were balanced by using SCALE normalization in HIC files. 

Data S7 consists of the following 4 files.
DataS7_Micro-C_bulk_resting_CD4_contact_map.hic
DataS7_Micro-C_bulk_resting_CD4_contact_map.mcool
DataS7_Micro-C_bulk_activated_CD4_contact_map.hic
DataS7_Micro-C_bulk_activated_CD4_contact_map.mcool

**Data S8: Results of Micro-C loops.**
Chromatin loop contacts in this study were identified by the HiCCUPS algorithm using the Juicer Tools package version 2.20.0 (https://github.com/aidenlab/juicer) and the scale-space representation algorithm using the Mustache package (https://github.com/ay-lab/mustache). Loops were called at a 1-kb resolution with SCALE-normalized contact matrices for HiCCUPS and with ICE-normalized contact matrices for Mustache, and were filtered for an FDR < 0.05.

Data S8 consists of the following 4 files.
DataS8_Micro-C_HiCCUPS_loop_bulk_resting_CD4.bedpe: Chromatin loop contacts for resting CD4+ T cells identified by the HiCCUPS algorithm.
DataS8_Micro-C_mustache_loop_bulk_resting_CD4.loop: Chromatin loop contacts for resting CD4+ T cells identified by using Mustache package.
DataS8_Micro-C_HiCCUPS_loop_bulk_activated_CD4.bedpe: Chromatin loop contacts for resting CD4+ T cells identified by the HiCCUPS algorithm.
DataS8_Micro-C_mustache_loop_bulk_activated_CD4.loop: Chromatin loop contacts for activated CD4+ T cells identified by using Mustache package.

**Data S9: Output files of CHiCAGO.**
Interaction calling and significance thresholding for RCMC was based on the workflow developed by Dovetail Genomics (https://dovetail-capture.readthedocs.io/en/latest/interactions.html) and the CHiCAGO tool. The input files for the CHiCAGO tool were the pairs files, which were produced according to the same method as for the Micro-C contact map.

Data S9 consists of the following 6 files.
DataS9_Region_Capture_Micro-C_bulk_resting_CD4_1kb_chicago_results.Rds
DataS9_Region_Capture_Micro-C_bulk_activated_CD4_1kb_chicago_results.Rds
DataS9_Region_Capture_Micro-C_Treg_1kb_chicago_results.Rds
DataS9_Region_Capture_Micro-C_Tfh_1kb_chicago_results.Rds
DataS9_Region_Capture_Micro-C_Th17_1kb_chicago_results.Rds
DataS9_Region_Capture_Micro-C_LAG3_1kb_chicago_results.Rds

**Data S10: Results of ABC models.**
We calculated the ABC scores using the pipeline provided by the authors (version 0.2.2, https://github.com/broadinstitute/ABC-Enhancer-Gene-Prediction) to predict enhancer–gene connections in resting and activated CD4+ T cells on the basis of chromatin accessibility (original pseudo-bulk snATAC-seq data from single-cell experiments), histone modifications (public H3K27ac ChIP–seq, ENCODE ENCFF484WXU for resting CD4+ T cells and ENCFF878VZI and ENCFF056OHJ for activated CD4+ T cells), gene expression profile (original pseudo-bulk RNA-seq data from single-cell experiments), and chromatin contact map (original Micro-C data).

Data S10 consists of the following 2 files.
DataS10_ABC_model_EnhancerPredictions_bulk_resting_CD4.txt
DataS10_ABC_model_EnhancerPredictions_bulk_activated_CD4.txt
