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

Program : make fa use sequence,out [in_name.fa], fa name = [in_file+num]

Usage: .pl [input file withe sequence] -i [1/2/3/4/5/6...] -h [0/1]
	-o			outname
	-i			input column [1]
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "i:s", "h:s", "o:s","help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
print "##########Start############ $0 @ARGV\n";
Ptime("Start");
my $infile=shift;
open(INfile, $infile) or die $!;
my $ic = $opts{i} eq ""?1:$opts{i};
my $hf = $opts{h} eq ""?0:1;
my $outname=$opts{o};
$outname = "$infile.fa" if $outname eq "";
open(OUT, ">$outname") or die $!;

#############
my %Lake;
my $n = 1;
while(<INfile>){
	next if ($_ =~ /^#/ || ($hf==1 && $. == 1));
	chomp;
	my @temp = split/\t/;
	my $name = ">${infile}_$n";
	print OUT "$name\n$temp[$ic-1]\n";
	$n++;
}
close INfile;

#############

close OUT;

Ptime("End");
print "##########End############\n";

