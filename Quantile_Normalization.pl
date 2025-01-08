#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd;
use FindBin qw($Bin);
# $Bin为当前路径
use lib '/home/yangfan/Data/Bin/perl_script_my/final/';
use yangfan;
### sort { getnum($a) <=> getnum($b) }
use Statistics::Descriptive;
use List::Util qw(shuffle);
use List::MoreUtils qw(uniq);
#fuzzy_pattern($x,1);
use POSIX;
# POSIX::round($x);  四舍五入
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********#

Program : Processing the file

Usage: .pl [input_matrix] -o [out.name]
        -o                      out name
        -help                   output help information

USAGE
GetOptions(\%opts,"a:s","b:s","c:s","d:s","e:s","f:s","g:s","h:s","i:s","j:s","k:s","l:s","m:s","n:s","o:s","p:s","q:s","r:s","s:s","t:s","u:s","v:s","w:s","x:s","y:s","z:s","head:s", "help!");
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
open(IN, $infile) or die $!;
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";

open(OUT, ">$outname") or die $!;

#############
my %Lake;
my $header= <IN>;
my @data;
my @gene_names;
while(<IN>){
        chomp;
        my @c = split/\t/;
        push @gene_names, shift @c;
        push @data, \@c;
}
close IN;

# 获取行数和列数
my $num_genes = scalar(@data);
my $num_samples = scalar(@{$data[0]});
print "total lines = $num_genes ... sample number = $num_samples\n";
my @sorted_data;
for my $sample (0 .. $num_samples - 1) {
    my @sample_data = map { $data[$_][$sample] } 0 .. $num_genes - 1;
    my @sorted_sample = sort { $a <=> $b } @sample_data;
    push @sorted_data, \@sorted_sample;
}
# 计算每个排名的平均值
my @rank_means;
for my $gene (0 .. $num_genes - 1) {
    my $sum = 0;
    for my $sample (0 .. $num_samples - 1) {
        $sum += $sorted_data[$sample][$gene];
    }
    my $mean = $sum / $num_samples;
    push @rank_means, $mean;
}
# 构建新的归一化数据矩阵
my @normalized_data;
for my $sample (0 .. $num_samples - 1) {
    my @sample_data = map { $data[$_][$sample] } 0 .. $num_genes - 1;
    my @sorted_indices = sort { $sample_data[$a] <=> $sample_data[$b] } 0 .. $#sample_data;
    my @normalized_sample;
    for my $rank (0 .. $#sorted_indices) {
        $normalized_sample[$sorted_indices[$rank]] = $rank_means[$rank];
    }
    push @normalized_data, \@normalized_sample;
}
# 输出归一化后的数据
print "Quantile Normalized Data ... \n";
print OUT "$header";
for my $gene (0 .. $num_genes - 1) {
        print OUT "$gene_names[$gene]\t";
    for my $sample (0 .. $num_samples - 1) {
        print OUT $normalized_data[$sample][$gene], "\t";
    }
    print OUT "\n";
}

#############

close OUT;

Ptime("End");
print "##########End############ perl $0 @ARGV ($optko)\n";
