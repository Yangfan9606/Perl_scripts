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

Program : Search NGG,+[CCN,-] (gRNA)

Usage: .pl [fa_file]
	-f			forward
	-b			backward after pam
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "f:s", "b:s", "help!");
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
open(INfile, $infile) or die $!;
my $f= $opts{f};
my $b= $opts{b};
# 4,3 Deep
# 0,4 JF
open(OUT, ">$infile.NGG.f${f}b$b.gRNA") or die $!;
#open(OUT1,">$infile1.gRNA.sup") or die $!;

#############
my %Lake;
my %chr;
my $C;
while(<INfile>){
	chomp;
	if (/^>/){
		my @test = split/>/;
		$C = $test[1];
		next;
	}
	$chr{$C} .= $_;
}
close INfile;
print "FA read done...\n";
my %gp;
foreach my $c(sort {$a cmp $b} keys %chr){
	my $seq = $chr{$c};
	while($seq=~/(?=([ATGC]{$f})([ATGC]{20})([ATGC]GG)([ATGC]{$b}))/gi){
		my $rf = uc $1;
		my $r = uc $2;
		my $pam = uc $3;
		my $rb = uc $4;
		my $as = $rf.$r.$pam.$rb;
		next if $gp{$c}{$r} == 1;
		print OUT "$c\t$r\t$pam\t+\t$as\n";
		$gp{$c}{$r} = 1;
	}
	while($seq=~/(?=([ATGC]{$b})(CC[ATGC])([ATGC]{20})([ATGC]{$f}))/gi){
		my $rb = uc $1;
		my $r = uc $3;
		my $pam = uc $2;
		my $rf = uc $4;
		my $as = $rb.$pam.$r.$rf;
		$as = reverse $as;
		$as =~ tr/ATGCatgc/TACGtacg/;
		$r = reverse $r;
		$r =~ tr/ATGCatgc/TACGtacg/;
		$pam = reverse $pam;
		$pam =~ tr/ATGCatgc/TACGtacg/;
		$r = uc $r;
		$pam = uc $pam;
		next if $gp{$c}{$r} == 1;
		print OUT "$c\t$r\t$pam\t-\t$as\n";
		$gp{$c}{$r} = 1;
	}
}
#############

close OUT;

Ptime("End");
print "##########End############\n";

