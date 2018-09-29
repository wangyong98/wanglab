#! /usr/bin/perl -w

open(FIN,"hg19.chromInfo.cumsum.txt");
my %abso=();
while(<FIN>)
{
	chomp;
	my @a=split(/\s+/);
	$abso{$a[0]}=$a[2]+1;
}
close(FIN);

open(FIN,"varbin.gc.content.300k.bowtie.k50.hg19.bin_not_removed.txt");
my $chr="0";
while(<FIN>)
{
	chomp;
	if(/^bin/)
	{
		next;
	}
	my @a=split(/\s+/);
	$a[0]=~/^chr(.*?)$/;
	$chr=$1;
	if($chr eq "X")
	{
		$chr="23";
	}
	if($chr eq "Y")
        {
                $chr="24";
        }	
	$relative=$a[1]+1;
	$absolute=$abso{$chr}+$a[1];
	print STDERR "$chr\t$relative\t$absolute\n";
}
close(FIN);
