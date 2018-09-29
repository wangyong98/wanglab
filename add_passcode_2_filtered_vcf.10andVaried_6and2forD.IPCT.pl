#! /usr/bin/perl -w

my $infile=$ARGV[0];
my $outfile=$ARGV[1];

my $DP=10;
my $VN=0.2;
my $GQ=0;

my $DP_P=6;
my $VN_P=2;

open(FIN,"/volumes/neo/database/IPTC/exons_coordinates.full.hg19.clean.bed") || die "can't open exons_coordinates.full.hg19.clean.bed\n";
my $index="";
my %exome=();
while(<FIN>)
{
        chomp;
        my @a=split(/\s+/);
        for($i=$a[1];$i<=$a[2];$i++)
        {
                $index=$a[0]."_".$i;
                $exome{$index}=1;
        }
}
close(FIN);

my $num_pop=1;

open(FIN,"$infile") || die "can't open $infile\n";
open(FOUT,"> $outfile") || die "can't open $outfile\n";

my $sample_num=0;
my $passcode="";
my @samples=();

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
		print STDERR "$sample_num\n";
		for($i=0;$i<$sample_num;$i++)
		{
			$samples[$i]=$a[$i+9];
		}
		print FOUT "$_\tpasscode\n";
	}
	else
	{
		$passcode="<";
		my @a=split(/\t/);
		$index=$a[0]."_".$a[1];

                #Within exome: E, outside exome: N
                if(exists($exome{$index}))
                {
                        $passcode=$passcode."E";
                }
                else
                {
                        $passcode=$passcode."N";
                }

		if($a[6] ne "PASS")
		{
			for($i=0;$i<$sample_num;$i++)
			{
				$passcode=$passcode."x";
			}
		}
		else
		{	
			# For Single Cells
			for($i=0;$i<$sample_num;$i++)
                        {
				# For tumors
				if($samples[$i] ne "TN7N")
				{
					my @b=split(/\:/,$a[9+$i]);
					if($b[0] ne "./.")
					{
						my @c=split(/\,/,$b[1]);
						if($b[2] >= $DP)
                                        	{
							$tmp=$c[1]/$b[2];
                                               		if(( $b[2] <= 20 && $c[1] >=3) || ($b[2] > 20 && $b[2] <= 100 && $tmp >=0.15) || ($b[2] > 100 && $tmp >= 0.1) )
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
				else
				{
					# For normals 
					my @b=split(/\:/,$a[9+$i]);
					if($b[0] ne "./.")
                                	{
                                        	my @c=split(/\,/,$b[1]);
                                        	if($b[2] >= $DP_P)
                                        	{
                                                	$tmp=$c[1]/$b[2];
                                                	if($c[1] >=$VN_P || $tmp >= 0.2 )
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
			
		}
		$passcode=$passcode.">";
		print FOUT "$_\t$passcode\n";
	}
}
close(FIN);
close(FOUT);	
