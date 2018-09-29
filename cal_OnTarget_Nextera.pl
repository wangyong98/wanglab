#! /usr/bin/perl -w

my $infile=$ARGV[0];

my $outfile=$infile.".metrics";

$cmd="java -jar /volumes/neo/code/3rd_party/picard-tools-1.97/picard-tools-1.97/CalculateHsMetrics.jar BI=/volumes/neo/database/Nextera/NexteraRapidCapture_Exome_TargetedRegions_hg19_clean.bed.intervals TI=/volumes/neo/database/Nextera/NexteraRapidCapture_Exome_TargetedRegions_hg19_clean.bed.intervals I=$infile O=$outfile  R=/volumes/neo/genomes/hg19/hg19_all.fa LEVEL=ALL_READS VALIDATION_STRINGENCY=SILENT ";
system("$cmd");
