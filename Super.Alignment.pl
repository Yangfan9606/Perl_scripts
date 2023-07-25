#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 生成alignment的shell

Usage: .pl IN_file
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
open(INfile, $infile) or die $!;

Ptime("Start");
#############
my %prj;
my $sp;
my @sample;
my $sf;
my $uniq;
my @bamfile;
my $bamNUM;

while(<INfile>){
	next if (/^#/);
	chomp;
	my @info = split/\s+/;
	my @temp = split/=/,$info[0];
	next if($temp[0] eq "");
	my $n = $temp[0];
	if($n eq "species"){
		$sp=$temp[1];
		die "你确定物种选对了?\n" if ($sp ne "hg38" && $sp ne "mm10");
	}elsif($n eq "sample"){
		@sample=split/,/,$temp[1];
	}elsif($n eq "software"){
		$sf=$temp[1];
		$uniq="NH:i:1" if $sf eq "hisat2";
		$uniq="NH:i:1" if $sf eq "STAR";
		$uniq="\"NM:\" \$s.$sf.sam|grep -v \"XS:\"" if $sf eq "bowtie2";
		$uniq="NH:i:1" if $sf eq "bowtie";
		$uniq="-v -e 'XA:Z:' -e 'SA:Z:'" if $sf eq "bwa";
		die "软件写对了?\n" if ($sf ne "hisat2" && $sf ne "STAR" && $sf ne "bowtie" && $sf ne "bowtie2" && $sf ne "bwa");
	}elsif($n eq "bam"){
		@bamfile=split/,/,$temp[1];
		$bamNUM=@bamfile;
	}else{
		$prj{$temp[0]}=$temp[1];
	}
}
close INfile;
print "----#####--info--#####----
Genome: $sp
软件：$sf
PE = $prj{'PE'}
fr = $prj{'fr'}
bamNUM : $bamNUM
----#####--info--#####----
";
if ($prj{'fr'} != 0 && $prj{'fr'} != 1 && $prj{'fr'} != 2){
	die "fr写错了！\n";
}
#############
open(OUT, ">$prj{'prj'}.alignment.sh") or die $!;
if ($sp eq "hg38"){
	print OUT "Genome=GRCh38;\n";
}else{print OUT "Genome=mm10;\n";}
print OUT "Genomedir=/home/yangfan/Data/Database/$sp;
bin=/Ubin/bin;\n
sample=\"";
my $sam;
my $saa=0;
my $S;
my $OS = join(" ",@sample);
my $SOS = `echo $OS|sed \"s/ /\\n/g\" |sort -V -k1|sed \":a;N;s/\\n/ /;ta\"`;
chomp $SOS;
my @sort_sample= split/ /,$SOS;
foreach (@sort_sample){
	if ($saa==0){
	$sam= $_;
	$S = $_;
	$saa=1;
	}else{
		$sam .= " $_";
	$S .= ",$_";
}
}
my $SS = $S;
$SS =~ s/,/.log.temp /;
$SS .= ".log.temp";
print OUT "$sam\"
for s in \$sample
do
";
if ($prj{'PE'} == 0){
	print OUT "cutadapt -f fastq -n 1 -e 0.1 -O 2 -m 15 -a AGATCGGAAGAGCACACGTCT -o \$s.fastq.clipper.gz \$s.fastq.gz > \$s.log\nwait\n#   1 CTGTCTCTTATACACATCTCC\n#   2 CTGTCTCTTATACACATCTG\n";
		if ($sf eq "hisat2"){
			my $strand="--rna-strandness R";
			$strand="--rna-strandness F" if $prj{'fr'} == 2;
			$strand="" if $prj{'fr'} == 0;
print OUT "hisat2 -x \$Genomedir/\$Genome -k 2 -p 30 --known-splicesite-infile \$Genomedir/\$Genome.hisat2.ss $strand --dta -U \$s.fastq.clipper.gz --no-unal --un-gz \$s.hisat2.un.gz --no-softclip --summary-file \$s.hisat2.log| tee >(samtools flagstat - > \$s.hisat2.flagstat) | samtools sort -O BAM | tee \$s.hisat2.bam\n";
		}elsif($sf eq "STAR"){
			$sf="STARAligned.out";
print OUT "STAR --runThreadN 30 --outFileNamePrefix \$s.STAR --genomeDir \$Genomedir/STAR  --outSAMtype BAM Unsorted --readFilesCommand zcat --readFilesIn \$s.fastq.clipper.gz --alignEndsType EndToEnd --outReadsUnmapped Fastx 2\n";
print OUT "#STAR --runThreadN 30 --outFilterMultimapNmax 20 --alignEndsType EndToEnd --outFileNamePrefix \$s.STAR --outSAMstrandField intronMotif --genomeDir \$Genomedir --outSAMtype BAM Unsorted --readFilesCommand zcat --readFilesIn \$s.fastq.clipper.gz --outReadsUnmapped Fastx 2\n";
		}elsif($sf eq "bowtie"){
print OUT "bowtie \$Genomedir/\$Genome  \$s.fastq.clipper -p 30 --best --strata -M 2 --no-unal -S \$s.bowtie.sam --un \$s.bowtie.un\n";
		}elsif($sf eq "bowtie2"){
print OUT "bowtie2 -x \$Genomedir/\$Genome -q -k 2 -p 30 -U \$s.fastq.clipper --no-unal -S \$s.bowtie2.sam --un \$s.bowtie2.un\n";
		}else{
print OUT "bwa mem -t 30 \$Genomedir/\$Genome.fa \$s.fastq.clipper > \$s.bwa.raw.sam\nwait\nperl /home/yangfan/Data/Bin/perl_script_my/final/Sam.SoftClip.filter.pl \$s\n";
		}
}elsif($prj{'PE'}==1){
	print OUT "cutadapt -f fastq -n 1 -e 0.1 -O 2 -m 16 -a AGATCGGAAGAGCACACGTCT -A AGATCGGAAGAGCGTCGTGT  -o \$s.1.fastq.clipper.gz -p \$s.2.fastq.clipper.gz \$s.1.fastq.gz \$s.2.fastq.gz > \$s.log\nwait\n#   1 CTGTCTCTTATACACATCTCC\n#   2 CTGTCTCTTATACACATCTG\n";
		if ($sf eq "hisat2"){
			my $strand="--rna-strandness RF";
			$strand = "--rna-strandness FR" if $prj{'fr'} == 2;
			$strand = "" if $prj{'fr'}==0;
print OUT "hisat2 -x \$Genomedir/\$Genome -k 2 -p 30 --known-splicesite-infile \$Genomedir/\$Genome.hisat2.ss $strand --dta -1 \$s.1.fastq.clipper.gz -2 \$s.2.fastq.clipper.gz --no-unal --un-conc-gz \$s.hisat2.un.gz --no-softclip --summary-file \$s.hisat2.log| tee >(samtools flagstat - > \$s.hisat2.flagstat) | samtools sort -O BAM | tee \$s.hisat2.bam\n";
		}elsif($sf eq "STAR"){
			$sf="STARAligned.out";
print OUT "STAR --runThreadN 30 --outFilterMultimapNmax 20 --outFileNamePrefix \$s.STAR --genomeDir \$Genomedir/STAR  --outSAMtype BAM Unsorted --readFilesCommand zcat --readFilesIn \$s.1.fastq.clipper.gz \$s.2.fastq.clipper.gz --alignEndsType EndToEnd --outReadsUnmapped Fastx 2 --outSAMstrandField intronMotif\n";
print OUT "#STAR --runThreadN 30 --outFileNamePrefix \$s.STAR --genomeDir \$Genomedir --outSAMtype SAM --readFilesCommand zcat --readFilesIn \$s.1.fastq.clipper.gz \$s.2.fastq.clipper.gz --alignEndsType EndToEnd --outReadsUnmapped Fastx 2\n";
print OUT "#STAR --runThreadN 30 --outFilterMultimapNmax 20 --alignEndsType EndToEnd --outFileNamePrefix \$s.STAR --outSAMstrandField intronMotif --genomeDir \$Genomedir --outSAMtype BAM Unsorted --readFilesCommand zcat --readFilesIn \$s.1.fastq.clipper.gz \$s.2.fastq.clipper.gz --outReadsUnmapped Fastx 2\n";
		}elsif($sf eq "bowtie"){
print OUT "bowtie \$Genomedir/\$Genome  -1 \$s.1.fastq.clipper -2 \$s.2.fastq.clipper -p 30 -M 2 --no-unal --un \$s.bowtie.un | samtools view -@ 36 -Sb -o \$s.bowtie2.bam\n";
		}elsif($sf eq "bowtie2"){
print OUT "bowtie2 -x \$Genomedir/\$Genome -q -k 2 -p 30 -1 \$s.1.fastq.clipper -2 \$s.2.fastq.clipper --no-discordant --no-mixed --no-unal --un-conc \$s.bowtie2.un -X 500 | samtools view -@ 36 -Sb -o \$s.bowtie2.bam\n";
		}else{
print OUT "bwa mem -t 30 \$Genomedir/\$Genome.fa \$s.1.fastq.clipper \$s.2.fastq.clipper > \$s.bwa.raw.sam\nwait\nperl /home/yangfan/Data/Bin/perl_script_my/final/Sam.SoftClip.filter.pl \$s\n";
		}
}else{die "PE都能写错?\n";}

if ($prj{'PE'} == 0){
print OUT "wait
samtools view -h -F 3332 \$s.$sf.bam -@ 15|samtools sort - -o \$s.bam -@ 15
samtools index \$s.bam -@ 30
wait
echo -en \"\$s.M\t\" > \$s.bg.sum
### !!!!!!!!!   注意 bam 必须要有index 才可以 找Mito的reads
samtools view \$s.bam \"M\" |wc -l  >>\$s.bg.sum
#samtools view \$s.uniq.bam \"M\" |wc -l  >>\$s.bg.sum
loc=\"rRNA tRNA\"
for l in \$loc
do
echo -en \"\$s.\$l\t\" >> \$s.bg.sum
intersectBed -abam \$s.bam -b \$Genomedir/\$Genome.\$l.bed |samtools view - |wc -l >> \$s.bg.sum
#intersectBed -abam \$s.uniq.bam -b \$Genomedir/\$Genome.\$l.bed |samtools view - |wc -l >> \$s.bg.sum
wait
done
#grep M \$Genomedir/\$Genome.genome.bed|cat - \$Genomedir/\$Genome.tRNA.bed \$Genomedir/\$Genome.rRNA.bed > \$Genome.trMRNA.bed
#intersectBed -abam \$s.bam -b \$Genome.trMRNA.bed -v  >\$s.trMclean.bam
wait
";
if ($sf eq "bwa"){
print OUT "
samtools view -h \$s.bam | grep $uniq | samtools view -b -@ 30|samtools sort - -o \$s.uniq.bam -@ 30
#samtools index \$s.uniq.bam -@ 30
";}else{
print OUT "
samtools view -H \$s.$sf.bam > \$s.head
samtools view -F 3332 \$s.$sf.bam -@ 15 | grep $uniq |cat \$s.head -|samtools view -Sb - |samtools sort - -o \$s.uniq.bam -@ 30
#samtools index \$s.uniq.bam -@ 30
";
}
print OUT"
wait
#java -jar \$bin/picard.jar MarkDuplicates INPUT=\${s}.uniq.bam OUTPUT=\${s}.uniq.nodup.bam METRICS_FILE=\${s}.uniq.nodup.dup ASSUME_SORTED=TRUE REMOVE_DUPLICATES=true
#igvtools count -z 10 -w 5 \$s.uniq.nodup.bam \$s.uniq.nodup.tdf \$Genomedir/\${Genome}.chrom.sizes
java -jar \$bin/picard.jar MarkDuplicates INPUT=\${s}.bam OUTPUT=\${s}.all.nodup.bam METRICS_FILE=\${s}.dup ASSUME_SORTED=TRUE REMOVE_DUPLICATES=true
igvtools count -z 10 -w 5 \$s.all.nodup.bam \$s.all.nodup.tdf \$Genomedir/\${Genome}.chrom.sizes
wait
done
";
}elsif($prj{'PE'}==1){
print OUT "wait
samtools view -h -F 3332 \$s.$sf.bam -@ 15|samtools sort - -o \$s.bam -@ 15
samtools index \$s.bam -@ 30
wait
";
if ($sf eq "bwa"){
print OUT "
samtools view -h \$s.bam | grep $uniq | samtools view -b -@ 30|samtools sort - -o \$s.uniq.bam -@ 30
#samtools index \$s.uniq.bam -@ 30
";}else{
print OUT "
samtools view -H \$s.$sf.bam > \$s.head
#####         single end delete the [-f 2] for uniq
samtools view -F 3332 \$s.$sf.bam -@ 15 | grep $uniq |cat \$s.head -|samtools view -Sb -f 2 - |samtools sort - -o \$s.uniq.bam -@ 30
#samtools index \$s.uniq.bam -@ 30
";
}
print OUT "
wait
echo -en \"\$s.M\t\" > \$s.bg.sum
### !!!!!!!!!   注意 bam 必须要有index 才可以 找Mito的reads
samtools view \$s.bam \"M\" |wc -l  >>\$s.bg.sum
#samtools view \$s.uniq.bam \"M\" |wc -l  >>\$s.bg.sum
loc=\"rRNA tRNA\"
for l in \$loc
do
echo -en \"\$s.\$l\t\" >> \$s.bg.sum
intersectBed -abam \$s.bam -b \$Genomedir/\$Genome.\$l.bed |samtools view - |wc -l >> \$s.bg.sum
#intersectBed -abam \$s.uniq.bam -b \$Genomedir/\$Genome.\$l.bed |samtools view - |wc -l >> \$s.bg.sum
wait
done
#grep M \$Genomedir/\$Genome.genome.bed|cat - \$Genomedir/\$Genome.tRNA.bed \$Genomedir/\$Genome.rRNA.bed > \$Genome.trMRNA.bed
#intersectBed -abam \$s.bam -b \$Genome.trMRNA.bed -v  >\$s.trMclean.bam
wait
#java -jar \$bin/picard.jar MarkDuplicates INPUT=\${s}.bam OUTPUT=\${s}.all.nodup.bam METRICS_FILE=\${s}.dup ASSUME_SORTED=TRUE REMOVE_DUPLICATES=true
java -jar \$bin/picard.jar MarkDuplicates INPUT=\${s}.uniq.bam OUTPUT=\${s}.uniq.nodup.bam METRICS_FILE=\${s}.dup ASSUME_SORTED=TRUE REMOVE_DUPLICATES=true
#java -jar \$bin/picard.jar MarkDuplicates INPUT=\${s}.uniq.trMclean.bam OUTPUT=\${s}.uniq.nodup.trMclean.bam METRICS_FILE=\${s}.uniq.trMclean.dup ASSUME_SORTED=TRUE REMOVE_DUPLICATES=true
wait
#igvtools count -z 10 -w 5 \$s.all.nodup.bam \$s.all.nodup.tdf \$Genomedir/\${Genome}.chrom.sizes
#igvtools count -z 10 -w 5 \$s.uniq.bam \$s.uniq.tdf \$Genomedir/\${Genome}.chrom.sizes
igvtools count -z 10 -w 5 \$s.uniq.nodup.bam \$s.uniq.nodup.tdf \$Genomedir/\${Genome}.chrom.sizes
#igvtools count -z 10 -w 5 \$s.uniq.nodup.trMclean.bam \$s.uniq.nodup.trMclean.tdf \$Genomedir/\${Genome}.chrom.sizes
wait
done
";
}
print OUT "
perl /Ubin/bin/trRNA.summary.pl $S $prj{'prj'}.trRNA.log
perl /home/yangfan/Data/Bin/perl_script_my/final/Alignment.summary.pl super.Alignment.sh
exit
";
my $str="";
$str = "--rf" if $prj{'fr'}==1;
$str = "--fr" if $prj{'fr'}==2;
print OUT "
sample=\"$sam\"
for s in \$sample
do
###stringtie -p 30 -e -b \$s.ballgown -G \$Genomedir/\$Genome.gtf -o \$s.assembly.gtf -C \$s.covered.gtf -A \$s.abun \$s.trMclean.bam
stringtie -p 30 -e -b \$s.ballgown -G \$Genomedir/\$Genome.gtf -o \$s.assembly.gtf -C \$s.covered.gtf -A \$s.abun \$s.uniq.nodup.bam
wait
#  -s no -s yes -s reverse
htseq-count -f bam -r name -m intersection-nonempty -s no \$s.uniq.bam -i gene_id -t exon \$Genomedir/\$Genome.gtf 1>\$s.exp 2>\$s.err
#htseq-count -f bam -r name -m union -s reverse \$s.uniq.bam -i transcript_id \$Genomedir/\$Genome.gtf -o \$s.htseq.bam -p bam -n 30
wait
grep __ -v \$s.exp > \$s.clean.exp
wait
done
";
my $taxon=9606;
$taxon=10090 if $prj{'species'} eq "mm10";
(my $abun=$S) =~ s/,/.abun,/g;
$abun .=".abun";
print OUT "
perl \$bin/StringTie.summary.pl $abun $prj{'prj'}.nor
perl /home/yangfan/Data/Bin/perl_script_my/final/RPKM.calculation.pl \$Genomedir/\$Genome.transcript.len $S -id gene_id -o $prj{'prj'}.exp
#perl \$bin/StringTie.summary.pl $abun $prj{'prj'}
## 以下可根据参数选择normalize
#perl /home/yangfan/Data/Bin/perl_script_my/final/RPKM.normalization.pl $prj{'prj'}.FPKM
#perl \$bin/fish.pl \$Genomedir/\$Genome.transcript.len.longest \$Genomedir/\$Genome.rawtranscript.bed -fish 4| perl \$bin/fish.pl - $prj{'prj'}.FPKM -bait 1,2,3,5 -fish 3,5,6,1 > $prj{'prj'}.uniq.FPKM

#Malab1: Jianzhao2/hMPV.RNASeq.cuffnorm/genes.fpkm_table ## 这是cufflink的结果
#perl \$bin/Symbol2GeneID.pl /Data/Database/ftp.ncbi.nih.gov/gene/DATA/gene_info.$taxon genes.fpkm_table 1
exit
";
print OUT "
# Deseq2 find differential genes(need biological replicates)
# Use /home/yangfan/Data/Bin/Run_useful_shells/deseq2.sh
# [heat-map] [VolcanoPlot] [correlation] [enrichment.analysis] : Use : /home/yangfan/Data/Bin/Run_useful_shells/RNA-seq
";
close OUT;
##############
sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}
Ptime("End");
