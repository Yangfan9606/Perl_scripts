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
use LWP::Simple qw(get);
#fuzzy_pattern($x,1);
my %opts;
my $program=`basename $0`;
chomp $program;
my $usage=<<USAGE; #******* Instruction of this program *********#

Program : 获取网页源码中的链接，并下载 (自定义分割字符串去寻找download link)

Usage: .pl [url] -o [outdir.name]
        -help                   output help information

USAGE

GetOptions(\%opts, "l:s", "b:s", "o:s", "u:s", "i:s", "help!");
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
my $url=shift;
my $html = get($url);

my $outname = $opts{o};
die "Input outdir name use -o\n" if $opts{o} eq "";
open(SHELL,">temp.Crawler.donwload.sh") or die $!;
print SHELL "rm -rf $outname\nmkdir $outname\ncd $outname\n";
#open(OUT, ">$outname") or die $!;
###################################################################
###### 分割字符串 1
my $split_word1 = "\"assembly\":\"GRCh38\",\"status\"";
#############################
my @HTML = split/$split_word1/,$html;
##################################################################
###### 分割字符串 2
my $split_word2 = "\"url\":\"";
##################################################################
foreach my $h(@HTML){
        my @URL = split/$split_word2/,$h;
        my @LINK = split/\"/,$URL[1];
        foreach my $l(@LINK){
                next unless $l =~ /^http/;
                next unless $l =~ /bed.gz$/;
                print SHELL "wget $l\n";
#               system("wget $l");
#               print OUT "$l\n";
        }
}
print SHELL "cd ..\n";
system("bash temp.Crawler.donwload.sh");
#############

close OUT;

Ptime("End");
print "##########End############\n";
