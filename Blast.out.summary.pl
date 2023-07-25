#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 统计blast out ,输出物种命和数量。

Usage: .pl IN_file1,IN_file2,IN_file3.... Total_Num_for_blast
	-k			查找:关键字(Homo,ribo,Mus等等)
	-l			搜索keywords时,向下搜索n行(default <查找分数最高的>)
	-fasta			t/f 是否输出keywords的fasta序列(default <f>)
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "k:s", "fasta:s", "help!");
##########
die $usage if ( @ARGV!=2 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my @infile=split/,/,shift;
my $total=shift;
#open(OUTlog, ">$infile.$program.log") or die $!;
my $keyflag=0;
my @tempribo;
my $keywords;
if ($opts{k} ne ""){
	$keyflag=1;
	$keywords = $opts{k};
}
my $rowR = 0;
$rowR = $opts{l} if $opts{l} ne "";
my $FastqFlag = 0;
$FastqFlag = 1 if $opts{f} eq "t";

if (($keywords==0) && ($FastqFlag==1)){
	die "use -k 'keywords' while use -f t !\n";
}

print "##########Start############\n";
Ptime("Start");
#############

#Sequences producing significant alignments:                 (Bits)  Value
foreach my $in(@infile){
open(INfile, $in) or die $!;
open(OUT, ">$in.blast.sum.out") or die $!;
open(OUT1, ">$in.$keywords.fa") or die $! if $FastqFlag==1;
my @fileRow;
my %Lake;
my $inputrow;
my $flag;
my $line=0;
my $num=0;
my %KW;
while(<INfile>){
	$line++;
	if ($flag == 1){
		$flag++;
		next;
	}
	chomp;
	if ($flag==2){
		$flag =0;
		my @temp2 = split/  /,$_;
		my @temp3 = split/ /,$temp2[0];
#		print "$temp3[0]\n";
		if ($keyflag==0){
		if (($temp3[0] eq "PREDICTED:") || ($temp3[0] eq "Uncultured")||($temp3[0] eq "Synthetic")||($temp3[0] eq "TPA:")){
			if ($temp3[1] eq "Homo"){
				$Lake{"$temp3[1] $temp3[2]"} += 1;
			}else{
#				$Lake{"$temp3[1] $temp3[2] $temp3[3]"} +=1;
				$Lake{"$temp3[1] $temp3[2]"} +=1;
			}
		}else{
			if ($temp3[0] eq "Homo"){
				$Lake{"$temp3[0] $temp3[1]"} += 1;
			}elsif($temp3[0] =~ /\.\d+$/){
				$Lake{"$temp3[1] $temp3[2]"} += 1;
			}else{
				print "\t(@temp3)//\n";
				$Lake{"$temp3[0] $temp3[1]"} +=1;
			}
		}
		}else{
			my $keywordsFLAG=0;
			if ($rowR != 0){
			for (my $i=1;$i<=$rowR;$i++){
				last if $rowR==1;
				my $next=<INfile>;
				chomp $next;
				last if $next eq "";
				$keywordsFLAG = 1 if ($next =~/$keywords/);
				last if $keywordsFLAG == 1;
			}
			}else{
			my @line = split//,$_;
			my $score=$line[70].$line[71].$line[72].$line[73];
#			print "$score\n";
			my $Srow;
			my $l;
			for ($l=1;$l<=100000;$l++){
				my $next=<INfile>;
				chomp $next;
				my @infoNext=split//,$next;
				my $scinfo=$infoNext[70].$infoNext[71].$infoNext[72].$infoNext[73];
				last if ($scinfo != $score);
			}
			print "$l\n";
			for (my $i=1;$i<=$l;$i++){
				my $next=<INfile>;
				chomp $next;
				$keywordsFLAG = 1 if ($next =~/$keywords/);
				last if $keywordsFLAG == 1;
			}
			}
			if (($_ =~ /$keywords/) || ($keywordsFLAG == 1)){
				$KW{"$keywords"} += 1;
				if ($FastqFlag==1){
					my $faFlag=0;
					my $lastfalg=0;
					for (my $i=1;$i<=100000;$i++){
						my $next1=<INfile>;
						chomp $next1;
						$faFlag += 1 if $next1 eq "";
						next if $faFlag == 0;
						next if $faFlag == 1;
						next unless $next1 =~ /Query/;
						my @outfa=split/\s+/,$next1;
						print OUT1 ">$keywords : $temp3[0] $temp3[1] $temp3[2]\n$outfa[2]\n";
						$lastfalg = 1 if $outfa[0] eq "Query";
						last if $lastfalg == 1;
				}
				}
			}else{
				$Lake{"$temp3[0] $temp3[1] $temp3[2]"} += 1;
			}
		}
		next;
	}
	if (/Sequences\sproducing\ssignificant\salignments:\s+\(Bits\)\s+Value/){
		$flag++;
		$num++;
	}
}
print "$num balsted of $in\n";
print OUT "Species\tnumber\tTOTAL:$num (<%of total Reads:$total>)\n";
if ($keyflag != 0){
my $kp = sprintf("%.2f%",($KW{"$keywords"}/$num)*100);
my $kTp=sprintf("%.2f%",($KW{"$keywords"}/$total)*100);
my $kkk=$KW{"$keywords"};
print OUT "$keywords\t$kkk\t$kp (<$kTp>)\n";
}
my @order = sort {$Lake{$b} <=> $Lake{$a}}keys %Lake;
foreach (@order){
	my $p = sprintf("%.2f%",($Lake{$_}/$num)*100);
	my $Tp = sprintf("%.2f%",($Lake{$_}/$total)*100);
	print OUT "$_\t$Lake{$_}\t$p (<$Tp>)\n";
}
close INfile;
close OUT;
close OUT1 if $FastqFlag==1;
}
#############

#close OUTlog;

sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}
Ptime("End");
print "##########End############\n";

