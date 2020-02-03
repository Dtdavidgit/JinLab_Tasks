#!/bin/bash

###Declare command and reference path

gatk=/home/david/Scientist_Tasks/tools/gatk-4.1.4.1/gatk
ref=/home/david/Scientist_Tasks/ref/chr22.fa


###Build reference index
bwa index $ref
$gatk CreateSequenceDictionary -R $ref -O $ref\.dict
samtools faidx $ref

###Acquire sample and start bwa mapping

fh=($(ls -d Sample*))
for sp in ${fh[@]}
do
	cd $sp
	pwd
	read1=$(ls -d *r1.fq.gz)
	read2=$(ls -d *r2.fq.gz)
	rgv=$(cat *rgfile)
	bwa mem -t 10 -M -Y -R $rgv $ref $read1 $read2 1>$sp\.sam 2>/dev/null
	samtools view -b -S $sp\.sam > $sp\.bam
	$gatk SortSam --INPUT $sp\.bam --OUTPUT $sp\.sort.bam --SO coordinate
	$gatk MarkDuplicates --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 8000 --INPUT $sp\.sort.bam --OUTPUT $sp\.sort.dedup.bam --METRICS_FILE $sp\.sort.dedup.metrics
	samtools index $sp\.sort.dedup.bam
	start=$(date +%s.%N)
	echo stats `date`
	samtools flagstat $sp\.sort.dedup.bam > $sp.alignment.flagstat
	samtools stats  $sp\.sort.dedup.bam > $sp\.alignment.stat
	rm $sp\.sam
	rm $sp\.bam
	rm $sp\.sort.bam
	echo plot-bamstats -p $sp\_QC  $sp\.alignment.stat
cd ../
done
