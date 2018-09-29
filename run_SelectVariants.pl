#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $prefix="";
if($infile=~/^(.*?)\.vcf$/)
{
	$prefix=$1;
}
else
{
	print STDERR "Wrong input, exiting ...\n";
	exit(1);
}

$outfile=$prefix.".SNP.vcf";
$cmd="java -jar  /volumes/neo/code/3rd_party/GATKv3.2/GenomeAnalysisTK.jar -T SelectVariants -V $infile -o $outfile -selectType SNP -R /volumes/neo/genomes/hg19/hg19_all.fa";
print STDERR "$cmd\n";
system("$cmd");

$outfile=$prefix.".INDEL.vcf";
$cmd="java -jar  /volumes/neo/code/3rd_party/GATKv3.2/GenomeAnalysisTK.jar -T SelectVariants -V $infile -o $outfile -selectType INDEL -R /volumes/neo/genomes/hg19/hg19_all.fa";
print STDERR "$cmd\n";
system("$cmd");
