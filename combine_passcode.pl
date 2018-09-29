#! /usr/bin/perl -w

my $anno_file=$ARGV[0];
my $vcf_file=$ARGV[1];
my $col_num=$ARGV[2];

open(FIN,"$anno_file");
my %anno=();
while(<FIN>)
{
	chomp;
	if(/^Cosmic/)
	{
		next;
	}
	my @a=split(/\t/);
	my $index=$a[$col_num-1]."_".$a[$col_num];
	$anno{$index}=1;
}
close(FIN);

open(FIN,"$vcf_file");
while(<FIN>)
{
	chomp;
	if(/^##/)
	{
		next;
	}
	if(/^#CHR/)
	{
		my @a=split(/\t/);
		my $size=@a;
		if($a[$size-1] ne "passcode")
		{
			print STDERR "VCF doesn't have passcode\n";
			exit(0);
		}
		next;
	}
	my @a=split(/\t/);
	my $size=@a;
	my $index=$a[0]."_".$a[1];
	if(exists($anno{$index}))
	{
		my $cov="<";
		my @d=();
		my @e=();
		for($i=9;$i<$size-1;$i++)
		{
			my @b=split(/\:/,$a[$i]);
			if($b[0] ne "./.")
			{
				my @c=split(/\,/,$b[1]);
				$d[$i-9]=round($c[1]/$b[2]);
				$e[$i-9]=$c[0].":".$c[1];
			}
			else
			{
				$d[$i-9]=0;
				$e[$i-9]="0:0";
			}
		}
		$tmp=join(',',@d);
		$tmp1=join(',',@e);
		$cov=$cov.$tmp.">";
		$anno{$index} = $a[$size-1]."\t".$cov."\t<".$tmp1.">\t".$a[2];
	}
}
close(FIN);	

open(FIN,"$anno_file");
open(FOUT,"> $anno_file.tmp");
while(<FIN>)
{
        chomp;
        if(/^Cosmic/)
        {
		print FOUT "passcode\t$_\n";
                next;
        }
        my @a=split(/\t/);
        my $index=$a[$col_num-1]."_".$a[$col_num];
	 @a=split(/\t/,$anno{$index});
	my @b=split(//,$a[0]);
	my $size=@b;
	my $num=0;
	for($i=2;$i<$size-1;$i++)
	{
		if($b[$i] eq "1" || $b[$i] eq "2")
		{
			$num++;
		}
	}
	if($num>0)
	{
        	print FOUT "$anno{$index}\t$_\n";
	}
	else
	{
		#print FOUT "$anno{$index}\t$_\n";
	}
}
close(FIN);
system("mv $anno_file.tmp $anno_file");


sub round 
{
	my $n=shift;
	$n=int($n*100+0.5)/100;
	return($n);
}
	

