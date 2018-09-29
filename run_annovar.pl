#! /usr/bin/perl -w
use File::Basename;

my $infile=$ARGV[0];


my $file=basename($infile,".vcf");
my $dir=dirname($infile);

my $cmd="/volumes/neo/code/3rd_party/annovar_hg19/convert2annovar.pl --format vcf4old $infile -outfile  $dir/tmp.avinput";
#print STDERR "$cmd\n";
system("$cmd");

$cmd="/volumes/neo/code/3rd_party/annovar_hg19/annotate_variation.pl -geneanno -buildver hg19 $dir/tmp.avinput /volumes/neo/code/3rd_party/annovar_hg19/humandb/";
#print STDERR "$cmd\n";
system("$cmd");

$cmd=" egrep \'ncRNA\' $dir/tmp.avinput.variant_function >& $dir/tmp.avinput.ncRNA";
system("$cmd");

$cmd="cut -f1-3,5 $dir/tmp.avinput >& $dir/tmp.avinput.bed";
system("$cmd");
$cmd="/volumes/neo/code/3rd_party/bedtools2-master/bin/intersectBED -a $dir/tmp.avinput.bed -b /volumes/neo/database/CancerGenes/CancerGenes.bed -wa -wb >& $dir/tmp.avinput.gene";
system("$cmd");

$cmd="/volumes/neo/code/3rd_party/annovar_hg19/annotate_variation.pl -filter -dbtype cosmic70 -buildver hg19 $dir/tmp.avinput /volumes/neo/code/3rd_party/annovar_hg19/humandb/";
system("$cmd");

open(FIN,"$dir/tmp.avinput.gene");
my %gene=();
while(<FIN>)
{
        chomp;
        my @a=split(/\t/);
        $temp=$a[0]."_".$a[1];
        $gene{$temp}=$a[7];
}
close(FIN);

open(FIN,"$dir/tmp.avinput.hg19_cosmic70_dropped");
my %cosmic=();
while(<FIN>)        {
        chomp;
        my @a=split(/\t/);                
	$temp=$a[2]."_".$a[3];
        $cosmic{$temp}=$a[1];
}        
close(FIN);

open(FIN,"$dir/tmp.avinput.ncRNA");
open(FOUT,"> $infile\.ncRNA");
print FOUT "Cosmic\tCancerGene\tRNA\tName\tCHR\tPos\n";
while(<FIN>)
{
        chomp;
        my @a=split(/\t/);
        $temp=$a[2]."_".$a[3];
        $out="";
        if(exists($gene{$temp}))
        {
                $out=$gene{$temp}."\t".$_;
        }
        else
        {
                $out="NA\t".$_;
        }
        if(exists($cosmic{$temp}))
        {
                $out=$cosmic{$temp}."\t".$out;
        }
        else
        {
                $out="NA\t".$out;
        }
        print FOUT "$out\n";
}
close(FIN);
close(FOUT);

$cmd="/volumes/neo/code/3rd_party/annovar_hg19/annotate_variation.pl -filter -dbtype ljb26_pp2hdiv -buildver hg19 $dir/tmp.avinput /volumes/neo/code/3rd_party/annovar_hg19/humandb/ ";
system("$cmd");
$cmd="/volumes/neo/code/3rd_party/annovar_hg19/annotate_variation.pl -filter -dbtype ljb26_sift -buildver hg19 $dir/tmp.avinput /volumes/neo/code/3rd_party/annovar_hg19/humandb/ ";
system("$cmd");
$cmd="/volumes/neo/code/3rd_party/annovar_hg19/annotate_variation.pl -filter -dbtype ljb26_mt -buildver hg19 $dir/tmp.avinput /volumes/neo/code/3rd_party/annovar_hg19/humandb/";
system("$cmd");
$cmd="/volumes/neo/code/3rd_party/annovar_hg19/annotate_variation.pl -filter -dbtype clinvar_20140929 -buildver hg19 $dir/tmp.avinput /volumes/neo/code/3rd_party/annovar_hg19/humandb/";
system("$cmd");

my %mt=();
my %clinic=();
my %sift=();
my %poly=();
open(FIN,"$dir/tmp.avinput.hg19_ljb26_sift_dropped");
while(<FIN>)
{
        chomp;
        my @a=split(/\t/);
        $temp=$a[2]."_".$a[3];
        $sift{$temp}=$a[1];
}
close(FIN);

open(FIN,"$dir/tmp.avinput.hg19_ljb26_pp2hdiv_dropped");
while(<FIN>)
{
        chomp;
        my @a=split(/\t/);
        $temp=$a[2]."_".$a[3];
        $poly{$temp}=$a[1];
}
close(FIN);

open(FIN,"$dir/tmp.avinput.hg19_ljb26_mt_dropped");
while(<FIN>)
{
        chomp;
        my @a=split(/\t/);
        $temp=$a[2]."_".$a[3];
        $mt{$temp}=$a[1];
}
close(FIN);

open(FIN,"$dir/tmp.avinput.hg19_clinvar_20140929_dropped");
while(<FIN>)
{
        chomp;
        my @a=split(/\t/);
        $temp=$a[2]."_".$a[3];
        $clinic{$temp}=$a[1];
}
close(FIN);


