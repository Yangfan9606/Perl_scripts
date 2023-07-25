#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd;
use FindBin qw($Bin);
# $Bin为当前路径
use lib '/home/yangfan/Data/Bin/perl_script_my/final/';
use yangfan;
use Statistics::Descriptive;
use List::Util qw(shuffle);

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 将诸如exp等count的data文件合并为一个(gene+值)，空位值将为0, 可指定某几列组成gene name列(out name下划线分隔)

Usage: .pl [exp1,exp2...] -o [out.name]
	-name			name1,name2,name3...
	-i			指定列,所有文件统一 [2]
	-gn			指定某几列合并为gene name列(-gn 1,3,5), default 第一列[1]
	-o			out name
	-nor			normalize factor default all 1 (-nor 0.5,1,0.7)
	-F			file format default non [gz] (gz = zcat 打开文件)
	-help			output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "name:s", "gn:s", "nor:s", "F:s", "help!");
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
my @infile=split/,/,shift;
my @name = split/,/,$opts{name};
die @name." vs ".@infile." !! Name number not suit for files number ...\n" if (@name != @infile);
my $n = join("\t",@name);
my $outname = $opts{o};
my $col = $opts{i} eq ""?1:$opts{i} - 1;
die "Input out name use -o\n" if $opts{o} eq "";
my @gn = split/,/,$opts{gn};
my @nor = split/,/,$opts{nor};
if ($opts{nor} ne ""){
	die @nor." vs ".@infile." !! nor factor number not suit for files number ...\n" if (@nor != @infile);
}
open(OUT, ">$outname") or die $!;
#############
my (%Lake,%val,%Total);
my $file_num=0;
foreach my $f(@infile){
	print "file:$f";
	if ($opts{F} eq "gz"){
		open(INfile,"zcat $f|") or die $!;
	}else{
		open(INfile,$f) or die $!;
	}
	my $line = 0;
while(<INfile>){
	chomp;
	my @temp = split/\t/;
	my $GN = $temp[0];
	if ($opts{gn} ne ""){
		$GN = "";
		foreach my $i(@gn){
			$GN .= $GN eq ""?$temp[$i-1]:"_$temp[$i-1]";
		}
	}
	$Lake{$GN} = 1;
	my $count = $temp[$col];
	$count = $count/$nor[$file_num] if $opts{nor} ne "";
	$val{$f}{$GN} = $count;
#	$Total{$f} += $count;
	$line++;
}
print "\t$line rows\n";
close INfile;
$file_num++;
}
print OUT "Group\t$n\n";
foreach my $g(sort {$a cmp $b} keys %Lake){
	my $o;
	foreach my $f(@infile){
		$val{$f}{$g} += 0;
#		my $rate = sprintf "%.2f", ($val{$f}{$g}/$Total{$f})*100;
		$o .= "\t$val{$f}{$g}";
#		$o .= "\t$rate";
	}
	print OUT "$g$o\n";
}

#############

close OUT;

Ptime("End");
print "##########End############\n";

