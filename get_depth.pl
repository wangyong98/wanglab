#! /usr/bin/perl -w
my $infile=$ARGV[0];
my $outfile=$infile.".depth";

open(FIN,"/volumes/neo/database/Nextera/NexteraRapidCapture_Exome_TargetedRegions_hg19_clean.bed");
my $index="";
my %exome=();
while(<FIN>)
{
        chomp;
        my @a=split(/\s+/);
        for($i=$a[1];$i<=$a[2];$i++)
        {
                $index=$a[0]."_".$i;
                $exome{$index}="0";
        }
}
close(FIN);

open(FIN,"$infile");
my $total=0;
while(<FIN>)
{
	chomp;
	my @a=split(/\t/);
	$index=$a[0]."_".$a[1];
	if(exists($exome{$index}))
	{
		$depth=$a[3];
		$total+=$depth;
		$exome{$index} = $depth;
		#print STDERR "$a[0]\t$a[1]\t$a[1]\t$exome{$index}\n";
	}
}
close(FIN);
print STDERR "Total reads: $total\n";

open(FIN,"/volumes/neo/database/Nextera/NexteraRapidCapture_Exome_TargetedRegions_hg19_clean.bed");
$total=0;

open(FOUT,"> $outfile");
while(<FIN>)
{
        chomp;
        my @a=split(/\s+/);
        for($i=$a[1];$i<=$a[2];$i++)
        {
		$total++;
                $index=$a[0]."_".$i;
		print FOUT "$exome{$index}\n";
        }
}
close(FIN);
print STDERR "Total sites: $total\n";
