#! /usr/bin/perl -w
my $inf1=$ARGV[0];
my $inf2=$ARGV[1];

open(FIN,"$inf1");
my %wy=();
my $head="";
while(<FIN>)
{
	chomp;
	if(/^##/)
	{
		next;
	}
	if(/^#CHR/)
	{
		$head=$_;
		next;
	}
	@a=split(/\t/);
	my $index=$a[0]."_".$a[1];
	$wy{$index}=$_;
}
close(FIN);

open(FIN,"$inf2");
my %ken=();
while(<FIN>)
{
	chomp;
        if(/^##/)
        {
                next;
        }
        if(/^#CHR/)
        {
		my @a=split(/\s+/);
		my $size=@a;
		for($i=9;$i<$size;$i++)
		{
			$head=$head."\t".$a[$i];
		}
		next;
	}
	@a=split(/\s+/);
        my $index=$a[0]."_".$a[1];
        $ken{$index}=$_;
}
close(FIN);

my %all=();
foreach my $key(keys %wy)
{
	$all{$key}=$wy{$key};
	if(exists($ken{$key}))
	{
		my @a=split(/\s+/,$ken{$key});
		my $size=@a;
		for($i=9;$i<$size;$i++)
                {
                        $all{$key}=$all{$key}."\t".$a[$i];
                }
	}
	else
	{
		for($i=0;$i<12;$i++)
		{
			$all{$key}=$all{$key}."\t./.";
		}
	}
}

foreach my $key(keys %ken)
{       
        unless(exists($wy{$key}))
        {
                my @a=split(/\s+/,$ken{$key});
                my $size=@a;
		$all{$key}=$a[0];
                for($i=1;$i<9;$i++)
                {
                        $all{$key}=$all{$key}."\t".$a[$i];
                }
		for($i=0;$i<=12;$i++)
		{
			$all{$key}=$all{$key}."\t./.";
		}
		for($i=9;$i<$size;$i++)
                {
                        $all{$key}=$all{$key}."\t".$a[$i];
                }
		
		
        }
}

print STDERR "$head\n";
foreach my $key(keys %all)
{
	
	print STDERR "$all{$key}\n";
}		
