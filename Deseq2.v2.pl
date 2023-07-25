#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 用deseq2.v2.sh计算deseq2

Usage: .pl deseq2.v2.sh
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

print "##########Start############\n";
Ptime("Start");
#############
my %prj;
my @sample;
my (%Lake,%P_group,%count_col);
my (@group,@PG);
my ($count,$Gname);

while(<INfile>){
	next if (/^#/);
	chomp;
	my @info = split/\s+/;
	my @temp = split/=/,$info[0];
	next if($temp[0] eq "");
	my $n = $temp[0];
	if ($n eq "sample"){
		@PG=split/;/,$temp[1];
		foreach my $t (@PG){
			my @P = split/\||,/,$t;
#			$P_group{$t}{'t'} = $P[0];
#			$P_group{$t}{'c'} = $P[1];
			foreach my $ts (@P){
				next if $Lake{$ts} == 1;
				$count++;
				push @sample,$ts;
				$Lake{$ts} = 1;
			}
		}
	}elsif($n eq "bam"){
	}elsif($n eq "group_name"){
		@group = split/,/,$temp[1];
		die "group name 与输入的比对组个数不对应！\n" if @group != @PG;
		for (my $i=0;$i<@group;$i++){
			my @P = split/\|/,$PG[$i];
			$P_group{$group[$i]}{'t'} = $P[0];
			$P_group{$group[$i]}{'c'} = $P[1];
			my @PC = split/\||,/,$PG[$i];
			foreach my $ts (@PC){
				$count_col{$group[$i]} .= $count_col{$group[$i]} eq ""?"\"$ts\"":",\"$ts\"";
			}
		}
	}else{
		$prj{$temp[0]}=$temp[1];
	}
}
close INfile;
my $pvalue = $prj{'pvalue_cutoff'};
my $padj = $pvalue == 0?$prj{'padj_cutoff'}:0;
my $cutoff = $pvalue == 0?"padj <= $padj":"pvalue <= $pvalue";
my $fc = $prj{'log2FC'};
my $fc_r = 0-$fc;
#############
my $sam;
my $saa=0;
my $S;
foreach (@sample){
	if ($saa==0){
	$sam= $_;
	$S = $_;
	$saa=1;
	}else{
		$sam .= " $_";
	$S .= ",$_";
}
}
###################
my $sf = $prj{'suffix'} eq ""?"":".".$prj{'suffix'};
open(OUT, ">$prj{'prj'}.deseq2.sh") or die $!;
print OUT "
Genome=$prj{'genome'}
Genomedir=$prj{'genomedir'}
bin=/Ubin/bin
sample=\"$sam\"
for s in \$sample
do";
print OUT "
samtools index \$s.bam -@ 21
wait"if $prj{'index'} == 1;
print OUT "
#stringtie -p 30 -e -b \$s.ballgown -G \$Genomedir/\$Genome.gtf -o \$s.assembly.gtf -C \$s.covered.gtf -A \$s.abun \$s.bam
wait" if $prj{'ReFPKM'} == 1;
print OUT "
htseq-count -f bam -r name -m intersection-nonempty -s ";
print OUT "no" if $prj{'fr'} == 0;
print OUT "yes" if $prj{'fr'} == 1;
print OUT "reverse" if $prj{'fr'} == 2;
print OUT " \$s$sf.bam -i gene_id -t exon \$Genomedir/\$Genome.gtf 1>\$s$sf.exp 2>\$s$sf.err
wait
grep __ -v \$s$sf.exp > \$s$sf.clean.exp
done\n
";
my $Cout;
for (my $c=2;$c<=$count*2;$c+=2){
	$Cout .= ",$c";
}
my ($Pout1,$Pout2,$Pexp);
my @S_sample = sort { ($a =~ /(\d+)/)[0] <=> ($b =~ /(\d+)/)[0] } @sample;
my %rank;
my $rc = 1;
my ($R_Names,$Pie_Names,$Po_Names);
foreach my $R(@S_sample){
	$rc ++;
	$rank{$R} = $rc;
	$Pout1 .= "\\t$R";
	$Pexp .= " $R$sf.clean.exp";
	$Pie_Names .= $Pie_Names eq ""?"$R$sf.clean.exp":",$R$sf.clean.exp";
	$Po_Names .= $Po_Names eq ""?"$R$sf":",$R$sf";
#	$R_Names .= "\"$R$sf\",";
	$R_Names .= "\"$R\",";
}
chop $R_Names;
print OUT "echo -en \"gene$Pout1\\n\" > $prj{'prj'}.count
paste$Pexp | cut -f1$Cout >> $prj{'prj'}.count
#perl /home/yangfan/Data/Bin/perl_script_my/final/pie.data.sum.pl $Pie_Names -name $Po_Names -o $prj{'prj'}.count";
my $dir=getcwd;
for (my $g=0;$g<@group;$g+=1){
	open (POUT1, ">$prj{'prj'}.$group[$g].condition") or die $!;
	print POUT1 "gene\tcondition\n";
	my @Rt = split/,/,$P_group{$group[$g]}{'t'};
	foreach my $R (@Rt){
		print POUT1 "$R\ttreated\n";
	}
	my @Rc = split/,/,$P_group{$group[$g]}{'c'};
	foreach my $R (@Rc){
		print POUT1 "$R\tcontrol\n";
	}
	close POUT1;
	print OUT "\nrm -rf $prj{'prj'}.$group[$g]\nR CMD BATCH $prj{'prj'}.$group[$g].deseq2.R\n";
	open (ROUT ,">$prj{'prj'}.$group[$g].deseq2.R") or die $!;
	print ROUT "
library(\"DESeq2\")
library(\"RColorBrewer\")
library(\"pheatmap\")
library(\"ggplot2\")
library(\"stringr\")
setwd(\"$dir/\")
path=\"$dir/\"
filelist <-c(\"$prj{'prj'}.$group[$g]\")
for (i in 1:length(filelist)) {
	countData<-read.table(file=str_c(\'$prj{'prj'}\','.count'),sep=\"\\t\",row.names = 1,header = T)
	names(countData) = c($R_Names);
	countData<- countData[ , c($count_col{$group[$g]})]
	countData = countData[which(rowSums(countData) > 0),]
	colData <- read.table(file=str_c(filelist[i],'.condition'),sep=\"\\t\",row.names = 1,header = T)
	dir.create(filelist[i])
	path1<- str_c(path,filelist[i])
	setwd(path1)
	colnames(countData) <- NULL
################## 注意dds的 condition, 在对应文件中默认是 按 字幕顺序，记得 check
#### ###########  B vs A，见 https://rstudio-pubs-static.s3.amazonaws.com/329027_593046fb6d7a427da6b2c538caf601e1.html
	dds <- DESeqDataSetFromMatrix(countData = countData,colData = colData,design = ~condition)
	dds <- DESeq(dds)#对 raw dds 进行normalize
	write.table(resultsNames(dds),file=str_c(filelist[i],'.vs.log'),sep=\"\t\",row.names=F)
	pdf(str_c(filelist[i],'.MAplot.pdf'),wi = 8,he = 8)
	plotMA(dds,ylim=c(-8,8),main='DESeq2: $group[$g]_Treat ($group[$g]_Control)')
	dev.off()
	res <- results(dds)
	resalldata <- merge(as.data.frame(res),as.data.frame(counts(dds,normalize = TRUE)),by=\"row.names\",sort=FALSE)
#	resalldata <- merge(as.data.frame(res),as.data.frame(counts(dds,normalize = F)),by=\"row.names\",sort=FALSE)
	write.table(resalldata,file=str_c(filelist[i],'.result.txt'),sep=\"\\t\",row.names = F)#保存所有计算的结果
#	diff_gene_deseq2 <- subset(resalldata,$cutoff & (log2FoldChange >= $fc | log2FoldChange <= $fc_r))
#	write.csv(diff_gene_deseq2,file=str_c(filelist[i],'.diffgene.csv'),row.names = F)#保存所有计算的结果
#	testdata <-diff_gene_deseq2[,8:ncol(diff_gene_deseq2)][1:nrow(diff_gene_deseq2),]
#	rownames(testdata) <-diff_gene_deseq2[,1]
#	colnames(testdata)
#	rownames(testdata)
#	High <- (15)
#	Widh <- (12)
#	pdf(str_c(filelist[i],'.diffgene_heatmap.pdf'),wi=Widh,he =High)
#	pheatmap(testdata,cluster_rows=T,cluster_cols=T,scale=\"row\",border_color=\"white\",color=colorRampPalette(rev(c(\"red\",\"ghostwhite\",\"blue\")))(100))
#	dev.off()
	setwd(\"$dir/\")
}
";
}
if ($prj{'ReFPKM'} == 1){
#my $name = $prj{'FPKM'};
#$name =~ s/\.FPKM$//;
my @TS = split/\ /,$sam;
my ($abun,$exp);
foreach my $s(@TS){
		$abun .= $abun eq ""?"$s$sf.abun":",$s$sf.abun";
		$exp .= $exp eq ""?"$s$sf":",$s$sf";
	}
print OUT "wait
###perl \$bin/StringTie.summary.pl $abun $prj{'prj'}.StringTie.RPKM
perl /home/yangfan/Data/Bin/perl_script_my/final/RPKM.calculation.pl \$Genomedir/\$Genome.transcript.len $exp -id gene_id -o $prj{'prj'}.RPKM
";
}else{
print OUT "wait
ln -s $prj{'FPKM'} .";
}
print OUT "
############################
# 注意 FPKM 的name 要跟input sample 的name一一对应 \$sample.\$suffix 为name, input bam为 \$sample.\$suffix.bam
# input 的deseq2 结果为 $prj{'prj'}.\$group[\$g].result.txt
#perl /home/yangfan/Data/Bin/perl_script_my/final/Deseq2.for_combine.pl deseq2.sh
wait
";
#$count = $count/2;
#my $fpkmnum= 6 + $count;
for (my $g=0;$g<@group;$g+=1){
#	last;
	print OUT "rm -rf $prj{'prj'}.$group[$g].result.txt\n";
	print OUT "ln -P $prj{'prj'}.$group[$g]/$prj{'prj'}.$group[$g].result.txt .\n";
	print OUT "sed -i 's/\"//g' $prj{'prj'}.$group[$g].result.txt\n";
	if ($prj{'genome'} eq "GRCh38_101"){
		if ($prj{'type'} eq "gene"){
		print OUT "head -1 $prj{'prj'}.$group[$g].result.txt |awk -F \"\\t\" '{print \"Gene\\t\"\$0}'> $prj{'prj'}.$group[$g].result.txt.head\n";
		print OUT "perl /Ubin/bin/fish.pl \$Genomedir/GRCh38_101.gene_id_name $prj{'prj'}.$group[$g].result.txt -bait 1 -fish 1 -cb 2 |cat $prj{'prj'}.$group[$g].result.txt.head - > $prj{'prj'}.$group[$g].Deseq2.results\n";
		print OUT "rm -rf $prj{'prj'}.$group[$g].result.txt.head\n";
		print OUT "perl /home/yangfan/Data/Bin/perl_script_my/final/deseq2.results.GRCh38_101.full.pl \$Genomedir/GRCh38_101.gene_id_name $prj{'prj'}.$group[$g].Deseq2.results  -o $prj{'prj'}.$group[$g].Deseq2.results.all\n";
		}elsif($prj{'type'} eq "transcript"){
			print "Use transcripts names...\n";
		print OUT "head -1 $prj{'prj'}.$group[$g].result.txt |awk -F \"\\t\" '{print \"Gene\\tName\\t\"\$0}'> $prj{'prj'}.$group[$g].result.txt.head\n";
		print OUT "perl /Ubin/bin/fish.pl \$Genomedir/GRCh38_101.gene_id_transcript.name $prj{'prj'}.$group[$g].result.txt -bait 6 -fish 1 -cb 1:2 |cat $prj{'prj'}.$group[$g].result.txt.head - > $prj{'prj'}.$group[$g].Deseq2.results\n";
		print OUT "rm -rf $prj{'prj'}.$group[$g].result.txt.head\n";
		print OUT "###perl /home/yangfan/Data/Bin/perl_script_my/final/deseq2.results.GRCh38_101.full.pl \$Genomedir/GRCh38_101.gene_id_name $prj{'prj'}.$group[$g].Deseq2.results  -o $prj{'prj'}.$group[$g].Deseq2.results.all\n";
		}
	}
#	print OUT "head -1 $prj{'prj'}.$group[$g].result.txt |cut -f1-7 > $prj{'prj'}.deseq2.head\n";
#	print OUT "head -1 $prj{'prj'}.$group[$g].$group[$g+1].FPKM > $prj{'prj'}.$group[$g].$group[$g+1].FPKM.head\n";
#	print OUT "paste $prj{'prj'}.$group[$g].$group[$g+1].deseq2.head $prj{'prj'}.$group[$g].$group[$g+1].FPKM.head > $prj{'prj'}.$group[$g].$group[$g+1].combine\n";
#	print OUT "perl /Ubin/bin/fish.pl $prj{'prj'}.$group[$g].$group[$g+1].result.txt $prj{'prj'}.$group[$g].$group[$g+1].FPKM -cb 1:7 >> $prj{'prj'}.$group[$g].$group[$g+1].combine
#rm -rf $prj{'prj'}.$group[$g].$group[$g+1].deseq2.head $prj{'prj'}.$group[$g].$group[$g+1].FPKM.head\n
#";
}
if ($prj{'genome'} eq "GRCh38_101"){
	if ($prj{'type'} eq "transcript"){
		print OUT "perl /home/yangfan/Data/Bin/perl_script_my/final/deseq2.results.GRCh38_101.transcript.pl ";
		for (my $g=0;$g<@group;$g+=1){
			print OUT ",$prj{'prj'}.$group[$g].Deseq2.results";
		}
		print OUT "\n";
	}
}
print OUT "################# final
####perl /home/yangfan/Data/Bin/perl_script_my/final/Deseq2.for_final_and_HeatMap.pl deseq2.sh\n";
close OUT;


################################
sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}
Ptime("End");
print "##########End############\n";
