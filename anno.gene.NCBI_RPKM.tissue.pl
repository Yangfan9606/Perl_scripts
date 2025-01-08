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
use LWP::Simple qw(get);
#fuzzy_pattern($x,1);
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********#

Program : Use gene ID(ENTREZID) anno NCBI RPKM of sepcific tissue name ('bone marrow', 'full_rpkm': 4.71216)

Usage: .pl IN_file -o [out.name]
        -i                      gene id column [2]
        -t                      tissue name ('bone marrow' refer to NCBI description)
        -h                      header or not [0]
        -o                      out name
        -info                   output 27 tissue info
        -help                   output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "h:s", "c:s", "f:s", "t:s", "info:s", "help!");
##########
if (defined($opts{info})){
die "
# adrenal               肾上腺
# appendix              阑尾
# bone marrow
# brain
# colon
# duodenum              十二指肠
# endometrium           子宫内膜
# esophagus             食道
# fat
# gall bladder          胆囊
# heart
# kidney
# liver
# lung
# lymph node
# ovary                 卵巢
# pancreas              胰腺
# placenta              胎盘
# prostate              前列腺
# salivary gland        唾液腺
# skin
# small intestine       小肠
# spleen
# stomach
# testis
# thyroid               甲状腺
# urinary bladder       膀胱

        ";
}
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
open(IN, $infile) or die $!;
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";
open(OUT, ">$outname") or die $!;
my $gc = $opts{i} eq ""?1:$opts{i}-1;
my $H = $opts{h} eq ""?0:$opts{h};
my $T = $opts{t};
die "input tissue name use -t \n" if $T eq "";
print "Tissue of : '$T'\n";
#############
my %Lake;
while(<IN>){
        chomp;
        if (($H==1)&&($.==1)){
                print OUT "$_\t$T RPKM\n";
                next;
        }
        my @c = split/\t/;
        my $id = $c[$gc];
        my $url = "https://www.ncbi.nlm.nih.gov/gene/$id";
        my $html = get($url);
        my $OS;
        print "gene of $id ...\n";
        if ($html !~ /'$T', 'full_rpkm': /){
                print OUT "$_\tNA\n";
                next;
        }
        my @HTML = split/'$T', 'full_rpkm': /,$html;
        my @S = split/,/,$HTML[1];
        my $RPKM = $S[0];
        print OUT "$_\t$RPKM\n";
}
close IN;
#############

close OUT;

Ptime("End");
print "##########End############\n";
