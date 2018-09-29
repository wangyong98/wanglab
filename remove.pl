#! /usr/bin/perl -w

#open(FIN,"/Volumes/ark/resource/Pipelines/CopyNumber/hg19/excluded.txt");
open(FIN,"masked.normal.varbin.bowtie.hg19.txt ");

my %saved=();
while(<FIN>)
{
	chomp;
	unless(/^chr/)
	{
		my @a=split(/\s+/);
		$a[1] -= 1;
		if($a[0] eq "23")
        	{
                	$a[0]="X";
        	}
        	if($a[0] eq "24")
        	{
                	$a[0]="Y";
        	}
        	my $index="chr".$a[0]."_".$a[1];
		$saved{$index}=0;
	}
}
close(FIN);

open(FIN,"varbin.gc.content.50k.bowtie.k50.hg19.txt.old");
while(<FIN>)
{
	chomp;
	my @a=split(/\s+/);
	if($a[0] eq "chr23")
	{
		$a[0]="chrX";
	}
	if($a[0] eq "chr24")
        {
                $a[0]="chrY";
        }
	my $index=$a[0]."_".$a[1];
	if(exists($saved{$index}))
	{
		print STDERR "$_\n";
	}
	else
	{
		$saved{$index}=1;
	}
}
close(FIN);


foreach my $key(keys %removed)
{
	if($removed{$key} != 1)
	{
		#print STDERR "$key\n";
	}
}
