#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : Processing the file

Usage: .pl IN_file
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
open(INfile, $infile) or die $!;

open(OUT, ">run.blastn.sh") or die $!;
#open(OUTlog, ">$infile.$program.log") or die $!;

print "##########Start############\n";
Ptime("Start");
#############
my @fileRow;
my $line=0;
my %Lake;
my $inputrow;
my @sample;

while(<INfile>){
	$line++;
	chomp;
	my @temp = split/=/;
	$inputrow = @temp;
	if ($temp[0] eq "sample"){
		my @temp1 = split/\"/, $temp[1];
		@sample = split/ /,$temp1[1];
	}elsif($temp[0] eq "number"){
		$Lake{'line'} = ($temp[1]+1)*4;
		$Lake{'num'} = $temp[1];
	}elsif($temp[0] eq "file"){
		$Lake{'file'}=$temp[1];
	}
}
my @sample1=@sample;
foreach (@sample){
	if ($Lake{'file'} eq "bam"){
	open (FAfile, "samtools view -h $_.$Lake{'file'}|") or die $!;
	}else{
		open (FAfile, "$_.$Lake{'file'}") or die $!;
	}
	open (FAout, ">$_.un.$Lake{'num'}.fa") or die $!;
	my $count =0;
	while (<FAfile>){
		next if (/^@/);
		last if $count == $Lake{'num'};
		$count ++;
		chomp;
		my @temp = split/\t/;
		print FAout ">$temp[0]\n$temp[9]\n";
	}
	close FAfile;
	close FAout;
}
print OUT "sample=\"$sample1[0]";
my $first=shift @sample1;
foreach (@sample1){
	print OUT " $_"
}
print OUT "\"
for s in \$sample
do
blastn -query \$s.un.$Lake{'num'}.fa -db /Data/Database/ftp.ncbi.nlm.nih.gov/gene/DATA/nt -out \$s.un.$Lake{'num'}.out -num_threads 28
wait
done

perl /home/yangfan/Data/Bin/perl_script_my/final/Blast.out.summary.pl $first.un.$Lake{'num'}.out";
foreach (@sample1){
	print OUT ",$_.un.$Lake{'num'}.out"
}
print OUT " $Lake{'num'}";


#############

close INfile;
close OUT;
#close OUTlog;

sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}
Ptime("End");
print "##########End############\n";

