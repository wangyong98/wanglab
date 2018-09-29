#! /usr/bin/perl -w

my $infile=$ARGV[0];
open(FIN,"$infile") || die "can't open $infile\n";

my $sample_num=0;
my @sample_name=();

my @tot_num=();
my %trans=();

while(<FIN>)
{
	if(/^##/)
	{
		next;
	}
	elsif(/^#CHROM/)
	{
		my @a=split(/\s+/);
                my $size=@a;
		if($a[$size-1] eq "passcode")
		{
			$sample_num=$size-10;
		}
		else
		{
			print STDERR "Need passcode to work, exiting\n";
			exit(0);
		}

		for($i=0;$i<$sample_num;$i++)
		{
			$sample_name[$i]=$a[9+$i];
			$tot_num[$i]=0;
		}
	}
	else
	{
		my @a=split(/\s+/);
		my $size=@a;
		my $temp=$a[3]."_".$a[4];
		my @b=split(//,$a[$size-1]);
		splice(@b,1,1);
		my $size_b=@b;
		if($size_b - $sample_num != 2)
		{
			print STDERR "Sample number doesn't match, exiting\n";
			exit(0);
		}
		
		for($i=0;$i<$sample_num;$i++)
		{
			if($b[$i+1] eq "1" || $b[$i+1] eq "2")
			{
				$tot_num[$i]++;
				if(exists($trans{$temp}[$i]))
				{
					$trans{$temp}[$i] = $trans{$temp}[$i] + 1;
				}
				else
				{
					$trans{$temp}[$i] = 1;
				}
			}
		}

	}
}
for($i=0;$i<$sample_num;$i++)
{
	print STDERR "\t$sample_name[$i]";
}
print STDERR "\n";

for $temp (keys %trans)
{
	my @a=split(/\_/,$temp);
	$index=$a[0]."=>".$a[1];
	print STDERR "$index\t";
	for($i=0;$i<$sample_num;$i++)
	{
		unless(exists($trans{$temp}[$i]))
		{
			$trans{$temp}[$i]=0;
		}
		print STDERR "$trans{$temp}[$i]\t";
	}
	print STDERR "\n";
}
print STDERR "\ntotal\t";
for($i=0;$i<$sample_num;$i++)
{
	print STDERR "$tot_num[$i]\t";
}
print STDERR "\n\n";

for $temp (keys %trans)
{
        my @a=split(/\_/,$temp);
        $index=$a[0]."=>".$a[1];
        print STDERR "$index\t";
        for($i=0;$i<$sample_num;$i++)
        {
		if($tot_num[$i] >0)
		{
			$per = $trans{$temp}[$i] / $tot_num[$i];
		}
		else
		{
			$per=0;
		}
                printf STDERR "%6.2f\t",$per;
        }
        print STDERR "\n";
}