if($file =~ /SNV|SNP/)
{
	$cmd=" grep \"nonsynonymous\\\|stop\\\|UNKNOWN\" $dir/tmp.avinput.exonic_variant_function >& $dir/tmp.avinput.nonsynonymous";
	print STDERR "$cmd\n";
	system("$cmd");

	open(FIN,"$dir/tmp.avinput.nonsynonymous");
	open(FOUT,"> $infile\.nonsynonymous");
	print FOUT "Cosmic\tCancerGene\tPOLY\tSIFT\tMutationTaster\tClinVar\n";
	while(<FIN>)
        {
                chomp;
                my @a=split(/\t/);
		$temp=$a[3]."_".$a[4];
		$out="";
		if(exists($clinic{$temp}))
                {
                        $out=$clinic{$temp}."\t".$_;
                }
                else
                {
                        $out="NA\t".$_;
                }
                if(exists($mt{$temp}))
                {
                        $out=$mt{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
		if(exists($sift{$temp}))
		{
			$out=$sift{$temp}."\t".$out;
		}
		else
		{
			$out="NA\t".$out;
		}
		if(exists($poly{$temp}))
                {
                        $out=$poly{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
		if(exists($gene{$temp}))
                {
                        $out=$gene{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($cosmic{$temp}))
                {
                        $out=$cosmic{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

		print FOUT "$out\n";
		
	}
	close(FIN);
	close(FOUT);	
	#print STDERR "$cmd\n";

	$cmd=" grep -w \"intronic\" $dir/tmp.avinput.variant_function >& $dir/tmp.avinput.intronic";
        print STDERR "$cmd\n";
        system("$cmd");

        open(FIN,"$dir/tmp.avinput.intronic");
        open(FOUT,"> $infile\.intronic");
        print FOUT "Cosmic\tCancerGene\tPOLY\tSIFT\n";
        while(<FIN>)
        {
                chomp;
                my @a=split(/\t/);
                $temp=$a[2]."_".$a[3];
                $out="";
		if(exists($clinic{$temp}))
                {
                        $out=$clinic{$temp}."\t".$_;
                }
                else
                {
                        $out="NA\t".$_;
                }
                if(exists($mt{$temp}))
                {
                        $out=$mt{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

                if(exists($sift{$temp}))
                {
                        $out=$sift{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($poly{$temp}))
                {
                        $out=$poly{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($gene{$temp}))
                {
                        $out=$gene{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($cosmic{$temp}))
                {
                        $out=$cosmic{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

                print FOUT "$out\n";

        }
        close(FIN);
        close(FOUT);
	
	$cmd=" grep -w \"synonymous\" $dir/tmp.avinput.exonic_variant_function >& $dir/tmp.avinput.synonymous";
        print STDERR "$cmd\n";
        system("$cmd");

        open(FIN,"$dir/tmp.avinput.synonymous");
        open(FOUT,"> $infile\.synonymous");
        print FOUT "Cosmic\tCancerGene\tPOLY\tSIFT\n";
        while(<FIN>)
        {
                chomp;
                my @a=split(/\t/);
                $temp=$a[3]."_".$a[4];
                $out="";
		if(exists($clinic{$temp}))
                {
                        $out=$clinic{$temp}."\t".$_;
                }
                else
                {
                        $out="NA\t".$_;
                }
                if(exists($mt{$temp}))
                {
                        $out=$mt{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

                if(exists($sift{$temp}))
                {
                        $out=$sift{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($poly{$temp}))
                {
                        $out=$poly{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($gene{$temp}))
                {
                        $out=$gene{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($cosmic{$temp}))
                {
                        $out=$cosmic{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

                print FOUT "$out\n";

        }
        close(FIN);
        close(FOUT);	
	my $tmpfile=$infile.".nonsynonymous";
	$cmd="/volumes/neo/code/yongwang_hg19/combine_passcode.pl $tmpfile $infile 10";
	system("$cmd");

	$tmpfile=$infile.".synonymous";
	$cmd="/volumes/neo/code/yongwang_hg19/combine_passcode.pl $tmpfile $infile 10";
	system("$cmd");
	
	$tmpfile=$infile.".intronic";
	$cmd="/volumes/neo/code/yongwang_hg19/combine_passcode.pl $tmpfile $infile 9";
	system("$cmd");

	$tmpfile=$infile.".ncRNA";
        $cmd="/volumes/neo/code/yongwang_hg19/combine_passcode_INDEL.pl $tmpfile $infile 5";
        system("$cmd");
}
else
{
	$cmd=" grep \"frame\\\|stop\\\|UNKNOWN\" $dir/tmp.avinput.exonic_variant_function >& $dir/tmp.avinput.frameshift";
	#print STDERR "$cmd\n";
	system("$cmd");
	open(FIN,"$dir/tmp.avinput.frameshift");
        open(FOUT,"> $infile\.frame");
	print FOUT "Cosmic\tCancerGene\tPOLY\tSIFT\n";
        while(<FIN>)
        {
                chomp;
                my @a=split(/\t/);
                $temp=$a[3]."_".$a[4];
                $out="";
		if(exists($clinic{$temp}))
                {
                        $out=$clinic{$temp}."\t".$_;
                }
                else
                {
                        $out="NA\t".$_;
                }
                if(exists($mt{$temp}))
                {
                        $out=$mt{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

                if(exists($sift{$temp}))
                {
                        $out=$sift{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($poly{$temp}))
                {
                        $out=$poly{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($gene{$temp}))
                {
                        $out=$gene{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }
                if(exists($cosmic{$temp}))
                {
                        $out=$cosmic{$temp}."\t".$out;
                }
                else
                {
                        $out="NA\t".$out;
                }

                print FOUT "$out\n";

        }
        close(FIN);
        close(FOUT);
	
	my $tmpfile=$infile.".frame";
        $cmd="/volumes/neo/code/yongwang_hg19/combine_passcode_INDEL.pl $tmpfile $infile 10";
        system("$cmd");

	$tmpfile=$infile.".ncRNA";
	$cmd="/volumes/neo/code/yongwang_hg19/combine_passcode_INDEL.pl $tmpfile $infile 5";
	system("$cmd");	
}

$cmd="rm -f $dir/tmp*";
system("$cmd");

