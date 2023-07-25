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

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : PE reads out to bed (使用properly pair reads), 染色体不同输出到日志
	根据bam第六列进行计算, (I)减去,(MDN)加上,其他情况程序输出到日志检查;
	flag 64+16 标记为 - 链

Usage: .pl [uniq.bam] -o [out.name]
	-MAPQ			MAPQ >= [0]
	-o			out name
	-sort			output sort by [p] (p/n) pos/name
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "len:s", "dis:s", "MAPQ:s", "sort:s", "help!");
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
open(INfile,"samtools view $infile|") or die $!;
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";
my $ilen = $opts{len} eq""?300:$opts{len};
my $sF = $opts{sort} eq ""?"p":$opts{sort};
if ($sF eq "p"){
	open(BED, "|sort -k1,1 -k2,2n >$outname") or die $!;
}else{
	open(BED, "|sort -k5V >$outname") or die $!;
}
#open (C_check, ">$outname.CIGAR.check") or die $!;
my $dis = $opts{dis} eq ""?0:$opts{dis};
my $MAPQ = $opts{MAPQ} eq ""?0:$opts{MAPQ};

#############
my %Lake;
my (%pe,%U,%B,%chr,%Rpos,%S,%R1,%R2);
my (%out,%reads,%out);
while(<INfile>){
	chomp;
	my @temp = split/\t/;
	my $name = $temp[0];
	my $c = $temp[2];
	my $q = $temp[4];
	next if $q < $MAPQ;
	my $seq = $temp[9];
	my $len = length $seq;
	my $s = $temp[3];
	my $e = $s + $len - 1;
	my $insert = abs $temp[8];
	my $T = $temp[5];
	my ($l,$s1,$s2,$e1,$e2,$sf);
	$s1 = $s;
	if ($T =~ /^(\d+)([A-Z])/){
		if ($2 eq "M" || $2 eq "D"){
			$l += $1;
		}elsif($2 eq "I"){
			$l -= $1;
		}else{
#			print C_check "check CIGAR\tnot_M|I|D\t$_\n";
			print "check CIGAR\tnot_M|I|D\t$_\n";
		}
	}
	while($T=~/(?=[A-Z](\d+)([A-Z]))/g){
		if ($2 eq "M" || $2 eq "D" || $2 eq "N"){
			$l += $1;
		}elsif($2 eq "I"){
			$l -= $1;
		}else{
#			print C_check "check CIGAR\tnot_M|I|D|N\t$_\n";
			print "check CIGAR\tnot_M|I|D|N\t$_\n";
		}
	}
	if ($out{$name} eq ""){
		$reads{$name} = $_;
		$e1 = $s1 + $l - 1;
		$out{$name} = "$c;$T;$s1,$e1;$temp[1];0";
	}else{
		my @O = split/;/,$out{$name};
		my $chr1 = $O[0];
		my ($t1,$t2) = ($T,$O[1]);
		print "check_2\tchr\t$_\n" if $chr1 ne $c;
		my ($f1,$f2) = ($temp[1],$O[-2]);
		my $Strand = "+";
		$Strand = "-" if ((($f1&64)==64)&&(($f1&16)==16));
		$Strand = "-" if ((($f2&64)==64)&&(($f2&16)==16));
		$e1 = $s1 + $l - 1;
		my $all = "$O[2],$s1,$e1";
		my @p = split/,/,$all;
		my @pos = sort { $a <=> $b } @p;
		my ($S,$E) = ($pos[0],$pos[-1]);
		my $L = $E - $S + 1;
		print BED "$c\t$S\t$E\t$L\t$name\t$Strand\t$t1($f1),$t2($f2)\t$insert\n";
#			print "$reads{$name}\n$_\n";
		delete $out{$name};
		delete $reads{$name};
	}
}
close INfile;
#############

close OUT;

Ptime("End");
print "##########End############\n";

