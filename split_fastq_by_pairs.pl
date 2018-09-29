#! /usr/bin/perl -w

my $infile=$ARGV[0];

$infile=~/^(.*?)\.fastq/;

$out_R1=$1.".R1.fastq";
$out_R2=$1.".R2.fastq";
open(FOUT1, "> $out_R1");
open(FOUT2, "> $out_R2");

open(FIN,"gzip -cd $infile|");
my @output=();
my $count=0;
while(<FIN>)
{
	chomp;
	$output[$count]=$_;
	$count++;
	if($count>=4)
	{
		my @a=split(/\s+/,$output[0]);
		my @b=split(/\:/,$a[1]);
		if($b[0] ==1)
		{
			for($i=0;$i<4;$i++)
			{
				print FOUT1 "$output[$i]\n";
			}
		}
		else
		{
			for($i=0;$i<4;$i++)
                        {
                                print FOUT2 "$output[$i]\n";
                        }
		}
		$count=0;
	}
}
close(FIN);
