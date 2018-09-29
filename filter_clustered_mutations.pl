#! /usr/bin/perl -w

my $indel=$ARGV[0];
my $snp=$ARGV[1];

my %cluster_snp=();
open(FIN,"$snp");
my $pre_chr="chr0";
my $pre_pos=-1000;
while(<FIN>)
{
	chomp;
	if(/^#/)
	{
		next;
	}
	my @a=split(/\t/);
	if($a[0] eq $pre_chr && ($a[1] - $pre_pos <10))
	{
		my $index=$pre_chr."_".$pre_pos;
		$cluster_snp{$index}=1;
		$index=$a[0]."_".$a[1];
		$cluster_snp{$index}=1;
		#print STDERR "$pre_chr\t$pre_pos\t$a[0]\t$a[1]\n";
	}
	$pre_chr=$a[0];
	$pre_pos=$a[1];
}
close(FIN);

my %cluster_indel=();
open(FIN,"$indel");
$pre_chr="chr0";
$pre_pos=-1000;
while(<FIN>)
{
        chomp;
        if(/^#/)
        {
                next;
        }
        my @a=split(/\t/);
        if($a[0] eq $pre_chr && ($a[1] - $pre_pos <10))
        {
                my $index=$pre_chr."_".$pre_pos;
                $cluster_indel{$index}=1;
                $index=$a[0]."_".$a[1];
                $cluster_indel{$index}=1;
                #print STDERR "$pre_chr\t$pre_pos\t$a[0]\t$a[1]\n";
        }
        $pre_chr=$a[0];
        $pre_pos=$a[1];
}
close(FIN);

open(FIN,"$indel");
open(FOUT,"> indel_tmp.bed");
while(<FIN>)
{
	chomp;
	if(/^#/)
	{
		next;
	}
	
	my @a=split(/\s+/);
	my @ref=split(//,$a[3]);
	my @alt=split(//,$a[4]);
	my $size_ref=@ref;
	my $size_alt=@alt;
	my $start=$a[1]-10;
	if($start<0)
	{
		$start=0;
	}
	my $end=$a[1];
	if($size_ref>$size_alt)
	{
		$end=$a[1]+$size_ref+10;	
	}
	else
	{
		$end=$a[1]+10;
	}
	print FOUT "$a[0]\t$start\t$end\t$a[1]\n";
}
close(FIN);
close(FOUT);

open(FIN,"$snp");
open(FOUT,"> snp_tmp.bed");
while(<FIN>)
{
        chomp;
        if(/^#/)
        {
                next;
        }

        my @a=split(/\s+/);
	print FOUT "$a[0]\t$a[1]\t$a[1]\n";
}
close(FIN);
close(FOUT);

system("/volumes/neo/code/3rd_party/bedtools2-master/bin/intersectBed -wo -a indel_tmp.bed -b snp_tmp.bed >& indel_snp_tmp.bed");
open(FIN,"indel_snp_tmp.bed");
my %de_snp=();
my %de_indel=();
while(<FIN>)
{
	chomp;
	my @a=split(/\s+/);
	my $index=$a[0]."_".$a[3];
	$de_indel{$index}=1;
	$index=$a[4]."_".$a[5];
	$de_snp{$index}=1;
}
close(FIN);

$indel=~/^(.*?)\.INDEL\.vcf$/;
$indel_out=$1.".cluster_filtered.INDEL.vcf";
open(FIN,"$indel");
open(FOUT,"> $indel_out");
while(<FIN>)
{
	chomp;
	if(/^#/)
	{
		print FOUT "$_\n";
		next;
	}
	my @a=split(/\s+/);
	my $index=$a[0]."_".$a[1];
	if(!exists($de_indel{$index}) && !exists($cluster_indel{$index}))
	{
		print FOUT "$_\n";
	}
}
close(FIN);
close(FOUT);

$snp=~/^(.*?)\.SNP\.vcf$/;
$snp_out=$1.".cluster_filtered.SNP.vcf";
open(FIN,"$snp");
open(FOUT,"> $snp_out");
while(<FIN>)
{
        chomp;
        if(/^#/)
        {
                print FOUT "$_\n";
                next;
        }
        my @a=split(/\s+/);
        my $index=$a[0]."_".$a[1];
        if(!exists($de_snp{$index}) && !exists($cluster_snp{$index}) )
        {
                print FOUT "$_\n";
        }
}
close(FIN);
close(FOUT);		
system("rm -f snp_tmp.bed indel_snp_tmp.bed indel_tmp.bed");
