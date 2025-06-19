# Perl Scripts Collection

This repository contains Perl scripts for bioinformatics and genomic data processing. 

## ⚠️ Important Note on `yangfan.pm` Module
**Replace directory paths** in dependent scripts:
```perl
/home/yangfan/Data/Bin/perl_script_my/final/ → your/local/path/
```
## 📚 Scripts Overview
### 🔍 Gene Annotation
| Script          | Function                     |
|-----------------|------------------------------|
|`anno.gene.description.pl`	|Get **`ENTREZID`** and **`GENENAME`** with **`SYMBOL`** or **`ENSEMBL`** |
|`anno.gene.NCBI_summary.pl`	|Get NCBI summary with **`ENTREZID`** |
|`anno.gene.Also_known_as.pl`	|Get "Also known as" annotations |
|`anno.gene.NCBI_bed.pl`	|Get NCBI gene regions |
|`anno.gene.NCBI_RPKM.pl`	|Get full RPKM for 27 tissues |
|`anno.gene.NCBI_RPKM.tissue.pl`	|Get RPKM for specific tissues |
|`anno.GO_KEGG.pl`	|Get **`GO`**/**`KEGG`** annotations |

### 🧬 BED/GTF Processing
| Script          | Function                     |
|-----------------|------------------------------|
|`bam_ID.count.pl` |	Count reads in regions (handles PE overlap) |
|`bed.gtf.pl` |	Create **`GTF`** from **`BED`** |
|`BED.intersectBed.merge.pl` |	Merge overlapping peaks |
|`BED.intersectBed.overlap_len_rate.pl` |	Calculate peak overlap metrics |
|`bin.gtf.pl` |	Create binned **`GTF`** |

### 🌐 Web Utilities
| Script          | Function                     |
|-----------------|------------------------------|
|`Crawler.donwload_URL.raw.pl` |	Web crawler template (requires customization) |

### 🧪 Differential Expression
| Script          | Function                     |
|-----------------|------------------------------|
|`Deseq2.v2.pl` |	Generate **`DESeq2`** pipelines |

### 🧬 FASTA/FASTQ Tools
| Script          | Function                     |
|-----------------|------------------------------|
|`fa.gtf.pl` |	Create **`GTF`** from **`FASTA`** |
|`fa.make.for_seq_file.pl` |	Generate custom **`FASTA`** |
|`fastQ.ASII.pl` |	Output Phred33 quality scores |
|`fastq2fasta.pl` |	Convert **`FASTQ`** → **`FASTA`** |
|`fasta.reverse_complement.pl` |	Generate reverse complements |

### 🔎 Sequence Retrieval & gRNA
| Script          | Function                     |
|-----------------|------------------------------|
|`get.reads.form.fastq.pl` |	Extract reads by name
|`Get.seq.from.fa.pl` |	Fetch sequences (**`[Chr]`****`[Start]`****`[End]`**)
|`GetFaSeq.of.Pos.pl` |	Fetch sequences (**`[Chr]`****`[Start-End]`**/**`BED`**)
|`gRNA.search.whole.fa.FwBw.pl` |	Find 20bp NGG gRNAs (forward/backward)
|`gRNA.search.whole.fa.pl` |	Find 20bp NGG gRNAs

### 📊 Coverage Analysis
| Script          | Function                     |
|-----------------|------------------------------|
|`mosdepth.Genome_cov.summary.pl` |	Summarize **`mosdepth`** coverage |

###🧬 Paired-End Processing
| Script          | Function                     |
|-----------------|------------------------------|
|`PE.paired_bam.to.bed.v2.pl` |	Convert PE **`BAM`** → **`BED`** |
|`PE_Reads.Strand.split.pl	Split` | reads by strand (**`POS`**/**`NEG`**) |

### 📈 Normalization
| Script          | Function                     |
|-----------------|------------------------------|
|`pie.data.sum.pl` |	Combine files by columns |
|`Quantile_Normalization.pl` |	Matrix quantile normalization |

### 📊 RPKM & Selection
| Script          | Function                     |
|-----------------|------------------------------|
|`random.select.seq.from.fa.pl` |	Randomly sample **`FASTA`** |
|`RPKM.calculation.pl` |	Calculate **`RPKM`** from **`HTseq-count`** |
|`RPKM.normalization.pl` |	Normalize **`RPKM`** values |

### ⚙️ Utilities
| Script          | Function                     |
|-----------------|------------------------------|
|`SamFlag.pl` |	Decode **`SAM`**/**`BAM`** flags |
|`split.file.pl` |	Split files by line count |
|`STAR.summary.v2.pl` |	Summarize **`STAR`** alignment |
|`StatisticsDescriptive.pl` |	Descriptive statistics |
|`Super.Alignment.pl` |	Generate alignment shells |

# 📜 License
## MIT © Yangfan
Maintainer: Yangfan

Contact: yangfanzhou9606@gmail.com

Last Updated: June 2025
