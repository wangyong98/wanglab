#! /usr/bin/perl -w

my $infile=$ARGV[0];

open(FIN,"$infile");
my %snp=();
while(<FIN>)
{
	chomp;
	@a=split(/\s+/);
	my $index=$a[0]."_".$a[1];
	$snp{$index}=".";
}
close(FIN);

open(FIN,"/volumes/neo/database/dbSNP/hg19/snp137.txt");
while(<FIN>)
{
	chomp;
	@a=split(/\s+/);
	my $index=$a[1]."_".$a[3];
	if(exists($snp{$index}))
	{
		$snp{$index}=$a[4];
	}
}

open(FIN,"$infile");
while(<FIN>)
{
        chomp;
        @a=split(/\s+/);
        my $index=$a[0]."_".$a[1];
	splice(@a,2,0,$snp{$index});
	print STDERR join("\t",@a);
	print STDERR "\n";
}
close(FIN);
