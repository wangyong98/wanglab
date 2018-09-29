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
	my $tmp=$a[$col_num];
	for($i=$tmp-10;$i<=$tmp+10;$i++)
	{
		my $index=$a[$col_num-1]."_".$i;
		$anno{$index}="NA";
	}
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
                for($i=9;$i<$size-1;$i++)
                {
                        my @b=split(/\:/,$a[$i]);
                        if($b[0] ne "./.")
                        {
                                my @c=split(/\,/,$b[1]);
                                $d[$i-9]=round($c[1]/$b[2]);
                        }
                        else
                        {
                                $d[$i-9]=0;
                        }
                }
                $tmp=join(',',@d);
                $cov=$cov.$tmp.">";

		$anno{$index} = $a[$size-1]."\t".$cov."\t".$a[2];
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
	my $found=0;
	if($anno{$index} ne NA)
	{
        	print FOUT "$anno{$index}\t$_\n";
		$found=1;
	}
	else
	{
		$tmp=$a[$col_num];
		for($i=1;$i<=10;$i++)
		{
			$tmp=$a[$col_num] + $i;	
			$index=$a[$col_num-1]."_".$tmp;
			if($anno{$index} ne NA)
			{
				print FOUT "$anno{$index}\t$_\n";
				$found=1;
				last;
			}
			$tmp=$a[$col_num] - $i;
                        $index=$a[$col_num-1]."_".$tmp;
                        if($anno{$index} ne NA)
                        {
                                print FOUT "$anno{$index}\t$_\n";
                                $found=1;
                                last;
                        }
		}
	}
	if($found==0)
	{
		print FOUT "NA\tNA\t$_\n";
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

