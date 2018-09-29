#! /usr/bin/perl -w

use Cwd;
my $cwd = getcwd;

my $infile=$ARGV[0];
my $prefix="";
if($infile=~/^(.*?)\.bam$/)
{
	$prefix=$1;
}
else
{
	print STDERR "Wring input .... exiting\n";
	exit(0);
}
my $outfile=$prefix.".re_aln.bam";
my $inter=$prefix.".bam.intervals";


$cmd="java -Djava.awt.headless=true -Djava.io.tmpdir=/volumes/neo/tmp -Xmx10g -jar /volumes/neo/code/3rd_party/GATKv3.2/GenomeAnalysisTK.jar -T RealignerTargetCreator -I $cwd/$infile -o $cwd/$inter -log $cwd/$inter.log -R /volumes/neo/genomes/hg19/hg19_all.fa  -S SILENT -nt 2 -dt BY_SAMPLE -dcov 2500 -l INFO -filterMBQ";
print STDERR "$cmd\n";
system("$cmd");

$cmd="java -Djava.awt.headless=true -Djava.io.tmpdir=/volumes/neo/tmp -Xmx10g -jar /volumes/neo/code/3rd_party/GATKv3.2/GenomeAnalysisTK.jar -T IndelRealigner -I $cwd/$infile -o $cwd/$outfile -log $cwd/$outfile.log -targetIntervals $cwd/$inter -R /volumes/neo/genomes/hg19/hg19_all.fa -S SILENT -dt BY_SAMPLE -dcov 2500 -l INFO -filterMBQ";
print STDERR "$cmd\n";
system("$cmd");
