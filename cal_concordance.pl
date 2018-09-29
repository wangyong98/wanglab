#! /usr/bin/perl -w

my @samples=();
my @con=();
my $num=0;

my $infile=$ARGV[0];
open(FIN,"$infile");
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
		$size=@a;
		$num=$size-10;
		for($i=9;$i<$size-1;$i++)
		{
			$samples[$i-9]=$a[$i];
		}
		last;
	}
	
}
close(FIN);
for($i=0;$i<$num;$i++)
{
	$con[$i][$i]=1;
}

for($i=0;$i<$num;$i++)
{
	for($j=$i+1;$j<$num;$j++)
	{
		my $code="<E";
		my $code1="<E";
		my $code2="<E";

		my $value=0;
		my $value1=0;
		my $value2=0;

		for($k=0;$k<$i;$k++)
		{
			$code=$code.".";
			$code1=$code1.".";
			$code2=$code2.".";
		}
		$code=$code."[1|2]";
		$code1=$code1."[1|2]";
		$code2=$code2."0";
		for($k=$i+1;$k<$j;$k++)
		{
			$code=$code.".";
			$code1=$code1.".";
			$code2=$code2.".";
		}
		$code=$code."[1|2]";
		$code1=$code1."0";
		$code2=$code2."[1|2]";
		for($k=$j+1;$k<$num;$k++)
		{
			$code=$code.".";
			$code1=$code1.".";
			$code2=$code2.".";
		}
		$code=$code.">";
		$code1=$code1.">";
		$code2=$code2.">";
		#print STDERR "$code\t$code1\t$code2\n";
		$value=`grep \"$code\" $infile|wc -l`;
		$value1=`grep \"$code1\" $infile|wc -l`;
		$value2=`grep \"$code2\" $infile|wc -l`;
		chomp($value);
		chomp($value1);
		chomp($value2);

		$con[$i][$j]=$value/($value+$value1);
		$con[$j][$i]=$value/($value+$value2);
		#print STDERR "$con[$i][$j]\t$con[$j][$i]\n";
	}
}

for($i=0;$i<$num;$i++)
{
	print STDERR "$samples[$i]\t";
}
print STDERR "\n";

for($i=0;$i<$num;$i++)
{
        for($j=0;$j<$num;$j++)
        {
		print STDERR "$con[$i][$j]\t";
	}
	print STDERR "\n";
}
