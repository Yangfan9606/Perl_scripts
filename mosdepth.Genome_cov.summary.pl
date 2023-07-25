#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : Processing the file

Usage: .pl name1,name2,name3... -o [outname]
	-M			[0/1] cal chrM cov default not[0]
	-help			output help information

USAGE

GetOptions(\%opts, "i:s", "l:s", "b:s", "o:s", "u:s", "M:s","help!");
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
#D3.genome.cov
my @infile=split/,/,shift;
my $name=$opts{o};
my $Mt = $opts{M} eq ""?0:$opts{M};
#############
my %Lake;
my $head="#Depth";
my %avg;
my @DP;
foreach my $f(@infile){
	$head .= "\t$f";
	open(INfile,"zcat $f.cov.thresholds.bed.gz|") or die $!;
	open(FOUT,"> $f.cov.summary") or die $!;
	my $n = 0;
	my $t = 0;
	my @Dp;
while(<INfile>){
	$n++;
	chomp;
	my @temp = split/\t/;
	if ($.==1){
		$n--;
		print FOUT "$temp[0]\t$temp[1]\t$temp[2]";
		for (my $i=4;$i<@temp;$i++){
			print FOUT "\t$temp[$i]";
			push @Dp,$temp[$i];
		}
		print FOUT "\n";
		print "Dp(@Dp)\n";
		next;
	}
	my $ct = $temp[2];
	print FOUT "$temp[0]\t$temp[1]\t$temp[2]";
	for (my $i=4;$i<@temp;$i++){
		my $cov = $temp[$i]/$ct;
		print FOUT "\t$cov";
		$Lake{$f}{$Dp[$i-4]} += $cov if ($temp[0] !~ /M/);
		print "\t$f\t$cov\t$Dp[$i-4]\n" if ($i==4);
	}
	print FOUT "\n";
}
$n--;
@DP = @Dp;
foreach my $d(@Dp){
	print "\t\n\t$f\t$Lake{$f}{$d} / $n\n";
	my $a = $Lake{$f}{$d}/$n;
	$avg{$d} .= "\t$a";
}
close INfile;
}
open(OUT, "> $name") or die $!;
print OUT "$head\n";
foreach my $d(@DP){
	print OUT "$d$avg{$d}\n";
}
#############
close OUT;

sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}
Ptime("End");
print "##########End############\n";

