#! /usr/bin/perl -w

system("wc -l *.vcf >& tmp1.txt");
open(FIN,"tmp1.txt");
while(<FIN>)
{
	chomp;
	if(/\s+(.*?)\s+(.*?)$/)
	{
		if($1 eq "0")
		{
			$file=$2.".log";
			open(FIN1,"$file");
			while(<FIN1>)
			{
				if(/^(.*?)Program Args\:(.*?)$/)
				{
					$cmd ="java  -Djava.awt.headless=true -Djava.io.tmpdir=/volumes/neo/tmp -Xmx48g -jar /volumes/neo/code/3rd_party/GATKv3.3/GenomeAnalysisTK.jar ".$2;
					print STDERR "$cmd\n";
					system("$cmd");	
				}
			}
			close(FIN1);
		}
	}
}
close(FIN);
