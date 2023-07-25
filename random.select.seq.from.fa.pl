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

Program : 从fasta文件中随机选取指定的条数

Usage: .pl [fa] -r [N] -o [out.name]
	-r			random number
	-o			out name
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "r:s", "help!");
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
my $R = $opts{r};
die "input random number use -r\n" if $R eq "";
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";

open(OUT, ">$outname") or die $!;

#############
my @FA;

while(<INfile>){
	next unless $_ =~ /^>/;
	my $L1 = $_;
	my $L2 = <INfile>;
	my $o = "$L1$L2";
	push @FA,$o;
}
close INfile;
my @S_FA = shuffle(@FA);
my $N = @S_FA;
$R = $N if $R >= $N;
for (my $i=0;$i<$R;$i++){
	print OUT "$S_FA[$i]\n";
}

#############

close OUT;

Ptime("End");
print "##########End############\n";

