#! /usr/bin/perl -w

my $num_args=$#ARGV + 1;
if($num_args == 1)
{
	$infile=$ARGV[0];
	open(FIN,"$infile");
	while(<FIN>)
	{
		chomp;
		if(/^#CHR/)
		{
			my @a=split(/\t/);
			my $size=@a;
			for($i=9;$i<$size;$i++)
			{
				print STDERR "$a[$i]\n";
			}
			exit(0);
		}
	}
}
elsif($num_args == 2)
{
	$infile1=$ARGV[0];
	$outfile="";
	if($infile1 =~ /^(.*?)\.SNP\.vcf/)
	{
		$outfile=$1.".re_ordered.SNP.vcf";
	}
	elsif($infile1 =~ /^(.*?)\.INDEL\.vcf/)
        {
                $outfile=$1.".re_ordered.INDEL.vcf";
        }
	else
	{
		print STDERR "input has to be a SNP or INDEL vcf file\n";
		exit(0);
	}
	open(FOUT,"> $outfile");

	$infile2=$ARGV[1];
	my @new_order=();
	my %old_order=();
	my $num=0;
	open(FIN,"$infile2");
	while(<FIN>)
	{
		chomp;
		$new_order[$num]=$_;
		$num++;
	}
	close(FIN);

	open(FIN,"$infile1");
	while(<FIN>)
        {
                chomp;
		if(/^##/)
		{
			print FOUT "$_\n";
		}
                elsif(/^#CHR/)
                {
                        my @a=split(/\t/);
                        my $size=@a;

			for($i=0;$i<9;$i++)
			{
				print FOUT "$a[$i]\t";
			}

                        for($i=9;$i<$size-1;$i++)
                        {
                                $old_order{$a[$i]}=$i;
				print FOUT "$new_order[$i-9]\t";
                        }
			$old_order{$a[$size-1]}=$size-1;
			print FOUT "$new_order[$size-10]\n";
                }
		else
		{
			my @a=split(/\t/);
                        my $size=@a;

                        for($i=0;$i<9;$i++)
                        {
                                print FOUT "$a[$i]\t";
                        }

                        for($i=9;$i<$size-1;$i++)
                        {
                                print FOUT "$a[$old_order{$new_order[$i-9]}]\t";
                        }
                        print FOUT "$a[$old_order{$new_order[$size-10]}]\n";	
		}
        }
	close(FIN);
	close(FOUT);	
}
else
{
	print STDERR "wrong input\n";
}
