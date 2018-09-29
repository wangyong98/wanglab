#navinlab processing pipeline for barcoded single cell to read counts
#nnavin@mdanderson.org 9-28-2011

min = 2
max=26

 for ((i=min; i<=$max; ++i ))   
 do
 echo "trim file $i"
	perl /code/seq/trim/remove_part_fastq.pl bc$i.fastq bc$i.trim34.fastq 34
 done
 

 for ((i=min; i<=$max; ++i )) 
 do
 echo "BWA align file $i"
	/bioinfo/bwa/bwa aln -t 12 /Volumes/sci/genomes/hg19/hg19_from_nick/hg19.fa bc$i.trim34.fastq > bc$i.sai
	done

 for ((i=min; i<=$max; ++i )) 
 do
 echo "BWA samse file $i"
	/bioinfo/bwa/bwa samse /Volumes/sci/genomes/hg19/bwa_nick/hg19.fa bc$i.sai bc$i.trim34.fastq > bc$i.sam
 done

 for ((i=min; i<=$max; ++i ))
 do
	echo "Samtools convert sam to bam file $i"
  samtools view -bS -q 1 bc$i.sam > bc$i.bam
 done

 for ((i=min; i<=$max; ++i )) 
  do
	echo "Samtools sort file $i"
	samtools sort bc$i.bam bc$i.sort
  done
  
for ((i=min; i<=$max; ++i )) 
 do
	echo "Convert back to sorted sam $i"
	samtools view bc$i.bam > bc$i.sort.sam
  done
  
for ((i=min; i<=$max; ++i )) 
 do
	echo "Calculate varbins $i"
    python /code/seq/varbin/varbin.sam.2.py bc$i.sort.sam bc$i.vb50 bc$i.stat.txt
 done
