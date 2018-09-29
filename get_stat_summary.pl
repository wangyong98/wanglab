#! /usr/bin/perl -w

system("head -n 2 *.cal >& tmp.txt");
open(FIN,"tmp.txt");
my %samples=();
my $sample="";
while(<FIN>)
{
	chomp;
	
	if(/^==> (.*?)\.bam/)
	{
		$sample=$1;
		@a=split(/\./,$sample);
		$sample=$a[0];
		next;
	}
	if(/^average depth = (.*?)$/)
	{
		$samples{$sample}="depth=\t".$1;
		next;
	}
	if(/^genome	0\s+/)
	{
		my @a=split(/\s+/);
		$tmp=1-$a[-1];
		$samples{$sample}=$samples{$sample}."\tbreadth=\t".$tmp;
		next;
	}
}
close(FIN);

system("head -n 5 *.flag >& tmp.txt");
open(FIN,"tmp.txt");
while(<FIN>)
{
        chomp;

        if(/^==> (.*?)\.mark/)
        {
                $sample=$1;
                next;
        }
	if(/^(.*?) \+ 0 in total/)
	{
		if(exists($samples{$sample}))
		{
			$samples{$sample}=$samples{$sample}."\tTotal=\t".$1;
		}
		else
		{
			$samples{$sample}="Total=\t".$1;
		}
		next;
	}	
	if(/^(.*?) \+ 0 duplicates/)
        {
                $samples{$sample}=$samples{$sample}."\tdup=\t".$1;
                next;
        }
	if(/^(.*?) \+ 0 mapped/)
        {
                $samples{$sample}=$samples{$sample}."\tMapped=\t".$1;
                next;
        }
}

print STDERR "Sample\tTotal\tmapped\tmapping_rate\tduplicates\tdup_rate\tdepth\tbreadth\n";
foreach my $key(sort keys %samples)
{
        #print STDERR "$key\t$samples{$key}\n";
        @a=split(/\t/,$samples{$key});
	$size=@a;
	if($size > 5)
	{
        	$map_rate=$a[9]/$a[5];
        	$dup_rate=$a[7]/$a[9];
        	print STDERR "$key\t$a[5]\t$a[9]\t$map_rate\t$a[7]\t$dup_rate\t$a[1]\t$a[3]\n";
	}
	else
	{
		print STDERR "$key\t$a[1]\t$a[3]\n";
	}
}

