#! /usr/bin/perl -w
use Cwd;
my $cwd=getcwd;

my $infile=$ARGV[0];

if($infile=~/^(.*?)\.vcf$/)
{
	$prefix=$1;
}
else
{
	print STDERR "input should be vcf file\n";
	exit(1);
}

my $tranchesFile=$cwd."/".$infile.".tranchesFile";
my $recalFile=$cwd."/".$infile.".recal";
my $rscriptFile=$cwd."/".$infile.".R";
my $filteredFile=$cwd."/".$prefix.".filtered.vcf";

$cmd="java -Xmx32g -jar /volumes/neo/code/3rd_party/GATKv3.3/GenomeAnalysisTK.jar -T VariantRecalibrator -input $infile -tranchesFile $tranchesFile -recalFile $recalFile -rscriptFile $rscriptFile -mode BOTH -R /volumes/neo/genomes/hg19/hg19_all.fa -resource:hapmap,VCF,known=false,training=true,truth=true,prior=15.0 /volumes/neo/code/3rd_party/GATKv3.3/GATK_resources/hapmap_3.3.hg19.sites.vcf -resource:omni,VCF,known=false,training=true,truth=false,prior=12.0 /volumes/neo/code/3rd_party/GATKv3.3/GATK_resources/1000G_omni2.5.hg19.sites.vcf -resource:dbsnp,VCF,known=true,training=false,truth=false,prior=8.0 /volumes/neo/code/3rd_party/GATKv3.3/GATK_resources/dbsnp_135.hg19.excluding_sites_after_129.vcf -resource:mills,VCF,known=true,training=true,truth=true,prior=12.0 /volumes/neo/code/3rd_party/GATKv3.3/GATK_resources/Mills_and_1000G_gold_standard.indels.hg19.vcf -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum  -an MQ  -an DP -an FS -U ALLOW_SEQ_DICT_INCOMPATIBILITY";

system("$cmd");

$cmd="java -Xmx32g -jar /volumes/neo/code/3rd_party/GATKv3.3/GenomeAnalysisTK.jar -T ApplyRecalibration -input $infile -recalFile $recalFile -tranchesFile $tranchesFile -o $filteredFile -mode BOTH -R /volumes/neo/genomes/hg19/hg19_all.fa";

system("$cmd");
