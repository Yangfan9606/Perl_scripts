#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 输入 染色体及位置信息,从fa文件中得到seq序列

Usage: .pl [fa_file] [chrome] [start] [end]
	-l		length
			/Data/Database/hg38/GRCh38.fa
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "help!");
##########
die $usage if ( @ARGV!=4 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
open(INfile, $infile) or die $!;
my $chr = shift;
my $start = shift;
$start -= 1;
my $end = shift;
die "\n终止位置要比起始大\n\n" if $end <= $start;
#############
my %Lake;
my $flag = 0;
my $chrseq;
while(<INfile>){
	chomp;
	if (/^>/){
		my @test = split/>| /;
		next if $test[1] ne $chr;
		$flag = 1;
		next;
	}
	next if $flag == 0;
	$chrseq .= $_;
}
die "\n染色体信息不对？\n" if $chrseq eq "";
my $len = $end - $start;
my $seq = substr($chrseq,$start,$len);
print "\n$seq\n\n";

#############

close INfile;
