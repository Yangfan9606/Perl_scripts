#!/usr/bin/perl
use strict;
use Cwd;
use FindBin qw($Bin);
#
if (@ARGV != 1) {
	print "usage: .pl \$s1,\$s2\n\t默认：\$s1.STARLog.final.out \n";
	exit;
}
my @files = split/,/,shift;
my %info;
my $n=1;
my $head;
foreach my $f(@files){
	open(IN,"$f.STARLog.final.out") or die $!;
	$head .= "\t$f";
	while(<IN>){
		chomp;
		if(/\s+Number of input reads \|\t(\d+)/){
			$info{'Input'}{$n} = $1;
		}elsif(/\s+ Uniquely mapped reads number \|\t(\d+)/){
			$info{'Uniq'}{$n} = $1;
		}elsif(/\s+ Uniquely mapped reads \% \|\t(\d+)\.(\d+)\%/){
			$info{'Uniq_P'}{$n} = "$1.$2%";
		}elsif(/\s+ Number of reads mapped to multiple loci \|\t(\d+)/){
			$info{'Multi'}{$n} = $1;
		}elsif(/\s+\% of reads mapped to multiple loci \|\t(\d+)\.(\d+)\%/){
			$info{'Multi_P'}{$n} = "$1.$2%";
		}elsif(/\s+ Number of reads mapped to too many loci \|\t(\d+)/){
			$info{'MultiM'}{$n} = $1;
		}elsif(/\s+\% of reads mapped to too many loci \|\t(\d+)\.(\d+)\%/){
			$info{'MultiM_P'}{$n} = "$1.$2%";
		}elsif(/\s+ Number of reads unmapped: too many mismatches \|\t(\d+)/){
			$info{'Mis'}{$n} = $1;
		}elsif(/\s+\% of reads unmapped: too many mismatches \|\t(\d+)\.(\d+)\%/){
			$info{'Mis_P'}{$n} = "$1.$2%";
		}elsif(/\s+ Number of reads unmapped: too short \|\t(\d+)/){
			$info{'Short'}{$n} = $1;
		}elsif(/\s+\% of reads unmapped: too short \|\t(\d+)\.(\d+)\%/){
			$info{'Short_P'}{$n} = "$1.$2%";
		}
	}
	close IN;
	$n++;
}
open(OUT, ">STAR.summary.log") or die $!;
print OUT "$head\n";
my $L1 = "Input";
my $L2 = "Uniq";
my $L3 = "Uniq %";
my $L4 = "multiple loci";
my $L5 = "multiple loci %";
my $L6 = "too many loci";
my $L7 = "too many loci %";
my $L8 = "too many mismatches";
my $L9 = "too many mismatches %";
my $L10 = "too short";
my $L11 = "too short %";
for (my $i=1;$i<=$n;$i++){
	$L1 .= "\t".$info{'Input'}{$i};
	$L2 .= "\t".$info{'Uniq'}{$i};
	$L3 .= "\t".$info{'Uniq_P'}{$i};
	$L4 .= "\t".$info{'Multi'}{$i};
	$L5 .= "\t".$info{'Multi_P'}{$i};
	$L6 .= "\t".$info{'MultiM'}{$i};
	$L7 .= "\t".$info{'MultiM_P'}{$i};
	$L8 .= "\t".$info{'Mis'}{$i};
	$L9 .= "\t".$info{'Mis_P'}{$i};
	$L10 .= "\t".$info{'Short'}{$i};
	$L11 .= "\t".$info{'Short_P'}{$i};
}
print OUT "$L1\n$L2\n$L3\n$L4\n$L5\n$L6\n$L7\n$L8\n$L9\n$L10\n$L11\n";
close OUT;



