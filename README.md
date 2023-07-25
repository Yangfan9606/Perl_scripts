# Perl_scripts
yangfan.pm  # Perl modules. Replace the directory of '/home/yangfan/Data/Bin/perl_script_my/final/' with this pm directory in some scripts.

# A
anno.gene.description.pl  # Get "ENTREZID" and "GENENAME" with [SYMBOL] or [ENSEMBL] id.

anno.gene.NCBI_summary.pl  # Get "NCBI summary" with [ENTREZID]. Could be used after 'anno.gene.description.pl'.

anno.gene.Also_known_as.pl  # Get "NCBI Also known as" annotation with [ENTREZID]. Could be used after 'anno.gene.description.pl'.
 
anno.gene.NCBI_bed.pl  # Get "NCBI gene current region" annotaiton wiht [ENTREZID]. Could be used after 'anno.gene.description.pl'.

# B
BED.intersectBed.merge.pl  # Merger overlaped peaks of "intersectBed" results.


# G
Get.seq.from.fa.pl  # Fetch fasta sequence from given fasta files using: [Chr] [Start] [End].

GetFaSeq.of.Pos.pl  # Fetch fasta sequence from given fasta files using: [Chr] [Start-End] or bed files.

pie.data.sum.pl  # Combine files with certain columns.

