# Perl Scripts Collection

This repository contains Perl scripts for bioinformatics and genomic data processing. 

## ⚠️ Important Note on `yangfan.pm` Module
**Replace directory paths** in dependent scripts:
```perl
/home/yangfan/Data/Bin/perl_script_my/final/ → your/local/path/
```
# 📚 Scripts Overview
## 🔍 Gene Annotation
### Script
Function
------
anno.gene.description.pl	
Get ENTREZID and GENENAME with [SYMBOL] or [ENSEMBL]
------
anno.gene.NCBI_summary.pl	Get NCBI summary with [ENTREZID]
anno.gene.Also_known_as.pl	Get "Also known as" annotations
anno.gene.NCBI_bed.pl	Get NCBI gene regions
anno.gene.NCBI_RPKM.pl	Get full RPKM for 27 tissues
anno.gene.NCBI_RPKM.tissue.pl	Get RPKM for specific tissues
anno.GO_KEGG.pl	Get GO/KEGG annotations
🧬 BED/GTF Processing
Script	Function
bam_ID.count.pl	Count reads in regions (handles PE overlap)
bed.gtf.pl	Create GTF from BED
BED.intersectBed.merge.pl	Merge overlapping peaks
BED.intersectBed.overlap_len_rate.pl	Calculate peak overlap metrics
bin.gtf.pl	Create binned GTF
🌐 Web Utilities
Script	Function
Crawler.donwload_URL.raw.pl	Web crawler template (requires customization)
🧪 Differential Expression
Script	Function
Deseq2.v2.pl	Generate DESeq2 pipelines
🧬 FASTA/FASTQ Tools
Script	Function
fa.gtf.pl	Create GTF from FASTA
fa.make.for_seq_file.pl	Generate custom FASTA
fastQ.ASII.pl	Output Phred33 quality scores
fastq2fasta.pl	Convert FASTQ→FASTA
fasta.reverse_complement.pl	Generate reverse complements
🔎 Sequence Retrieval & gRNA
Script	Function
get.reads.form.fastq.pl	Extract reads by name
Get.seq.from.fa.pl	Fetch sequences ([Chr][Start][End])
GetFaSeq.of.Pos.pl	Fetch sequences ([Chr][Start-End]/BED)
gRNA.search.whole.fa.FwBw.pl	Find 20bp NGG gRNAs (forward/backward)
gRNA.search.whole.fa.pl	Find 20bp NGG gRNAs
📊 Coverage Analysis
Script	Function
mosdepth.Genome_cov.summary.pl	Summarize mosdepth coverage
🧬 Paired-End Processing
Script	Function
PE.paired_bam.to.bed.v2.pl	Convert PE BAM→BED
PE_Reads.Strand.split.pl	Split reads by strand (POS/NEG)
📈 Normalization
Script	Function
pie.data.sum.pl	Combine files by columns
Quantile_Normalization.pl	Matrix quantile normalization
📊 RPKM & Selection
Script	Function
random.select.seq.from.fa.pl	Randomly sample FASTA
RPKM.calculation.pl	Calculate RPKM from HTseq-count
RPKM.normalization.pl	Normalize RPKM values
⚙️ Utilities
Script	Function
SamFlag.pl	Decode SAM/BAM flags
split.file.pl	Split files by line count
STAR.summary.v2.pl	Summarize STAR alignment
StatisticsDescriptive.pl	Descriptive statistics
Super.Alignment.pl	Generate alignment shells

# 📜 License
## MIT © Yangfan
Maintainer: Yangfan
Contact: yangfanzhou9606@gmail.com
Last Updated: June 2025

# A
anno.gene.description.pl    ...... Get "ENTREZID" and "GENENAME" with [SYMBOL] or [ENSEMBL] id.

anno.gene.NCBI_summary.pl    ...... Get "NCBI summary" with [ENTREZID]. Could be used after 'anno.gene.description.pl'.

