#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $prefix="";
if($infile=~/^(.*?)\.bam$/)
{
	$prefix=$1;
}
else
{
	print STDERR "Wrong input ... exiting\n";
	exit(0);
}

my $outfile=$prefix.".bam.coverage";

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools view -uF 0x400 -q 1 $infile | /volumes/neo/code/3rd_party/bedtools2-master/bin/genomeCoverageBed -ibam - -max 100 -g /volumes/neo/genomes/hg19/hg19_all.fa >& $outfile";
system("$cmd");
