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

my $outfile=$prefix.".bam.exomecoverage";

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools view -uF 0x400 -q 1 $infile | /volumes/neo/code/3rd_party/BEDTools-Version-2.14.3/coverageBed -abam - -b /volumes/sci/users/ckim/t1000/T1000.bed -d >& $outfile";
system("$cmd");

$calfile=$outfile.".cal";
$cmd="/volumes/neo/code/yongwang_hg19/cal_depthdistribution_exome.pl $outfile $calfile";
system("$cmd");
