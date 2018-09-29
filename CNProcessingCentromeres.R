copyNumberProcessing <- function(dataName = dataName, 
                                 dataDir = dataDir, 
                                 outputDir = outputDir, 
                                 gcName = "/Volumes/sci/code/yongwang_hg19/varbin.gc.content.50k.bowtie.k50.hg19.txt", 
                                 alpha = 0.01,
                                 undo.SD = 2,
                                 min.width=5,
                                 centName = "/Volumes/ark/resource/Projects/genomeInfo/hg19/centromereLoc.txt"){
  #Load library for copynumber processing 
  library("DNAcopy")
  gc <- read.delim(gcName)
  centr.loc <- read.delim(centName, as.is=TRUE)
  
  if (!file.exists(paste(outputDir,"Figures", sep="/"))) 
  { dir.create(paste(outputDir,"Figures", sep="/")) }
  
  if (!file.exists(paste(outputDir,"IGV_shorts", sep="/")))
  { dir.create(paste(outputDir,"IGV_shorts", sep="/")) }
  
  if (!file.exists(paste(outputDir,"IGV_longs", sep="/")))
  { dir.create(paste(outputDir,"IGV_longs", sep="/")) }

cnBins <- NULL
cnRatio <- NULL
for(x in list.files(dataDir, pattern="new.vb50"))
{
  temp <- read.delim(paste(dataDir,x, sep="/"), header=FALSE)
  sample.name <- substring(x, 1, nchar(x) - 9)
  
  if(is.null(cnBins))
  {
    cnBins <- cbind(gc,temp[,1:4])
    cnRatio <- cbind(gc,temp[,c(1:3,5)])
    colnames(cnBins)[which(colnames(cnBins) == "V4")] <- sample.name
    colnames(cnRatio)[which(colnames(cnRatio) == "V5")] <- sample.name
  } else 
    if(!is.null(cnBins))
    {
      temp.bin <- temp$V4
      temp.r <- temp$V5
      cnBins <- cbind(cnBins, temp.bin)
      cnRatio <- cbind(cnRatio, temp.r)
      colnames(cnBins)[which(colnames(cnBins) == "temp.bin")] <- sample.name
      colnames(cnRatio)[which(colnames(cnRatio) == "temp.r")] <- sample.name
    }
}

colnames(cnBins)[match(c("V1", "V2", "V3"), colnames(cnBins))] <- c("chrom","chrompos","abspos")
colnames(cnRatio)[match(c("V1", "V2", "V3"), colnames(cnRatio))] <- c("chrom","chrompos","abspos")

write.table(cnBins[,9:ncol(cnBins)], file = paste(outputDir, "/uber.", dataName, ".bin.txt", sep=""), 
            quote = FALSE, sep = "\t",row.names = FALSE)
write.table(cnRatio[,9:ncol(cnRatio),], file = paste(outputDir, "/uber.", dataName, ".ratio.txt", sep=""),
            quote = FALSE, sep = "\t",row.names = FALSE)

for(x in 12:ncol(cnRatio))
{
  appendFile <- FALSE
  if(x !=12)
  {
    appendFile <- TRUE
  }
  sample.name <- colnames(cnRatio[,c(9:11, x)])[4]
  thisRatio <-  cbind(cnBins[,c(9:11, x)],cnRatio[,x] ) 
  colnames(thisRatio) <-c("chrom", "chrompos", "abspos", "bincount", "ratio")
  thisRatio$ratio[which(thisRatio$ratio == 0)] <- 1e-3
  thisRatio$chrom <- as.numeric(thisRatio$chrom)
  CNA.object <- CNA(log(thisRatio$ratio, base=2), thisRatio$chrom, thisRatio$chrompos, data.type="logratio", 
                    sampleid=sample.name) 
  smoothed.CNA.object <- smooth.CNA(CNA.object) 
  
  segment.smoothed.CNA.object <- segment(smoothed.CNA.object, alpha=alpha, min.width=min.width, undo.splits="sdundo", undo.SD=undo.SD) 
  thisShort <- segment.smoothed.CNA.object[[2]]
  m <- matrix(data=0, nrow=nrow(thisRatio), ncol=1)  
  prevEnd <- 0
  for (i in 1:nrow(thisShort)) {
    thisStart <- prevEnd + 1
    thisEnd <- prevEnd + thisShort$num.mark[i]
    m[thisStart:thisEnd, 1] <- 2^thisShort$seg.mean[i]
    prevEnd = thisEnd
  }
  
  thisRatio$seg.mean.LOWESS <- m[, 1]
  chr <- thisRatio$chrom
  chr.shift <- c(chr[-1], chr[length(chr)])
  vlines <- c(1, thisRatio$abspos[which(chr != chr.shift) + 1], thisRatio$abspos[nrow(thisRatio)])
  hlines <- c(0.5, 1.0, 1.5, 2.0)
  chr.text <- c(1:22, "X", "Y")
  vlines.shift <- c(vlines[-1], 4*10^9)
  chr.at <- vlines + (vlines.shift - vlines) / 2
  x.at <- c(0, 0.5, 1, 1.5, 2, 2.5, 3) * 10^9
  x.labels <- c("0", "0.5", "1.0", "1.5", "2.0", "2.5", "3.0")
  y.at <- c(0.005, 0.020, 0.100, 0.500, 2.000)
  y.labels <- c("0.005", "0.020", "0.100", "0.500", "2.000")
  
  jpeg(paste(outputDir,"/Figures/hg19-", dataName, "-", sample.name, ".jpg", sep=""), height=800, width=1200)
  par(mar=c(5.1,4.1,4.1,4.1))
  plot(x=thisRatio$abspos, y=thisRatio$ratio, log="y", main=paste(sample.name, "Alpha: ", alpha), xaxt="n", 
       xlab="Genome Position Gb", yaxt="n", ylab="Ratio", col="#CCCCCC", cex=0.5)
  axis(1, at=x.at, labels=x.labels)
  axis(2, at=y.at, labels=y.labels)
  lines(x=thisRatio$abspos, y=thisRatio$ratio, col="#CCCCCC", cex=0.5)
  points(x=thisRatio$abspos, y=thisRatio$seg.mean.LOWESS, col="#0000AA", cex=0.5)
  lines(x=thisRatio$abspos, y=thisRatio$seg.mean.LOWESS, col="#0000AA", cex=0.5)
  abline(h=hlines, col="red")
  abline(v= centr.loc$abs, col="red", lty = 2)
  abline(v=vlines, par(lty=2))
  mtext(chr.text, at = chr.at)
  dev.off()
  
  
  write.table(thisRatio, sep="\t", file=paste(outputDir, "/IGV_longs/", dataName, ".", sample.name, ".hg19.50k.varbin.txt", 
                                              sep=""), quote=FALSE, row.names=FALSE) 
  write.table(thisShort, sep="\t", file=paste(outputDir, "/IGV_shorts/", dataName, ".", sample.name, ".hg19.50k.varbin.txt", 
                                              sep=""),  quote=FALSE, row.names=FALSE)  
  write.table(thisShort, sep="\t", file=paste(outputDir, "/IGV_shorts/", dataName, ".all.hg19.50k.varbin.seg", 
                                              sep=""), quote=FALSE, row.names=FALSE, col.names=FALSE, append=appendFile)
}
}
