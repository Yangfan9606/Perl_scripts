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

Program : reads split to POS and NEG (R1主导or R2主导)

Usage: .pl \$s.B.uniq.bam -o [out.name].pos/.neg
	-R1			R1为主 (default)
	-R2			R2为主
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
my $infile1=shift;
open(IN,"samtools view $infile1|") or die $!;
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";
my $R=1;
if (defined ($opts{"R1"})){
	$R = 1;
}elsif(defined ($opts{"R2"})){
	$R = 2;
}
open(OUT1, ">$outname.NEG") or die $!;
open(OUT2, ">$outname.POS") or die $!;

#############
my %Lake;

my (%R1);
while(<IN>){
	chomp;
	my @temp = split/\t/;
	if (($temp[1]&64)==64){
		next if $R == 2;
		if (($temp[1]&16)==16){
			$R1{$temp[0]} = "NEG";
		}else{
			$R1{$temp[0]} = "POS";
		}
	}elsif(($temp[1]&128)==128){
		next if $R == 1;
		if (($temp[1]&16)==16){
			$R1{$temp[0]} = "NEG";
		}else{
			$R1{$temp[0]} = "POS";
		}
	}
}
close IN;
open(IN,"samtools view $infile1|") or die $!;
while(<IN>){
	chomp;
	my @temp = split/\t/;
	if ($R1{$temp[0]} eq "POS"){
		print OUT2 "$_\n";
	}elsif($R1{$temp[0]} eq "NEG"){
		print OUT1 "$_\n";
	}else{
		print "NO strand of $_\n";
	}
}
close IN;
#############

close OUT;

Ptime("End");
print "##########End############\n";

