# Perl_scripts
yangfan.pm  # Perl modules. Replace the directory of '/home/yangfan/Data/Bin/perl_script_my/final/' with this pm directory in some scripts.

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

fa.random.pl    ...... Random select sequence from .fa file.

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
