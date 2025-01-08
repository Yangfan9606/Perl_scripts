#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd;
use FindBin qw($Bin);
# $Bin为当前路径
use lib '/home/yangfan/Data/Bin/perl_script_my/final/';
use yangfan;
### sort { getnum($a) <=> getnum($b) }
use Statistics::Descriptive;
use List::Util qw(shuffle);
use List::MoreUtils qw(uniq);
#fuzzy_pattern($x,1);
use POSIX;
# POSIX::round($x);  四舍五入
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********#

Program : Random select from .fa

Usage: .pl [] -o [out.name]
        -s                      number of select
        -o                      out name
        -help                   output help information

USAGE
GetOptions(\%opts,"a:s","b:s","c:s","d:s","e:s","f:s","g:s","h:s","i:s","j:s","k:s","l:s","m:s","n:s","o:s","p:s","q:s","r:s","s:s","t:s","u:s","v:s","w:s","x:s","y:s","z:s","head:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $optko;
foreach my $opt(keys %opts){
        $optko .= " -$opt $opts{$opt}";
}
#print "##########Start############ perl $0 @ARGV ($optko)\n";
#Ptime("Start");
my $infile=shift;
open(IN, $infile) or die $!;
my $outname = $opts{o};
my $num = $opts{s};
die "Input out name use -o\n" if $opts{o} eq "";

open(OUT, ">$outname") or die $!;

#############
my %Lake;

while(<IN>){
        next unless $_ =~ /^>/;
        my $L1 = $_;
        my $L2 = <IN>;
        chomp ($L1,$L2);
        $Lake{$L1} = $L2;
}
close IN;
my $n = 0;
foreach my $k(keys %Lake){
        $n++;
        print OUT "$k\n$Lake{$k}\n";
        last if $n >= $num;
}

#############

close OUT;

#Ptime("End");
#print "##########End############ perl $0 @ARGV ($optko)\n";
