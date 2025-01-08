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

Program : Input gene ID(ENTREZID) , out NCBI RPKM of 27 tissues('full_rpkm': 4.71216)

Usage: .pl gene_id

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "h:s", "c:s", "f:s", "t:s", "help!");
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
#############
my %Lake;
        my $id = shift;
        my $url = "https://www.ncbi.nlm.nih.gov/gene/$id";
        my $html = get($url);
        my $OS;
        print "gene of $id ...\n\n";
        while($html=~/(?=('source_name': ')(\w+ ?\w+)(', 'full_rpkm': )([0-9]*\.[0-9]*)(, 'exp_rpkm':))/g){
                print "$2\t\t\t$4\n";
        }
close IN;

#############
print "\n";
close OUT;

Ptime("End");
print "##########End############\n";
