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

Program : 以所有bam_id区间为key,输出各自的count
	 PE reads 会去除insert overlap情况

Usage: .pl [bam.....]
	out 为 s.clean.exp
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "help!");
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
my @infile=split/,/,shift;
#open(INfile, $infile) or die $!;
#my $outname = $opts{o};
#die "Input out name use -o\n" if $opts{o} eq "";

#open(OUT, ">$outname") or die $!;

#############
my %Lake;
my %site;
foreach my $f(@infile){
	open(INfile, "samtools view $f|") or die $!;
	my %pe;
while(<INfile>){
	chomp;
	my @temp = split/\t/;
	my $name = $temp[0];
	my $seq = $temp[9];
	my $len = length $seq;
	my $s = $temp[3];
	my $e = $s + $len - 1;
	my $c = $temp[2];
	my $insert = abs $temp[8];
	if ($pe{$name} eq ""){
		$pe{$name} = "$c-$s-$e,$insert";
	}else{
		my @L = split/,/,$pe{$name};
		my @l = split/-/,$L[0];
		my ($lc,$ls,$le) = ($l[0],$l[1],$l[2]);
		if ($l[0] ne $c){
			$Lake{$f}{$L[0]} += 1;
			$site{$L[0]} += 1;
			$Lake{$f}{"$c-$s-$e"} += 1;
			$site{"$c-$s-$e"} = 1;
		}else{
			if ($s<=$ls){
				if ($e>=$ls){
					$Lake{$f}{"$c-$s-$le"} += 1;
					$site{"$c-$s-$le"} = 1;
				}else{
			$Lake{$f}{$L[0]} += 1;
			$site{$L[0]} += 1;
			$Lake{$f}{"$c-$s-$e"} += 1;
			$site{"$c-$s-$e"} = 1;
				}
			}else{
				if ($le>=$s){
					$Lake{$f}{"$c-$ls-$e"} += 1;
					$site{"$c-$ls-$e"} = 1;
				}else{
			$Lake{$f}{$L[0]} += 1;
			$site{$L[0]} += 1;
			$Lake{$f}{"$c-$s-$e"} += 1;
			$site{"$c-$s-$e"} = 1;
				}
			}
		}
	}
	$Lake{$f}{"$c-$s-$e"} += 1;
	$site{"$c-$s-$e"} = 1;
}
close INfile;
}
foreach my $f(@infile){
	my $oname = $f;
	$oname =~ s/\.bam//;
	open(OUT, ">$oname.clean.exp") or die $!;
	foreach my $pos(sort {$a <=> $b} keys %site){
		$Lake{$f}{$pos} += 0;
		my $n = $Lake{$f}{$pos};
		print OUT "$pos\t$n\n";
	}
	close OUT;
}

#############

close OUT;

Ptime("End");
print "##########End############\n";

