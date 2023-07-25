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
my $infile=shift;
open(INfile, $infile) or die $!;
open(OUT, ">$infile.NGG.gRNA") or die $!;
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
	while($seq=~/(?=([ATGC]{20})([ATGC]GG))/gi){
		my $r = uc $1;
		my $pam = uc $2;
		next if $gp{$c}{$r} == 1;
		print OUT "$c\t$r\t$pam\t+\n";
		$gp{$c}{$r} = 1;
	}
	while($seq=~/(?=(CC[ATGC])([ATGC]{20}))/gi){
		my $r = uc $2;
		$r = reverse $r;
		$r =~ tr/ATGCatgc/TACGtacg/;
		my $pam = uc $1;
		$pam = reverse $pam;
		$pam =~ tr/ATGCatgc/TACGtacg/;
		$r = uc $r;
		$pam = uc $pam;
		next if $gp{$c}{$r} == 1;
		print OUT "$c\t$r\t$pam\t-\n";
		$gp{$c}{$r} = 1;
	}
}
#############

close OUT;

Ptime("End");
print "##########End############\n";

