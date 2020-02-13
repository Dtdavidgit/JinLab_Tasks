library('SKAT')
# set args for command line input
args = unlist(strsplit(commandArgs(trailingOnly = TRUE)," "))
# extract basename
basename = strsplit(basename(args), "\\.")[[1]][1]
# read phenotype file
dat <- read.table(args[1], header=TRUE, stringsAsFactors=FALSE) 
phen = ifelse(dat$PHENOTYPE == 2, 0, 1) 
# read genotype file
geno = as.matrix(dat[,-c(1:6)])
# perform SKAT emmax model
obj <- SKAT_NULL_emmaX(phen~1, out_type="D")

skatT <- SKAT(geno, obj, method ="optimal.adj")
# print p.value 
cat(skatT$p.value)


wardf <- data.frame(V1=paste("warning", 1:length(warnings), ':', sep=""), V2=warnings)
# Output file
output = rbind(
  data.frame(
    V1 = c("individuals", "controls", "cases", paste("pval for rho = ", skatT$param$rho, ":", sep = ""), "test_p:"),
    V2 = c(length(phen), table(phen)[[2]], table(phen)[[1]], skatT$param$p.val.each, skatT$p.value)),
  wardf)
# Write output
write.table(output, paste(basename, "_SKAT.txt", sep=""), col.names=F, quote=F, row.names=F, sep="\t")