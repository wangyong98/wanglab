#! /usr/bin/perl -w

print STDERR "#! /usr/bin/perl -w\n\n";
open(FIN,"/volumes/neo/genomes/hg19/hg19_all_len.txt");
my @chr_intervals=();
my $size=0;

$cmd="java  -Djava.awt.headless=true -Djava.io.tmpdir=/volumes/neo/tmp -Xmx48g -jar /volumes/neo/code/3rd_party/GATKv3.3/GenomeAnalysisTK.jar -T UnifiedGenotyper -glm BOTH -R /volumes/neo/genomes/hg19/hg19_all.fa --dbsnp /volumes/neo/code/3rd_party/GATKv3.3/GATK_resources/dbsnp_137.hg19.excluding_sites_after_129.vcf -I TN10N_seq_both_sscs.RG.bam -I TN10T_seq_both_sscs.RG.bam -S SILENT -nt 10 -dt BY_SAMPLE -dcov 2500 -l INFO -mbq 20 -rf BadCigar ";

my $p_num=0;

while(<FIN>)
{
	chomp;
	if(/^(.*?)\s+LN\:(.*?)$/)
	{
		$chr=$1;
		$length=$2;
		$min=1;
		$max=25000000;
		while($max <= $length )
		{
			$code=$chr.":".$min."-".$max;
			$out_file="TN10_".$p_num.".vcf";
			$log_file=$out_file.".log";
			$code=$cmd."-o ".$out_file." -log ".$log_file." -L ".$code;
			#print STDERR "system\(\"$code\"\)\;\n\n";
			print STDERR "$code\n";
			system("$code");
			$min=$max+1;
			$max+=25000000;	
			$p_num++;
		}
		$out_file="TN10_".$p_num.".vcf";
		$log_file=$out_file.".log";
		$code=$chr.":".$min."-".$length;
		$code=$cmd."-o ".$out_file." -log ".$log_file." -L ".$code;
		#print STDERR "system\(\"$code\"\)\;\n\n";
		print STDERR "$code\n";
		system("$code");
		$p_num++;
	}
}
