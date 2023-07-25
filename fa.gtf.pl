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

Program : fasta to gtf

Usage: .pl [fa] -o [out.name]
	-o			out name
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
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";

open(OUT, ">$outname") or die $!;

#############
my %Lake;

while(<INfile>){
	next unless $_ =~ /^>/;
	my $L1 = $_;
	my $L2 = <INfile>;
	chomp $L1;
	chomp $L2;
	my $c = $L1;
	$c =~ s/>//;
	my $len = length $L2;
	print OUT "$c\tNA\texon\t1\t$len\t.\t+\t.\tgene_id \"$c\"\n";
}
close INfile;

#############

close OUT;

Ptime("End");
print "##########End############\n";

