#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $outfile=$ARGV[1];

my $DP=6;
my $VN=1;
my $GQ=0;

open(FIN,"$infile") || die "can't open $infile\n";
open(FOUT,"> $outfile") || die "can't open $outfile\n";

my $sample_num=0;
my $passcode="";

while(<FIN>)
{
	chomp;
	if(/^##/)
	{
		print FOUT "$_\n";
	}
	elsif(/^#CHROM/)
	{
		my @a=split(/\t/);
		$size=@a;
		$sample_num=$size-9;
		print FOUT "$_\tpasscode\n";
	}
	else
	{
		$passcode="<";
		my @a=split(/\t/);
		if($a[6] ne "PASS")
		{
			for($i=0;$i<$sample_num;$i++)
			{
				$passcode=$passcode."x";
			}
		}
		else
		{	
			for($i=0;$i<$sample_num;$i++)
                        {
				my @b=split(/\:/,$a[9+$i]);
				#if($b[0] ne "./." && $b[0] ne "0/0")
				if($b[0] ne "./.")
				{
					my @c=split(/\,/,$b[1]);
					if($b[2] >= $DP)
                                        {
                                                if($c[1] >=$VN && $b[3] >=$GQ)
                                                {
                                                        if($b[0] eq "0/1")
                                                        {
                                                                $passcode=$passcode."1";
                                                        }
                                                        elsif($b[0] eq "1/1")
                                                        {
                                                                $passcode=$passcode."2";
                                                        }
                                                        else
                                                        {
								$tmp=$c[1]/$b[2];
								if($tmp>=0.5)
								{
									$passcode=$passcode."2";
								}
								else
								{
                                                                	$passcode=$passcode."1";
								}
                                                        }
                                                }
                                        	else
                                                {
                                                        $passcode=$passcode."0";
                                                }
                                        }
                                        else
                                        {
                                                $passcode=$passcode."x";
                                        }

				}
				else
				{
					$passcode=$passcode."x";
				}
			}
		}
		$passcode=$passcode.">";
		print FOUT "$_\t$passcode\n";
	}
}
close(FIN);
close(FOUT);	
