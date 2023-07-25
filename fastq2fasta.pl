#!/usr/bin/env perl
use warnings;


if (@ARGV < 1) {
	print STDERR "<fastq file> (STD IN)\n";
	print STDERR "Will output a FASTA file (STD OUT)\n";
	exit;
}


open IN, $ARGV[0];
my $good = 0;
while (<IN>) {
	next unless $_ =~ /^@/;
	my $L1 = $_;
	my $L2 = <IN>;
	chomp $L1;
	chomp $L2;
	$L1 =~ s/^\@//;
	$L1 =~ s/ /_/g;
	print ">$L1\n";
	print "$L2\n";
}
close IN;
