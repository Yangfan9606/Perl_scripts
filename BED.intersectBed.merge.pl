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

Program : intersectBed 的peak进行合并[取并集], 输入2个bed的chr列即可

Usage: .pl [IN_file] -b -o [out.name]
	-b			bed 2 的 chr 列 (必须参数)
	-s			是否有strand信息 [0] (0/1) (默认bed 1 第六列)
	-o			out name
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "b:s", "s:s", "help!");
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
my $bc = $opts{b};
die "Input bed 2 chr column use -b\n" if $opts{b} eq "";
my $sflag = $opts{s} eq ""?0:$opts{s};
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";

open(OUT, ">$outname") or die $!;

#############
my %Lake;

while(<IN>){
	chomp;
	my @col = split/\t/;
	my ($c1,$s1,$e1) = ($col[0],$col[1],$col[2]);
	my ($c2,$s2,$e2) = ($col[$bc-1],$col[$bc],$col[$bc+1]);
	if ($c1 != $c2){
		die "check input bed 2 chr ($c2)\n";
	}
	my ($info1,$info2);
	my $strand;
	$strand = $col[5] if $sflag == 1;
	for (my $i=0;$i<$bc-1;$i++){
		$info1 .= "$col[$i],";
	}
	chop $info1;
	for (my $i=$bc-1;$i<@col;$i++){
		$info2 .= "$col[$i],";
	}
	chop $info2;
	my $L;
	if ($s1<=$s2 && $e1 <= $e2){
		$L = $e1 - $s2 + 1;
	}elsif($s2<=$s1 && $e2 <= $e1){
		$L = $e2 - $s1 + 1;
	}elsif($s1<=$s2 && $e2<=$e1){
		$L = $e2 - $s2 + 1;
	}elsif($s2<=$s1 && $e1<=$e2){
		$L = $e1 - $s1 + 1;
	}else{
		print "other overlap of ($s1,$e1 | $s2,$e2)$_\n";
	}
	my @P = ($s1,$s2,$e1,$e2);
	@P = sort {$a <=> $b} @P;
	print OUT "$c1\t$P[0]\t$P[-1]\t$info1\t$info2\t$strand\t$L\n";
}
close IN;

#############

close OUT;

Ptime("End");
print "##########End############\n";

