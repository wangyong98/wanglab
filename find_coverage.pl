#! /usr/bin/perl -w

$in1=$ARGV[0];
$in2=$ARGV[1];

my %mutations=();
open(FIN,"$in1");
while(<FIN>)
{
	chomp;
	my @a=split(/\s+/);
	my $index=$a[0]."_".$a[1];
	$mutations{$index}="";
}
close(FIN);

open(FIN,"$in2");
while(<FIN>)
{
	chomp;
	if(/^#/)
	{
		next;
	}
	my @a=split(/\s+/);
	$size=@a;
	my $index=$a[0]."_".$a[1];
	if(exists($mutations{$index}))
	{
		for($i=9;$i<$size-1;$i++)
		{
			@b=split(/\:/,$a[$i]);
			$sizeb=@b;
			if($sizeb>1)
			{
				$mutations{$index}=$mutations{$index}.$b[1].":";
			}	
			else
			{
				$mutations{$index}=$mutations{$index}."x:";
			}
		}
	}
		
}

open(FIN,"$in1");
while(<FIN>)
{
        chomp;
        my @a=split(/\s+/);
        my $index=$a[0]."_".$a[1];
	
       	print STDERR "$_\t$mutations{$index}\n";
}
close(FIN);
