#!/usr/bin/perl

$infilelist = $ARGV[0];

open(TXT, "<$infilelist");
@filenamelist = <TXT>;
close(TXT);

chomp(@filenamelist); 

foreach $item(@filenamelist)
 	{
    print "BWA align file $item \n";
	system("/Volumes/core/bioinfo/bwa/bwa aln -t 12 /Volumes/sci/genomes/hg19/bwa_nick/hg19.fa ./fastq/$item.trim28.fastq > $item.sai");
	}

foreach $item(@filenamelist)
	{
	print "BWA samse file $item \n";
	system("/Volumes/core/bioinfo/bwa/bwa samse /Volumes/sci/genomes/hg19/bwa_nick/hg19.fa $item.sai ./fastq/$item.trim28.fastq > $item.sam"); 
 	}

 foreach $item(@filenamelist)
	{
	print "Samtools convert sam to bam file $item \n";
	system("/Volumes/sci/code/3rd_party/samtools-0.1.18/samtools view -bS -q 1 $item.sam > $item.bam");
	}

foreach $item(@filenamelist)
	{
	print "Samtools sort file $item \n";
	system("/Volumes/sci/code/3rd_party/samtools-0.1.18/samtools sort $item.bam $item.sort");
	}
	
foreach $item(@filenamelist)
	{
	print "Convert back to sorted sam $item \n";
	system("/Volumes/sci/code/3rd_party/samtools-0.1.18/samtools view $item.sort.bam > $item.sort.sam");
	}
  
foreach $item(@filenamelist)
	{
	print "Calculate varbins $item \n";
     system("python /Volumes/sci/code/yongwang_hg19/varbin.sam.2.py $item.sort.sam $item.new.vb50 $item.new.stat.txt");
	}
