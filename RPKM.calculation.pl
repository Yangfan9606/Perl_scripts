#!/usr/bin/perl
use strict;
use Getopt::Long;

my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********# 

Program : 对htseq生成的exp结果文件进行RPKM及TPM计算,多个sample一起, 输入name为 .clean.exp之前名称
	  注：exp_file 以.clean.exp结尾,且所有exp文件行数一致!
	  normalize用的是RPKM.normalization.pl (用最后一列进行normalize)
	  输出文件：Out_name .all.count .RPKM .TPM

Usage: .pl Genome.transcript.len exp_file1,exp_file2,exp_file3... -o Out_name
#	/Data/Database/hg38/GRCh38.transcript.len
	-o		out name (.all.count .RPKM .TPM)
	-id		使用transcript_id [transcript]还是gene_id [gene] default <transcript>
	-type		计算类型(gene/CDS/5UTR/3UTR/Start_coden/Stop_coden) default <gene>, gene使用最长transcript;
	-nor		(0/1)是否输出normalize的RPKM结果 (default <0>)
	-help		output help information

USAGE

GetOptions(\%opts, "id:s", "type:s", "o:s", "nor:s", "help!");
##########
die $usage if ( @ARGV!=2 || defined($opts{"help"}));

###################################################
#                  START                          #
###################################################
my $infile=shift;
open(INfile, $infile) or die $!;
my @expfile=split/,/,shift;
my $outname=$opts{o};
my $id = 0;
$id = 1 if ($opts{id} eq "gene" || $opts{id} eq "gene_id");
my $type= "gene";
$type = $opts{type} if $opts{type} ne "";

print "##########Start############\n";
print "id = $id,$opts{id}\ntype = $type\n";
#############
my %Lake;
while(<INfile>){
	chomp;
	my @temp = split/\t/;
	my $n;
	$n=$temp[5] if $id == 1;
	$n=$temp[0] if $id == 0;
	$Lake{$n}{'5UTR'}=$temp[2];
	$Lake{$n}{'CDS'}=$temp[3];
	$Lake{$n}{'3UTR'}=$temp[4];
	if ($Lake{$n}{'Gene'} ne ""){
	$Lake{$n}{'Gene'}=$temp[1] if ($temp[1] > $Lake{$n}{'Gene'});
	}else{$Lake{$n}{'Gene'}=$temp[1];}
}
close INfile;
#############
my $outline1="Gene";
my %outrpkm;
my %outtpm;
my %outcount;
my $fileflag=0;
foreach my $F(@expfile){
print "File : $F\n";
$F=~s/\.clean\.exp//;
$fileflag+=1;
$outline1 .= "\t$F";
open(INfile1, "$F.clean.exp") or die $!;
my $totalcount;
my $tpmtotal;
while(<INfile1>){
	chomp;
	my @temp = split/\t/;
	$outcount{$temp[0]} = $_ if $fileflag == 1;
	$outcount{$temp[0]} .= "\t$temp[1]" if $fileflag != 1;
	$totalcount += $temp[1];
	print "$temp[0] gene len eq 0 (检查是否使用 -id gene_id 选项)or(genome file 文件名不对)\n" if $Lake{$temp[0]}{'Gene'} ==0;
	$tpmtotal += $temp[1]/$Lake{$temp[0]}{'Gene'};
}
close INfile1;
open(INfile1, "$F.clean.exp") or die $!;
while(<INfile1>){
	chomp;
	my @temp = split/\t/;
	my $n = $temp[0];
	my $c = $temp[1];
	my $rpkmS=($c*1000000000)/($totalcount*3);
	my $rpkmT=($c*1000000000)/($totalcount*3);
	my $rpkmC = ($Lake{$n}{'CDS'} == 0)?0:($c*1000000000)/($totalcount*$Lake{$n}{'CDS'});
	my $rpkm3 = ($Lake{$n}{'3UTR'} == 0)?0:($c*1000000000)/($totalcount*$Lake{$n}{'3UTR'});
	my $rpkm5 = ($Lake{$n}{'5UTR'} == 0)?0:($c*1000000000)/($totalcount*$Lake{$n}{'5UTR'});
	my $rpkmG = ($Lake{$n}{'Gene'} ==0)?0:($c*1000000000)/($totalcount*$Lake{$n}{'Gene'});
	my $tpmS=($c*1000000)/($tpmtotal*3);
	my $tpmT=($c*1000000)/($tpmtotal*3);
	my $tpmC = ($Lake{$n}{'CDS'}==0)?0:($c*1000000)/($tpmtotal*$Lake{$n}{'CDS'});
	my $tpm3 = ($Lake{$n}{'3UTR'}==0)?0:($c*1000000)/($tpmtotal*$Lake{$n}{'3UTR'});
	my $tpm5 = ($Lake{$n}{'5UTR'}==0)?0:($c*1000000)/($tpmtotal*$Lake{$n}{'5UTR'});
	my $tpmG = ($Lake{$n}{'Gene'}==0)?0:($c*1000000)/($tpmtotal*$Lake{$n}{'Gene'});
	my $rout;
	my $tout;
	if ($type eq "gene"){
		$rout = $rpkmG;
		$tout = $tpmG;
	}elsif($type eq "Start_coden" || $type eq "Stop_coden"){
		$rout = $rpkmS;
		$tout = $tpmS;
	}elsif($type eq "CDS"){
		$rout = $rpkmC;
		$tout = $tpmC;
	}elsif($type eq "3UTR"){
		$rout = $rpkm3;
		$tout = $tpm3;
	}elsif($type eq "5UTR"){
		$rout = $rpkm5;
		$tout = $tpm5;
	}else{
		die "请输出正确的type值!\n";
	}
	if ($fileflag == 1){
	$outrpkm{$n} = "$n\t$rout";
	$outtpm{$n} = "$n\t$tout";
	}else{
	$outrpkm{$n} .= "\t$rout";
	$outtpm{$n} .= "\t$tout";
	}
}
close INfile1;
}
open(OUTcount,">$outname.all.count") or die $!;
open(OUTrpkm, ">$outname.RPKM") or die $!;
open(OUTtpm, ">$outname.TPM") or die $!;
print OUTcount "$outline1\n";
print OUTrpkm "$outline1\n";
print OUTtpm "$outline1\n";
my @order = sort {$a cmp $b} keys %outcount;
foreach my $o (@order){
	print OUTcount "$outcount{$o}\n";
	print OUTrpkm "$outrpkm{$o}\n";
	print OUTtpm "$outtpm{$o}\n";
}
close OUTcount;
close OUTrpkm;
close OUTtpm;
print "##########End############\n";
system("perl /home/yangfan/Data/Bin/perl_script_my/final/RPKM.normalization.pl $outname.RPKM -start 2") if $opts{nor} == 1;