anno.gene.Also_known_as.pl    ...... Get "NCBI Also known as" annotation with [ENTREZID]. Could be used after 'anno.gene.description.pl'.
 
anno.gene.NCBI_bed.pl    ...... Get "NCBI gene current region" annotaiton with [ENTREZID]. Could be used after 'anno.gene.description.pl'.

anno.gene.NCBI_RPKM.pl    ...... Get "NCBI full_rpkm of 27 tissues" annotaiton with [ENTREZID].

anno.gene.NCBI_RPKM.tissue.pl    ...... Get "NCBI full_rpkm of [input] tissues" annotaiton with [ENTREZID].

anno.GO_KEGG.pl    ...... Get "GO" and "KEGG" annotation with [SYMBOL].

# B
bam_ID.count.pl    ...... Count reads with the same region. Paired-end reads would consider the insert overlap.

bed.gtf.pl    ...... Creat gtf use bed file. Then could be used with HTseq-count.

BED.intersectBed.merge.pl    ...... Merge overlapped peaks of "intersectBed" results.

BED.intersectBed.overlap_len_rate.pl    ...... Calculate the overlap length and rate of "intersectBed" results.

bin.gtf.pl    ...... Divide genome into [bin] bp gtf. Then could be used with HTseq-count.

Blast.out.summary.pl    ...... Summary the blast out.

blastn_for_unMap_Fastq.pl    ...... Random select [n] sequence to do blast with FASTQ file.

Bowtie.summary.pl    ...... Summary the bowtie alignment out.

bp.of.seq.pl    ...... Show sequence info about length/GC/base and output 'reverse', 'reverse complementary', 'complementary'.

# C
Crawler.donwload_URL.raw.pl    ...... Crawler raw code, custom modifications are required when using.

# D
Deseq2.v2.pl    ...... Generate deseq2 R and shell by using 'deseq2.v2.sh'. 

# F
fa.gtf.pl    ...... Creat gtf use fasta file.

fa.make.for_seq_file.pl    ...... Creat fasta with sequence.

fastQ.ASII.pl    ...... output ASII score of fastq file. Only adapted for Phred33.

fastq2fasta.pl    ...... fastq to fasta.

fasta.reverse_complement.pl    ...... Output reverse_complement of fasta file.

# G
get.reads.form.fastq.pl    ...... output reads in fastq file with reads name.

Get.seq.from.fa.pl    ...... Fetch fasta sequence from given fasta files using: [Chr] [Start] [End].

GetFaSeq.of.Pos.pl    ...... Fetch fasta sequence from given fasta files using: [Chr] [Start-End] or bed files.

gRNA.search.whole.fa.FwBw.pl    ...... Find 20 bp NGG gRNAs in fasta file. Can set the [forward] and [backword].

gRNA.search.whole.fa.pl    ...... Find 20 bp NGG gRNAs in fasta file.

# M
mosdepth.Genome_cov.summary.pl    ...... Sumamry the coverage with 'mosdepth' output。

# P
PE.paired_bam.to.bed.v2.pl    ...... Paired-end reads (only properly pair) to bed.

PE_Reads.Strand.split.pl    ...... Reads split to POS and NEG with strand info.

pie.data.sum.pl  ...... Combine files with certain columns.

# Q
Quantile_Normalization.pl  ...... Quantile normalization wiht [Matrix] input.

# R
random.select.seq.from.fa.pl    ...... Random select [n] sequence from fasta.

RPKM.calculation.pl    ...... Calculate RPKM with HTseq-count output.

RPKM.normalization.pl    ...... Normalize RPKM with 'RPKM.calculation.pl' output.

# S
SamFlag.pl    ...... Output [flag] info.

split.file.pl    ...... Split file with [n] lines.

STAR.summary.v2.pl    ...... Summary the STAR alignment out.

StatisticsDescriptive.pl    # Output statistics info of input values. Need the Statistics::Descriptive module.

Super.Alignment.pl    # Generate the alignment shell by using 'super.Alignment.sh'.
