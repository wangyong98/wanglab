#! /usr/bin/perl -w

my $infile=$ARGV[0];
my %vcf=();
open(FIN,"$infile");
while(<FIN>)
{
	chomp;
	if(/^#/)
	{
		next;
	}
	my @a=split(/\t/);
	my $tmp=$a[1]+1;
	my $index=$a[0]."_".$tmp;
	$vcf{$index}=$a[3]."_".$a[4];
	
}
close(FIN);

open(FIN,"/Volumes/sci/genomes/hg19/hg19_all.fa");
my $cur_chr="";
my $cur_pos=0;
my @store=();
while(<FIN>)
{
	chomp;
	if(/^\>(.*?)$/)
	{
		$cur_chr=$1;
		$cur_pos=0;
		for(my $i=0;$i<3;$i++)
		{
			$store[$i]="E";
		}
		next;
	}
	my @a=split(//);
	my $size=@a;
	for(my $i=0;$i<$size;$i++)
	{
		my $allele = uc($a[$i]);
		push(@store,"$allele");
		shift(@store);
		$cur_pos++;
		my $index=$cur_chr."_".$cur_pos;
		if(exists($vcf{$index}))
		{
			my @b=split(/\_/,$vcf{$index});
			if($store[1] ne $b[0])
			{
				print STDERR "wrong: $store[0]\t$b[0]==>$b[1]\t$store[2]\t$index\n";
				exit(0);
			}
			print STDERR "$store[0]\t$b[0]==>$b[1]\t$store[2]\n";
		}
	}
}
close(FIN); 	
