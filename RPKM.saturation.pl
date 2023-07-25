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

Program : Processing the file

Usage: .pl [RPKM] -name [HEB_1,HEB_2...] -f [0.2,0.4,0.6,0.8] -o [out.name]
	-name			sample name [HEB_1,HEB_2...]
	-f			fraction [0.2,0.4,0.6,0.8]
	-o			out name
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "name:s", "f:s", "help!");
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
my @name = split/,/,$opts{name};
my @fr = split/,/,$opts{f};
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";

open(OUT, ">$outname") or die $!;

#############
my %Lake;
my %col;
while(<INfile>){
	chomp;
	my @temp = split/\t/;
	for (my $i=1;$i<@temp;$i++){
		$col{$temp[$i]} = $i+1;
#HEB_1   HEB_1.0.2       HEB_1.0.4
	}
	last;
}
close INfile;
my ($H,$T);
foreach my $n(@name){
	$H .= $H eq ""?$n:"\t$n";
	my $i = $col{$n};
	my $num = `cat $infile|awk -F \"\\t\" '\$$i>=1{print \$0}'|wc -l`;
	$num -= 1;
	$T .= $T eq ""?$num:"\t$num";
}
print OUT "$H\n";
foreach my $f(@fr){
	my $o;
	foreach my $n(@name){
		my $i = $col{"$n.$f"};
		my $num = `cat $infile|awk -F \"\\t\" '\$$i>=1{print \$0}'|wc -l`;
		$num -= 1;
		$o .= $o eq ""?$num:"\t$num";
	}
	print OUT "$o\n";
}
print OUT "$T\n";


#############

close OUT;

Ptime("End");
print "##########End############\n";

