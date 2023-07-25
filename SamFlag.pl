#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 计算sam,bam第二列的flag

Usage: .pl falg_num  -o out_name
	-help			output help information
	-o			输出到日志文件

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
#open(INfile, $infile) or die $!;
my $F=0;
if ($opts{o} ne ""){
	my $outfile=shift;
	$F = 1;
	open(OUT, ">$outfile.SamFlag.log") or die $!;
}

#############

$_ = $infile;
	print "$_  flag is:\n";
	print "$_  flag is:\n" if $F == 1;
	if (($_&1) == 1){
		print "\t1 => read paired\n";
		print OUT "\t1 => read paired\n" if $F == 1;
	}if(($_&2) == 2){
		print "\t2 => read mapped in proper pair\n";
		print OUT "\t2 => read mapped in proper pair\n" if $F == 1;
	}if(($_&4) == 4){
		print "\t4 => read unmapped\n";
		print OUT "\t4 => read unmapped\n" if $F == 1;
	}if(($_&8) == 8){
		print "\t8 => mate unmapped\n";
		print OUT "\t8 => mate unmapped\n" if $F == 1;
	}if(($_&16) == 16){
		print "\t16 => read reverse strand\n";
		print OUT "\t16 => read reverse strand\n" if $F == 1;
	}if(($_&32) == 32){
		print "\t32 => mate reverse strand\n";
		print OUT "\t32 => mate reverse strand\n" if $F == 1;
	}if(($_&64) == 64){
		print "\t64 => first in pair\n";
		print OUT "\t64 => first in pair\n" if $F == 1;
	}if(($_&128) == 128){
		print "\t128 => second in pair\n";
		print OUT "\t128 => second in pair\n" if $F == 1;
	}if(($_&256) == 256){
		print "\t256 => not primary alignment\n";
		print OUT "\t256 => not primary alignment\n" if $F == 1;
	}if(($_&512) == 512){
		print "\t512 => read fails platform/vendor quality checks\n";
		print OUT "\t512 => read fails platform/vendor quality checks\n" if $F == 1;
	}if(($_&1024) == 1024){
		print "\t1024 => read is PCR or optical duplicate\n";
		print OUT "\t1024 => read is PCR or optical duplicate\n" if $F == 1;
	}if(($_&2048) == 2048){
		print "\t2048 => supplementary alignment\n";
		print OUT "\t2048 => supplementary alignment\n" if $F == 1;
	}

#############

close OUT if $opts{o} ne "";
#close OUTlog;


