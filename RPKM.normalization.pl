#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 对Alignment.sh 生成的.FPKM文件进行normalize; (注:文件必须包含列名)
	  若想对RPKM结果文件进行nor,使用 -start 命令
	  nomalize 使用3/4位的值,若为0则使用4/5;5/6;6/7;

Usage: .pl .FPKM
	-nor			选择nor的列(default <最后一列>),第7列开始
	-o			output name(.nor.out)
	-start			选择RPKM开始的列(dufault <7>)
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "nor:s", "start:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
open(INfile, $infile) or die $!;
my $Outfilename = $opts{o} if $opts{o} ne "";
open(OUT, ">$infile.nor.out") or die $! if $opts{o} eq "";
open(OUT, ">$Outfilename.nor.out") or die $! if $opts{o} ne "";
#open(OUTlog, ">$infile.$program.log") or die $!;
my $norcolumn = 0;
$norcolumn = $opts{nor} if $opts{nor} ne "";

my $Start=6;
$Start = $opts{start} - 1 if $opts{start} ne "";

print "##########Start############\n";
my $SFcol = $Start + 1;
print "start列 = $SFcol\n";
print "norcolumn = $norcolumn ;若为0,表示最后一列\n";
#############
my %EachRPKM;
my $inputrow;

my $line=0;
while(<INfile>){
	$line++;
	chomp;
	my @temp = split/\t/;
	$inputrow = @temp;
	next if $line == 1;
	for (my $i=$Start;$i<@temp;$i++){
		$EachRPKM{$i} .= " $temp[$i]";
	}
}
close INfile;

my $samplerow = $inputrow - $Start;
print "sample num : $samplerow\n";

my @computTPM;
my @normTPM;
for (my $i=$Start;$i<$inputrow;$i++){
	my $Col = $i+1;
	my @S = split/ /, $EachRPKM{$i};
	shift @S;
	my @SS = sort{$a<=>$b} @S;
	my $j = int(3*@SS/4);
	my $num;
	if (@SS[$j] == 0){
		print "第 $Col 列3/4位值为0, 选择4/5位";
		my $r = int(4*@SS/5);
		$num = @SS[$r-1];
		if ($num == 0){
			print "; 其4/5位值也为0, 选择5/6位";
			my $rr = int(5*@SS/6);
			$num = @SS[$rr-1];
		}
		if ($num == 0){
			print "; 其5/6位值也为0, 选择6/7位";
			my $rrr = int(6*@SS/7);
			$num = @SS[$rrr-1];
		}
		if ($num == 0){
			print "\n";
			die "第 $Col 列6/7位数还是为0,无法进行normalize,自己想办法!\n\n";
		}
		print ";\n";
	}else{
	$num = @SS[$j-1];
	}
	push @computTPM, $num;
}
print @computTPM." of input RPKM : (选择nor的RPKM值) 第$SFcol列开始\n";
print "\t@computTPM\n";
############################################ 
$norcolumn = $norcolumn - $Start if $norcolumn != 0;
for (my $r=0;$r<@computTPM;$r++){
	my $cptNUM = $computTPM[$r]/$computTPM[$norcolumn-1];
	push @normTPM, $cptNUM;
}
print @normTPM." of nor result: (每列nor的值) 第$SFcol列开始\n";
print "\t@normTPM\n";
#############
my @fileRow;
$line=0;
my %Lake;

open(INfile, $infile) or die $!;
while(<INfile>){
	$line++;
	chomp;
	my @temp = split/\t/;
	if ($line == 1){
		print OUT "$_\n";
		next;
	}
	print OUT "$temp[0]";
	my $out1;
	for (my $k=1;$k<$Start;$k++){
		$out1 .= "\t$temp[$k]"
	}
	print OUT "$out1";
	for (my $i=1;$i<=$samplerow;$i++){
		my $outrpkm = $temp[$i+$Start-1]/$normTPM[$i-1];
		print OUT "\t$outrpkm";
	}
	print OUT "\n";
}
print "column $inputrow\n";
print "  line $line\n";

#############

close INfile;
close OUT;
#close OUTlog;

print "##########End############\n";

