package yangfan;

use strict;
require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 1.00;
@ISA = qw(Exporter);
#@EXPORT = qw(Ptime Overlap Merge median max min avg sum codon2aa readFa GC tmCal interval);
#@EXPORT_OK = qw(Ptime Overlap Merge median max min avg sum codon2aa readFa GC tmCal interval);
@EXPORT = qw(Ptime mean median max min avg sum qianfen GC Tm interval find_diffs fuzzy_pattern combin);
@EXPORT_OK = qw(Ptime mean median max min avg sum qianfen GC Tm interval find_diffs fuzzy_pattern combin);

sub Ptime {
	my $time = localtime;
	my ($msg) = @_;
	print "$msg at $time\n";
}

sub mean {
	my (@array) = @_;
	my $sum=0;
	foreach my $i(@array){
		$sum+=$i/@array;
	}
	return $sum;
}

sub median {
	my (@array) = @_;
	my @infoS = sort{$a <=> $b} @array;
	if(@infoS%2 != 0){
		return $infoS[int(@infoS/2)];
	}else{
		return ($infoS[@infoS/2-1]+$infoS[@infoS/2])/2;
	}
}

sub avg{
	my (@array) = @_;
	my $sum=0;
	foreach my $i(@array){
		$sum+=$i/@array;
	}
	return $sum;
}

sub sum{
	my (@array) = @_;
	my $sum=0;
	foreach my $i(@array){
		$sum+=$i;
	}
	return $sum;
}

sub min{
	my (@array) = @_;
	my @infoS = sort {$a<=>$b} @array;
	return $infoS[0];
}

sub max{
	my (@array) = @_;
	my @infoS = sort {$a<=>$b} @array;
	return $infoS[-1];
}

sub qianfen {
	my ($num) = @_;
	my @sp = split/\./,$num;
	while($sp[0] =~ s/(\d)(\d{3})((,\d\d\d)*)$/$1,$2$3/){};
	my $R = $sp[1] eq ""?$sp[0]:"$sp[0].$sp[1]";
	return $R;
}

sub GC{
	my($seq) = @_;
	my @S = split//,$seq;
	my %count;
	$count{'A'}+=0;
	$count{'T'}+=0;
	$count{'G'}+=0;
	$count{'C'}+=0;
	$count{'N'}+=0;
	my $n = 0;
	foreach my $s(@S){
		$count{uc $s}++;
		$n++;
	}
	my $g = $count{'G'};
	my $c = $count{'C'};
	my $gc = ($g+$c)/$n;
	return $gc;
}

###http://biotools.nubic.northwestern.edu/OligoCalc.html
sub Tm{
	my($seq,$na)=@_;
	my @S = split//,$seq;
	$na = 0.05 if($na eq "");
	my $tm=0;
	my %Count;
	my ($a,$t,$g,$c)=(0,0,0,0);
	foreach my $s(@S){
		$Count{uc $s}++;
	}
	$a = $Count{'A'}+0;
	$t = $Count{'T'}+0;
	$g = $Count{'G'}+0;
	$c = $Count{'C'}+0;
	my $len = scalar @S;
#	print "$seq\t$len\tA:$a\tT:$t\tG:$g\tC:$c\n";
	if(@S<13){
		$tm = ($a+$t)*2+($g+$c)*4+16.6*(log($na/0.05)/log(10));
	}elsif(@S<50){
		$tm = 100.5+(41*($g+$c)/($a+$t+$g+$c))-(820/($a+$t+$g+$c))+16.6*(log($na)/log(10));
	}elsif(@S>=50){
		$tm = 81.5+(41*($g+$c)/($a+$t+$g+$c))-(500/($a+$t+$g+$c))+16.6*(log($na)/log(10));
	}
	return $tm;
}

################  查看点是否落在区间内, ($chr,$dot,@b); 格式"1,123,(1-100-101,2-105-107)"
sub interval{
	my ($chr,$dot,@p) = @_;
	my $R;
	foreach my $P(@p){
		my @T = split/\-/,$P;
		my $c = $T[0];
		next if $c ne $chr;
		my $s = $T[1];
		next if $dot < $s;
		my $e = $T[2];
		next if $dot > $e;
		$R .= $R eq ""?"$P":",$P";
	}
	return $R;
}

##################### 寻找2个字符串之间的差异,并输出位置及mutation(1 base) out @ ("1,$M1","7,$M2"...)
sub find_diffs{
	my ($s1,$s2) = @_;
	my @S1 = split//,$s1;
	my @S2 = split//,$s2;
	my @R;
	for (my $i=0;$i<@S1;$i++){
		my $p = $i+1;
		my $b1 = $S1[$i];
		my $b2 = $S2[$i];
		if ($b1 ne $b2){
			my $m = "$p,$b2";
			push @R,$m;
		}
	}
	return @R;
}
###### 返回 允许x个错配的匹配pattern
# my $new_TSO = "TTTCTTATATGGG";
# my $new_TSO_mis1 = fuzzy_pattern($new_TSO,1);
# if ($seq =~ /$new_TSO_mis1/)...
sub fuzzy_pattern {
	my ($original_pattern, $mismatches_allowed) = @_;
	$mismatches_allowed >= 0 or die "Number of mismatches must be greater than or equal to zero\n";
	my $new_pattern = make_approximate($original_pattern, $mismatches_allowed);
	return qr/$new_pattern/;
}
sub make_approximate {
	my ($pattern, $mismatches_allowed) = @_;
	if ($mismatches_allowed == 0) { return $pattern }
	elsif (length($pattern) <= $mismatches_allowed){ $pattern =~ tr/ACTG/./; return $pattern }
	else {
		my ($first, $rest) = $pattern =~ /^(.)(.*)/;
		my $after_match = make_approximate($rest, $mismatches_allowed);
		if ($first =~ /[ACGT]/) {
			my $after_miss = make_approximate($rest, $mismatches_allowed-1);
			return "(?:$first$after_match|.$after_miss)";
		}else { return "$first$after_match" }
	}
}
###  计算组合数
sub combin{
	my ($a,$b) = @_;
	open(R,">temp.R") or die $!;
	print R "library(gtools)\nnrow(combinations($a, $b))\n";
	my $o = `Rscript temp.R`;
	chomp $o;
	my @N = split/ /,$o;
	system("rm -rf temp.R");
	return $N[1];
}
