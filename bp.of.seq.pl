#!/usr/bin/perl
use strict;
use Getopt::Long;
use lib '/home/yangfan/Data/Bin/perl_script_my/final/';
use yangfan;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 显示一段序列多少bp, -r <reverse> -rc <reverse complementary> -c <complementary> -uc <全变成大写> -lc <全变成小写>

Usage: .pl ATGC....

USAGE

GetOptions(\%opts, "r:s", "rc:s", "o:s", "c:s", "uc:s", "lc:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;

#open(INfile, $infile) or die $!;

#open(OUT, ">$infile.one.out") or die $!;
#open(OUTlog, ">$infile.$program.log") or die $!;

#############
my @fileRow;
my $line=0;
my %Lake;
my $inputrow;
my @temp = split//,$infile;
print @temp."\n";
my $out_seq=$infile;

my $c = 0;
$c = 1 if defined $opts{c};
my $rc= 0;
$rc= 1 if defined $opts{rc};
my $r = 0;
$r = 1 if defined $opts{r};
my $uc = 0;
$uc= 1 if defined $opts{uc};
my $lc = 0;
$lc= 1 if defined $opts{lc};
if ($uc == 1 && $lc == 1){die "大小写必须分开！\n";}
if ($uc == 1){
	$infile =~ tr/atgcn/ATGCN/;
	$infile = uc $infile;
	print "$infile\n" if ($c == 0 && $r == 0 && $rc == 0);
	$out_seq = $infile if ($c == 0 && $r == 0 && $rc == 0);
}elsif ($lc == 1){
	$infile =~ tr/ATGCN/atgcn/;
	$infile = lc $infile;
	print "$infile\n" if ($c == 0 && $r == 0 && $rc == 0);
	$out_seq = $infile if ($c == 0 && $r == 0 && $rc == 0);
}
################################################
if ($c == 1){
	print "complementary :\n";
	$out_seq = ();
	foreach my $n(@temp){
		my $o = $n;
		$o =~ tr/ATGCatgc/TACGtacg/;
		print "$o";
		$out_seq .= $o;
	}
	print "\n";
}
if ($rc == 1){
	print "reverse complementary:\n";
	my $rseq = reverse $infile;
	my @seq = split//,$rseq;
	$out_seq = ();
	foreach my $n(@seq){
		my $o = $n;
		$o =~ tr/ATGCatgc/TACGtacg/;
		print "$o";
		$out_seq .= $o;
	}
	print "\n";
}
if ($r == 1){
	print "reverse :\n";
	my $rseq = reverse $infile;
	print "$rseq\n";
	$out_seq = $rseq;
}
my @S = split//,$out_seq;
my ($gc,$len);
my %base;
foreach my $b(@S){
	$len +=1 if ($b eq "G" || $b eq "C" ||$b eq "g" ||$b eq "c");
	$base{$b} += 1;
}
my $l = @S;
my $gc = $len/$l;
my $bout;
my %same;
foreach my $k(sort {$a cmp $b} keys %base){
	$bout .= "\t$k: $base{$k}";
	my $nk = lc $k;
	my $abc = $k eq $nk?$base{$k}:$base{$k} + $base{$nk};
	$bout .= "($abc)" if $same{$nk} eq "";
	$same{$nk} = 1;
}
print "GC: $gc$bout\n";
#############
my $tm = Tm($out_seq);
print "Tm: $tm\n";

#close INfile;
#close OUT;
#close OUTlog;

sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}

