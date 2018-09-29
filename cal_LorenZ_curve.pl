#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $outfile=$infile.".Lorenz";
my $tot=0;
open(FIN,"$infile");
while(<FIN>)
{
	chomp;
	$tot+=$_;
}
close(FIN);

my $step=50000;
my $read=0;
my $site=0;
my $count=0;

open(FIN,"$infile");
open(FOUT,"> $outfile");

while(<FIN>)
{
	chomp;
	$site++;
	$read+=$_;
	$count++;
	if($count >=$step)
	{
		$count=0;
		$tmp1=$read/$tot;	
		$tmp2=$site/37317541;
		print FOUT "$tmp2\t$tmp1\n";
	}
}
$tmp1=$read/$tot;
$tmp2=$site/37317541;
print FOUT "$tmp1\t$tmp2\n";
