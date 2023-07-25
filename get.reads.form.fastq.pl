#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 直接根据reads name从fastq中找出这个reads的信息

Usage: .pl reads_name fq/clipper_file

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "help!");
##########
die $usage if ( @ARGV!=2 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $read=shift;
my $infile=shift;

open(INfile, $infile) or die $!;

#############
my @fileRow;
my $line=0;
my %Lake;
my $inputrow;

while(<INfile>){
	next if (!/^@/);
	my $a=$_;
	chomp;
	my @temp = split/ |@/;
	if ($temp[1] eq $read){
		my $b=<INfile>;
		my $c=<INfile>;
		my $d=<INfile>;
		print "↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓\n$a$b$c$d↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ \n";
		last;
	}
}

#############

close INfile;


