#!/usr/bin/env python

import sys


def main():

	infilename = sys.argv[1]
	outfilename = sys.argv[2]
	statfilename = sys.argv[3]

	chrominfo = fileToDictionary("/Volumes/sci/code/yongwang_hg19/hg19.chromInfo.cumsum.txt", 0)
	bins = fileToArray("/Volumes/sci/code/yongwang_hg19/bin.boundaries.50k.bowtie.k50.sorted.bin_not_removed.txt", 0)
#	INFILE = open("/home10/vault/kendall/nick/skbr3_02/s_1_48bp.n2.e70.map", "r")
#	OUTFILE = open("/home10/vault/kendall/nick/skbr3_02/s_1_48bp.n2.e70.varbin.txt", "w")
	INFILE = open(infilename, "r")
	OUTFILE = open(outfilename, "w")
	STATFILE = open(statfilename, "w")

	binCounts = []
	for i in range(len(bins)):
		binCounts.append(0)

	counter = 0
	dups = 0
	totalReads = 0
	prevChrompos = ""
	for x in INFILE:
		arow = x.rstrip().split("\t")
		thisChrom = arow[2][3:]
		thisChrompos = arow[3]
#print thisChrom
#		print thisChrompos
		if thisChrom.find("_") > -1:
			continue
		if thisChrom == "M":
			#print thisChrom
			continue
		if thisChrom == "":
			continue
		if thisChrom == "X":
			thisChrom = "23"
		if thisChrom == "Y":
			thisChrom = "24"

		totalReads += 1
		if thisChrompos == prevChrompos:
			dups += 1
			continue
			
		thisChrominfo = chrominfo[thisChrom]
		thisAbspos = long(thisChrompos) + long(thisChrominfo[2])
		
		counter += 1
		#if counter % 100000 == 0:
		#	print counter
		
		indexUp = len(bins) - 1
		indexDown = 0
		indexMid = int((indexUp - indexDown) / 2.0)

		#print thisChrom, thisChrompos, thisAbspos
		while True:
			#print indexDown, indexMid, indexUp
			if thisAbspos >= long(bins[indexMid][2]):
				indexDown = indexMid + 0
				indexMid = int((indexUp - indexDown) / 2.0) + indexMid
			else:
				indexUp = indexMid + 0
				indexMid = int((indexUp - indexDown) / 2.0) + indexDown

			if indexUp - indexDown < 2:
				break

		#print thisChrom, thisChrompos, thisAbspos, bins[indexDown], bins[indexDown+1]
		binCounts[indexDown] += 1
		prevChrompos = thisChrompos
		
	for i in range(len(binCounts)):
		thisRatio = float(binCounts[i]) / (float(counter) / float(len(bins)))
		OUTFILE.write("\t".join(bins[i]))
		OUTFILE.write("\t")
		OUTFILE.write(str(binCounts[i]))
		OUTFILE.write("\t")
		OUTFILE.write(str(thisRatio))
		OUTFILE.write("\n")

	binCounts.sort()
	
	STATFILE.write("TotalReads\tDupsRemoved\tReadsKept\tMedianBinCount\n")
	STATFILE.write(str(totalReads))
	STATFILE.write("\t")
	STATFILE.write(str(dups))
	STATFILE.write("\t")
	STATFILE.write(str(counter))
	STATFILE.write("\t")
	STATFILE.write(str(binCounts[25005]))
	STATFILE.write("\n")
	
	INFILE.close()
	OUTFILE.close()
	STATFILE.close()


def fileToDictionary(inputFile, indexColumn):
	input = open(inputFile, "r")

	rd = dict()
#	input.readline()
	for x in input:
		arow = x.rstrip().split("\t")
		id = arow[indexColumn]
		if rd.has_key(id):
			#rd[id].append(arow)
			print "duplicate knowngene id = " + id
			print "arow =   " + str(arow)
			print "rd[id] = " + str(rd[id])
		else:
			rd[id] = arow
		
	input.close()
	return(rd)


def fileToArray(inputFile, skipFirst):
	input = open(inputFile, "r")

	ra = []

	for i in range(skipFirst):
		input.readline()

	for x in input:
		arow = x.rstrip().split("\t")
		ra.append(arow)
		
	input.close()
	return(ra)


if __name__ == "__main__":
	main()
