#! /usr/bin/perl -w

$cmd ="java -Djava.io.tmpdir=/volumes/neo/tmp -Xmx8g  -jar /volumes/neo/code/3rd_party/GATKv3.3/GenomeAnalysisTK.jar -T CombineVariants -o TNBC_FNA_sscs.vcf -R  /volumes/neo/genomes/hg19/hg19_all.fa --genotypemergeoption UNSORTED  ";

for($i=0;$i<=204;$i++)
{
	$file="-V TNBC_FNA_".$i.".vcf";
	$cmd=$cmd." ".$file;
}
#print STDERR "$cmd\n";
system("$cmd");
