#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd;
use lib '/home/yangfan/Data/Bin/perl_script_my/final/';
use yangfan;
use Statistics::Descriptive;
use List::Util qw(shuffle);

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : Processing the file 根据行分割文件

Usage: .pl IN_file
	-s			按行数分割
	-h			header or not [0] (0/1)
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "h:s", "o:s", "s:s", "i:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
print "##########Start############ perl $0 @ARGV\n";
Ptime("Start");
my $infile=shift;
open(INfile, $infile) or die $!;
die "\n输入分割行数 ：-s \n\n" if $opts{s} eq "";
my $s = $opts{s};
my $h = $opts{h} eq ""?0:1;

#############
my %Lake;
my $n=1;
my $l=1;
while(<INfile>){
	chomp;
	next if ($_ =~ /^#/ || ($h==1 && $.==1));
	if ($l<=$s){
		open(OUT, ">$infile.$n") or die $! if $l == 1;
		print OUT "$_\n";
		$l++;
	}else{
		close OUT;
		$n++;
		$l=1;
		redo;
	}
}
close INfile;
close OUT;

#############

close OUT;

Ptime("End");
print "##########End############\n";

