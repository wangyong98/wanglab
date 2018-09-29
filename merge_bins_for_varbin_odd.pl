#! /usr/bin/perl -w

my $bin_num=3;
my $count=0;
my @st=();
for($i=0;$i<$bin_num;$i++)
{
	$st[$i]="chr1";
}
open(FIN,"varbin.gc.content.100k.bowtie.k50.hg19.bin_not_removed.txt");
while(<FIN>)
{
	chomp;
	if(/^bin/)
	{
		print STDERR "$_\n";
		next;
	}
	$count++;
	push(@st,$_);
	shift(@st);
	if($count == $bin_num)
	{
		$count=0;
		#print STDERR "$st[0]\n$st[1]\n";
		my @a=split(/\t/,$st[0]);
		my @b=split(/\t/,$st[1]);
		my @c=split(/\t/,$st[2]);
		if($a[0] ne $b[0])
		{
			print STDERR "$st[0]\n";
			$count++;
			next;
		}
		else
		{
			$length=$a[3] + $b[3] + $c[3];
			$gene=$a[4] + $b[4] + $c[4];
			$cgi= $a[5] + $b[5] + $c[5];
			$gc = ($a[7]*$a[3] + $b[7]*$b[3] + $c[7]*$c[3])/($a[3] + $b[3] + $c[3]);
			print STDERR "$a[0]\t$a[1]\t$c[2]\t$length\t$gene\t$cgi\t$c[6]\t$gc\n";
		}	
	}
}
close(FIN);	
if($count==1 || $count ==2)
{
	print STDERR "$st[2]\n";
}
