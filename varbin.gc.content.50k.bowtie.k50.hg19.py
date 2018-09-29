#!/usr/bin/env python

import re
import sys
import random
import string

def main():

	outfilename = "varbin.gc.content.50k.bowtie.k50.hg19.txt"

	bins = fileToArray("varbin.gene.cgi.counts.50k.bowtie.k50.hg19.txt", True)
	
	prevChrom = ""
	INFILE = False
	OUTFILE = open(outfilename, "w")
	
	for arow in bins:
		thisChrom = arow[0].strip()
		if thisChrom == "23":
			thisChrom = "X"
		if thisChrom == "24":
			thisChrom = "Y"
		thisChrom = thisChrom
		thisStart = int(arow[1].strip())
		thisEnd = int(arow[2].strip())
		
		if thisChrom == prevChrom:
			pass
		else:
			if INFILE:
				INFILE.close()
			INFILE = open("/data/safe/kendall/sequences/hg19/" + thisChrom + ".fa", "r")
			chr = []
			x = ""
			y = ""
			INFILE.readline()
			for x in INFILE:
				chr.append(x.rstrip())
			x = "".join(chr)
			y = x.upper()
			print "after read " + thisChrom
			prevChrom = thisChrom
			
		gcContent = float(len(re.findall("[CG]", y[(thisStart):(thisEnd+1)]))) / float(len(re.findall("[ACGT]", y[(thisStart):(thisEnd+1)])))
		OUTFILE.write("\t".join(arow))
		OUTFILE.write("\t")
		OUTFILE.write(str(gcContent))
		OUTFILE.write("\n")
		OUTFILE.flush()
	
	INFILE.close()
	OUTFILE.close()


def fileToArray(inputFile, skipFirst):
	input = open(inputFile, "r")

	ra = []
	if skipFirst:
		input.readline()
	for x in input:
		arow = x.rstrip().split("\t")
		ra.append(arow)
		
	input.close()
	return(ra)



if __name__ == "__main__":
	main()
