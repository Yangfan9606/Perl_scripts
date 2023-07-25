#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd;
use FindBin qw($Bin);
# $Bin为当前路径
use lib '/home/yangfan/Data/Bin/perl_script_my/final/';
use yangfan;
use Statistics::Descriptive;
use List::Util qw(shuffle);
#fuzzy_pattern($x,1);
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : input gene name (跑完可以用 anno.gene.NCBI_summary.pl 补充NCBI summary)

Usage: .pl [gene name file] -o [out.name].anno.txt
	-i			gene name column [1]
	-h			header or not [0]
	-type			gene name type [SYMBOL] (SYMBOL / ENSEMBL)
	-o			out name
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "h:s", "p:s", "q:s", "type:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $optko;
foreach my $opt(keys %opts){
	$optko .= " -$opt $opts{$opt}";
}
print "##########Start############ perl $0 @ARGV ($optko)\n";
Ptime("Start");
my $infile=shift;
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";
open(ROUT,">$outname.anno.R") or die $!;
my $gc = $opts{i} eq ""?1:$opts{i};
my $H = $opts{h} eq ""?0:$opts{h};
$H = $H == 0?"F":"T";
my $P = $opts{p} eq ""?1:$opts{p};
my $Q = $opts{q} eq ""?1:$opts{q};
my $type=$opts{type} eq ""?"SYMBOL":$opts{type};
my %T;
$T{SYMBOL} = 1;
$T{ENSEMBL} = 1;
die "Please check type input 'SYMBOL' or 'ENSEMBL' ? \n" if $T{$type} eq "";
my $TT = "\"$type\"";
$TT = "\"SYMBOL\",\"$type\"" if $T{ENSEMBL} == 1;
#############
my %Lake;
print ROUT"
#if (!requireNamespace(\"BiocManager\", quietly = TRUE))
#    install.packages(\"BiocManager\")
#BiocManager::install(\"org.Hs.eg.db\")
library(\"org.Hs.eg.db\")

file=read.table(file=\"$infile\",header = $H)
ids=as.vector(file[,$gc])
cols <- c($TT, \"ENTREZID\", \"GENENAME\")
anno=select(org.Hs.eg.db, keys=ids, columns=cols, keytype=\"$type\")
ido=as.data.frame(ids)
colnames(ido)=\"Original_name\"
anno.all=cbind(ido,anno)
write.table(anno.all,file=\"$outname.anno.txt\",sep=\"\t\",quote=F,row.names = F) #保存富集结果
";
system("R CMD BATCH $outname.anno.R");
#############

close OUT;

Ptime("End");
print "##########End############\n";

