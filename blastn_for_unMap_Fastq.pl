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

Program : input Fastq 随机取指定条做blast

Usage: .pl IN_file.fastq -n [1000]
	-n		 随机取 [x], 1000 by default
	-help			output help information

USAGE

GetOptions(\%opts, "n:s", "b:s", "o:s", "u:s", "i:s", "help!");
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
my $n = $opts{n} eq ""?1000:$opts{n};
open(OUTFA, ">$infile.blatn.fa") or die $!;
open(OUT, ">$infile.blatn.sh") or die $!;

#############
my %Lake;

while(<INfile>){
	next if $_ !~ /^@/;
	my $L1 = $_;
	my $L2 = <INfile>;
	chomp $L1;
	chomp $L2;
	my @temp = split/\ /,$L1;
	my $name = ">$temp[0]";
	$Lake{$name} = $L2;
}
close INfile;
my @reads = keys %Lake;
my @shu_reads = shuffle(@reads);
for (my $i=0;$i<$n;$i++){
	print OUTFA "$shu_reads[$i]\n$Lake{$shu_reads[$i]}\n";
}
print OUT"
blastn -query $infile.blatn.fa -db /Data/Database/ftp.ncbi.nih.gov/gene/DATA/nt -out $infile.un.blast.out -num_threads 12
wait
perl /home/yangfan/Data/Bin/perl_script_my/final/Blast.out.summary.pl $infile.un.blast.out
";

#############

close OUT;

Ptime("End");
print "##########End############\n";

