#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $outfile=$ARGV[1];

my @dis=();
for($i=0;$i<=1000;$i++)
{
	$dis[$i]=0;
}

my $num_sites=0;
my $depth=0;
open(FIN,"$infile");
open(FOUT,"> $outfile");
while(<FIN>)
{
	chomp;
	my @a=split(/\s+/);
	$num_sites++;
	$depth+=$a[4];
	if($a[4]>=1000)
	{
		$dis[1000]++;
	}
	else
	{
		$dis[$a[4]]++;
	}
}
close(FIN);
$depth=$depth/$num_sites;

printf FOUT "average depth = %.0f\n", $depth;

for($i=0;$i<=1000;$i++)
{
	$temp=$dis[$i] / $num_sites;
	printf FOUT "genome\t%d\t%d\t%d\t%.4f\n", $i, $dis[$i], $num_sites, $temp;
}
close(FOUT);
