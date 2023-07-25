#!/usr/bin/perl
use strict;
use Getopt::Long;
use Statistics::Descriptive;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : Statistics~~~~~~ https://metacpan.org/pod/Statistics::Descriptive

Usage: .pl IN_file
	-h			是否有header,(t/f default <f>)
	-t			指定分隔符(default <\\t>)
	-i			choose input cloumn(default <1>)
	-o			choose output Statistics(see below) default <all>
	 mean 		平均值
	 mid		中位数 median / or use Q2
	 Q1		1/4 quartile
	 Q3		3/4 quartile
	 var 		方差 variance
	 std 		标准差 standard_deviation
	 num 		data个数
	 sum		求和
	 max 		最大值
	 maxdex 	最大值的index
	 min 		最小值
	 mindex 	最小值的index
	 range		最小值到最大值的距离
	-help			output help information
	-QQ			output QQ-plot (需要car包) y使用log(x)标准化(可能会报错)
USAGE

GetOptions(\%opts, "i:s", "b:s", "o:s", "u:s", "h:s", "QQ:s", "help!");
##########
die $usage if ( @ARGV!=1 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
open(INfile, $infile) or die $!;
my $t="\\t";
$t=$opts{t} if $opts{t} ne "";
my $in=1;
$in=$opts{i} if $opts{i} ne "";
my $head="f";
$head="t" if $opts{h} eq "t";

#############
my @fileRow;
my $line=0;
my %Lake;
my $inputrow;
my @data;
while(<INfile>){
	$line++;
	if ($head eq "t"){
		$head ="f";
		next;
	}
	chomp;
	my @temp = split/$t/;
	$inputrow = @temp;
	push @data,$temp[$in-1];
}
close INfile;
#############
my $stat = Statistics::Descriptive::Full->new();
$stat->add_data(@data);
my $mean = $stat->mean();#平均值
my $median = $stat->median();
my $variance = $stat->variance();#方差
my $num = $stat->count();#data的數目
my $standard_deviation=$stat->standard_deviation();#標準差
my $sum=$stat->sum();#求和
my $min=$stat->min();#最小值
my $mindex=$stat->mindex();#最小值的index
my $max=$stat->max();#最大值
my $maxdex=$stat->maxdex();#最大值的index
my $range=$stat->sample_range();#最小值到最大值
my $q1 = $stat->quantile(1); # lower quartile = lowest cut off (25%) of data = 25th percentile
my $q2 = $stat->quantile(2); # median = it cuts data set in half = 50th percentile
my $q3 = $stat->quantile(3); # upper quartile = highest cut off (25%) of data, or lowest 75% = 75th percentile

my $std3=$standard_deviation*3;
my $std6=$standard_deviation*6;

my ($x_mean_sum2,$x_mean_sum3,$x_mean_sum4);
my $x_StDev_sum4;
my $StDev = $standard_deviation;
foreach my $x(@data){
	$x_mean_sum2 += (($x-$mean)**2);
	$x_mean_sum3 += (($x-$mean)**3);
	$x_mean_sum4 += (($x-$mean)**4);
	$x_StDev_sum4 += ((($x-$mean)/$StDev)**4);
}
# 偏度 Skewness
my $n1 = 1/$num;
my $Skewness = ($n1*$x_mean_sum3)/(($n1*$x_mean_sum2)**(3/2));
# 峰度 Kurtosis
my $Kurtosis = ($n1*$x_mean_sum4)/(($n1*$x_mean_sum2)**(2)) -3;
my $n = $num;
#my $Kurtosis2 = ($x_StDev_sum4/($n-1)) - 3;
my $Kurtosis_excel = (($n*($n+1))/(($n-1)*($n-2)*($n-3)))*($x_StDev_sum4)-((3*(($n-1)**2))/(($n-2)*($n-3)));
my $Z_Skewness = $Skewness/$StDev;
my $Z_Kurtosis = $Kurtosis/$StDev;
my $Z_Kurtosis_excel = $Kurtosis_excel/$StDev;

if ($opts{o} eq ""){
	print "Number of Values = $num\n",
	      "sum = $sum\n",
	      "Mean = $mean\n",
	      "Median = $median\n",
	      "Q1 = $q1, Q2 = $q2, Q3 = $q3\n",
	      "Variance = $variance\n",
	      "standard_deviation = $standard_deviation (3σ= $std3 , 6σ= $std6)\n",
	      "min = $min\n",
	      "mindex = $mindex\n",
	      "max = $max\n",
	      "maxdex = $maxdex\n",
	      "range = $range\n",
	      "偏度Skewness = $Skewness (Z_score:$Z_Skewness)\n",
	      "峰度Kurtosis = $Kurtosis (Z_score:$Z_Kurtosis)\n",
	      "Excel_Kurtosis = $Kurtosis_excel (Z_score:$Z_Kurtosis_excel) Z should +- 1.96\n";
}else{
	print "$mean\n" if $opts{o} eq "mean";
	print "$median\n" if $opts{o} eq "mid";
	print "$q1\n" if $opts{o} eq "Q1";
	print "$q2\n" if $opts{o} eq "Q2";
	print "$q3\n" if $opts{o} eq "Q3";
	print "$variance\n" if $opts{o} eq "var";
	print "$standard_deviation\n" if $opts{o} eq "std";
	print "$num\n" if $opts{o} eq "num";
	print "$sum\n" if $opts{o} eq "sum";
	print "$max\n" if $opts{o} eq "max";
	print "$min\n" if $opts{o} eq "min";
	print "$maxdex\n" if $opts{o} eq "maxdex";
	print "$mindex\n" if $opts{o} eq "mindex";
	print "$range\n" if $opts{o} eq "range";
}
if ($opts{QQ} ne ""){
	my $Qtitle = $infile eq "-"?"":"$infile";
	open(Rout,">stat.QQ.R") or die $!;
#	open(Qout,">stat.QQ.R.temp") or die $!;
	my $o;
	foreach my $x(@data){
		$o .= $o eq ""?$x:",$x";
#		print Qout "$x\n";
	}
	print Rout "
library(car)
#x=read.table(file=\"stat.QQ.R.temp\",sep=\"\\t\",header=F)
#,stringsAsFactors=F)
x=c($o)
x=na.omit(x)
####y=(x-mean(x))/sqrt(var(x)) # z-score同scale()
####y=(x-min(x))/(max(x)-min(x)) # min-max标准化
#y=scale(x)
#y=(x-min(x))/(max(x)-min(x))
#y=log2(x+1)
y=log(x)
#y=na.omit(y)
head(x)
head(y)
pdf(\"qqPlot_$Qtitle.col$in.pdf\")
qqPlot(x, main=\"$Qtitle\\nqq plot\", col=\"blue\", pch=20, col.lines=\"red\")
qqPlot(y, main=\"$Qtitle\\nlog qq plot\", col=\"blue\", pch=20, col.lines=\"red\")
dev.off()
";
system("Rscript stat.QQ.R");
system("rm -rf stat.QQ.R");
}

sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}

