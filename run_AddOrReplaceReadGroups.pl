#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $RG=$ARGV[1];
my $SM=$ARGV[2];

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

my $outfile=$prefix.".RG.bam";

$cmd="java -Xmx2g -jar /volumes/neo/code/3rd_party/picard-tools-1.97/picard-tools-1.97/AddOrReplaceReadGroups.jar  I=$infile O=$outfile ID=$RG PL=ILLUMINA PU=$RG LB=$RG SM=$SM TMP_DIR=/volumes/neo/tmp VERBOSITY=INFO VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=5000000";
system("$cmd");

system("samtools index $outfile");
