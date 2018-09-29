#! /usr/bin/perl -w

open(FIN,"hg19_all_len.txt");
my $pre=0;
while(<FIN>)
{
	chomp;
	if(/^chr(.*?)\s+LN\:(.*?)$/)
	{
		print STDERR "$1\t$2\t$pre\n";
		$pre+=$2;
	}
}
