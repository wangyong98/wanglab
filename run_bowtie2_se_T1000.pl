#! /usr/bin/perl -w
use File::Basename;
use Cwd;

my $cwd = getcwd;
my $path=$cwd;

@files=glob("$path/*_R1*.fastq $path/*_R1*.fastq.gz");

my $i=0;
my $pre="";
foreach $file (@files)
{
	my $fname=basename($file);
	$fname =~ /^(.*?)\_(.*?)\_(.*?)\_(.*?)\_(.*?)\.fastq/;
	$pre=$1;

	$sampleName=$1;
	$samName=$cwd."/".$1."_".$2."_".$3."_".$5.".sam";
	
	$seq2="$path/".$sampleName."_".$2."_".$3."_R2_".$5.".fastq.gz";
	
	#get sam file
	$cmd_sam="/volumes/neo/code/3rd_party/bowtie2-2.2.6/bowtie2 -x /volumes/neo/code/3rd_party/bowtie2-2.2.6/hg19/hg19 -U $file -S $samName --local --rg-id $sampleName --rg SM:$sampleName --rg PU:$sampleName --rg PL:ILLUMINA --rg LB:$sampleName -p 6 ";

	#from sam to bam
	$bamName=$cwd."/".$1."_".$2."_".$3."_".$5.".bam";
	$cmd_bam="/volumes/neo/code/3rd_party/samtools-1.2/samtools view -bS $samName > $bamName";

	#sort bam
	$sortName=$cwd."/".$1."_".$2."_".$3."_".$5.".sorted";
	$cmd_sort="/volumes/neo/code/3rd_party/samtools-1.2/samtools sort -m 7600000000 $bamName $sortName";

	if(-e $samName && -e $bamName && -e $sortName )
	{
	}
	elsif(-e $samName && -e $bamName)
	{
                sytem("$cmd_sort");
	}
	elsif(-e $samName)
	{
                system("$cmd_bam");
                system("$cmd_sort");
	}
	else
	{
		system("$cmd_sam");
		system("$cmd_bam");
		system("$cmd_sort");
	}
}

@files=glob("$path/*.sorted.bam");

my $cmd="";
$size=@files;
if($size>1)
{
	$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools merge $cwd/$pre.sorted.bam ";

	foreach $file (@files)
	{
		$cmd=$cmd." ".$file;
	}
	print STDERR "$cmd\n";
}
else
{
	$cmd="mv $files[0] $cwd/$pre.sorted.bam ";
	print STDERR "$cmd\n";
}
system("$cmd");

$key=$pre;

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools index $cwd/$key.sorted.bam";
print STDERR "$cmd\n";
system("$cmd");

$cmd="java -Xmx8g -jar /volumes/neo/code/3rd_party/picard-tools-1.97/picard-tools-1.97/MarkDuplicates.jar I=$cwd/$key.sorted.bam O=$cwd/$key.marked.sorted.bam M=$cwd/$key.marked.sorted.bam.log TMP_DIR=/volumes/neo/tmp VALIDATION_STRINGENCY=SILENT AS=true REMOVE_DUPLICATES=false VERBOSITY=INFO MAX_RECORDS_IN_RAM=10000000";
print STDERR "$cmd\n";
system("$cmd");

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools flagstat $cwd/$key.marked.sorted.bam >& $key.marked.sorted.bam.flag";
print STDERR "$cmd\n";
system("$cmd");

$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools index $cwd/$key.marked.sorted.bam";
print STDERR "$cmd\n";
system("$cmd");

my $outfile=$key.".marked.sorted.bam.exomecoverage";
$cmd="/volumes/neo/code/3rd_party/samtools-1.2/samtools view -uF 0x400 -q 1 $key.marked.sorted.bam | /volumes/neo/code/3rd_party/BEDTools-Version-2.14.3/bin/coverageBed -abam - -b /volumes/neo/custom_panel_design_1000_genes/OID42878_hg19_T1000_30Sep2015_capture_targets.bed -d >& $outfile";
system("$cmd");

$calfile=$outfile.".cal";
$cmd="/volumes/neo/code/yongwang_hg19/cal_depthdistribution_exome.pl $outfile $calfile";
system("$cmd");

