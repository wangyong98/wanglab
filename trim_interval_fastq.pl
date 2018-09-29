#!/usr/bin/perl -w
# Removes beginning and end of sequence
#Remove first 28 bases: trim_interval_fastq.pl C05M-26.fastq C05M-26.trim28.fastq 28 100


use strict;
use warnings;

my $infile=$ARGV[0];
my $outfile=$ARGV[1];
my $bp_start=$ARGV[2];
my $bp_stop=$ARGV[3];
my $seqlength = $bp_stop-$bp_start;

open(IN, "less $infile|") or die "cannot open $!\n";
open(OUT, ">$outfile") or die "cannot open $!\n";

while (my $line=<IN>)
{
   chomp($line);
   if ($line =~ /^@/ | $line =~/^\+/)
     { 
       print OUT "$line\n"; 
       $line=<IN>; 
       my $seq=substr($line, $bp_start, $seqlength);
        print OUT "$seq\n";
     }
}
close(IN);
close(OUT);

