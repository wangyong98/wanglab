#! /usr/bin/perl -w

my $infile=$ARGV[0];
my %nonsyn=();

open(FIN,"$infile.nonsynonymous");

while(<FIN>)
{
	chomp;
	if(/^Cosmic/)
	{
		next;
	}
	else
	{
		my @a=split(/\t/);
		my $index=$a[7]."_".$a[8];
		#print STDERR "$index\n";
		$nonsyn{$index}=$a[0]."\t".$a[1]."\t".$a[2]."\t".$a[3]."\t".$a[5]."\t".$a[6];
	}
}
close(FIN);

open(FIN,"$infile");
my %found=();

while(<FIN>)
{
	chomp;
	if(/^#/)
	{
		next;
	}
	my @a=split(/\t/);
	my $index=$a[0]."_".$a[1];
	if(exists($nonsyn{$index}))
	{
		my $code=$a[-1];
		#print STDERR "code is: $code\n";
		my @pass=split(//,$code);
		my @pass17=();
		my $j=0;
		my $size=@pass;
		for($i=1;$i<$size-1;$i++)
		{
			$pass17[$j]=$pass[$i];
			$j++;
		}
		my $stat=0;
		my $comm=0;
		$size=@pass17;
		for($i=0;$i<$size;$i++)
		{
			if($pass17[$i] eq "x")
			{
				$stat=1;
			}
			if($pass17[$i] eq "1" || $pass17[$i] eq "2")
			{
				$comm++;
				$pass17[$i] = "1";
			}
		}
		if($stat!=0 || $comm <=0)
		{
			#next;
		}
		my $pass17_s=join('',@pass17);
		#print STDERR "$comm\t$pass17_s\t$a[0]\t$a[1]\t$nonsyn{$index}\n";
		$found{$index}="$comm\t$pass17_s\t$a[0]\t$a[1]\t$nonsyn{$index}";
	
	}
}
close(FIN);

open(FIN,"$infile.nonsynonymous");

while(<FIN>)
{
        chomp;
        if(/^Cosmic/)
        {
                next;
        }
        else
        {
                my @a=split(/\t/);
                my $index=$a[7]."_".$a[8];
		if(exists($found{$index}))
		{
			my @b=split(/\t/,$found{$index});
			if($b[0] > 0)
			{
				print STDERR "$found{$index}\n";
			}
		}
		else
		{
                	$temp=$a[0]."\t".$a[1]."\t".$a[2]."\t".$a[3]."\t".$a[5]."\t".$a[6];
			print STDERR "NotFound\t$a[7]\t$a[8]\t$temp\n";
		}
        }
}
close(FIN);
