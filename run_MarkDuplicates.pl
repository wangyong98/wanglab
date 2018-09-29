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

my $outfile=$prefix.".marked.bam";
my $M_file=$outfile.".metrics";

$cmd="java -Xmx4g -jar /volumes/neo/code/3rd_party/picard-tools-1.97/picard-tools-1.97/MarkDuplicates.jar  I=$infile O=$outfile M=$M_file REMOVE_DUPLICATES=false AS=true TMP_DIR=/volumes/neo/tmp VERBOSITY=INFO VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=5000000";
system("$cmd");

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools flagstat $prefix.marked.bam >& $prefix.marked.bam.flag";
system("$cmd");

$outfile=$prefix.".marked.bam.coverage";

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools view -uF 0x400 -q 1 $prefix.marked.bam | /volumes/neo/code/3rd_party/bedtools2-master/bin/genomeCoverageBed -ibam - -max 100 -g /volumes/neo/genomes/hg19/hg19_all.fa >& $outfile";
#system("$cmd");
