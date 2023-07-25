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
use LWP::Simple qw(get);
#fuzzy_pattern($x,1);
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 根据gene ID(ENTREZID) 注释NCBI summary  (after anno.gene.description.pl)

Usage: .pl IN_file -o [out.name]
	-i			gene id column [2]
	-h			header or not [0]
	-o			out name
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "h:s", "c:s", "f:s", "help!");
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
open(IN, $infile) or die $!;
my $outname = $opts{o};
die "Input out name use -o\n" if $opts{o} eq "";
open(OUT, ">$outname") or die $!;
my $gc = $opts{i} eq ""?1:$opts{i}-1;
my $H = $opts{h} eq ""?0:$opts{h};
#############
my %Lake;
while(<IN>){
	chomp;
	if (($H==1)&&($.==1)){
		print OUT "$_\tOfficial_Symbol\tNCBI_summary\n";
		next;
	}
	my @c = split/\t/;
	my $id = $c[$gc];
	my $url = "https://www.ncbi.nlm.nih.gov/gene/$id";
	my $html = get($url);
	my $OS;
	if ($html !~ /Symbol<\/dt>/){
		$OS = "NA";
	}else{
		my @Osy= split/<dd class="noline">|<span class="prov">/,$html;
		$OS = $Osy[1];
	}
	if ($html !~ /<dt>Summary<\/dt>/){
		print OUT "$_\t$OS\tNA\n";
		next;
	}
	my @HTML = split/<dt>Summary<\/dt>/,$html;
	my @S = split/<dd>|<\/dd>/,$HTML[1];
	my $summary = $S[1];
	print OUT "$_\t$OS\t$summary\n";
}
close IN;

#############

close OUT;

Ptime("End");
print "##########End############\n";

