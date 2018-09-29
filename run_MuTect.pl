#! /usr/bin/perl -w

print STDERR "#! /usr/bin/perl -w\n\n";
open(FIN,"/volumes/neo/genomes/hg19/hg19_all_len.txt");
my @chr_intervals=();
my $size=0;

$cmd="java -Djava.io.tmpdir=/volumes/neo/tmp -Xmx24g -jar /volumes/neo/code/3rd_party/muTect-1.1.4-bin/muTect-1.1.4.jar -T MuTect -R /volumes/neo/genomes/hg19/hg19_all.fa --input_file:normal ../CTC8_11_11_2013/CTC8-Pop-N.marked.sorted.re_aln.q40.bam  --input_file:tumor ../CTC8_11_11_2013/CTC8-CF.marked.sorted.re_aln.q40.bam -S SILENT -l INFO -filterMBQ ";

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
			$out_file="CTC8_CF_N_".$p_num.".vcf";
			$log_file=$out_file.".log";
			$code=$cmd."-vcf ".$out_file." -log ".$log_file." -L ".$code;
			print STDERR "$code\n";
			system("$code");
			$min=$max+1;
			$max+=25000000;	
			$p_num++;
		}
		$out_file="CTC8_CF_N_".$p_num.".vcf";
		$log_file=$out_file.".log";
		$code=$chr.":".$min."-".$length;
		$code=$cmd."-vcf ".$out_file." -log ".$log_file." -L ".$code;
		print STDERR "$code\n";
		system("$code");
		$p_num++;
	}
}
