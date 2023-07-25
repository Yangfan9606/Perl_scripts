
use strict;

#
#

if (@ARGV != 3) {
	print "usage: .pl bowtie.log file1,file2 out\n";
	exit;
}

my $infile1 = shift;
open(IN1, "$infile1") or die $!;
my @infile = split/,/, shift;
my $outfile = shift;
open(OUT, ">$outfile") or die $!;

my %Sum;
my $i=0;
while (<IN1>) {
# reads processed: 29041893
# reads with at least one reported alignment: 4711510 (16.22%)
# reads that failed to align: 16536462 (56.94%)
# reads with alignments sampled due to -M: 7793921 (26.84%)
	next if (!/^#/);
	if(/# reads processed: (\d+)/){
		my $input = $1;
		print "total $1\n";
		$Sum{$infile[$i]}{'Input'} = $input;
	}elsif(/# reads that failed to align: (\d+)\s\([\d\.]+\%\)/){
		my $unmap = $1;
		print "unmap $1\n";
		$Sum{$infile[$i]}{'Mapped'} = $Sum{$infile[$i]}{'Input'} - $unmap;
		$i++;
	}
}
close IN1;

$"="\t";
print OUT "\t@infile\n";
my @order=('Input','Mapped');

for(my$r=0;$r<@order;$r++){
	print OUT "$order[$r]";
	for(my$i=0;$i<@infile;$i++){
		print OUT "\t$Sum{$infile[$i]}{$order[$r]}";
	}
	print OUT "\n";
}
close OUT;



