#!/bin/bash

# Envoronment path setting
gatk=/home/david/Scientist_Tasks/tools/gatk-4.1.4.1/gatk
ref=/home/david/Scientist_Tasks/ref/chr22.fa
dbsnp=/home/david/Scientist_Tasks/ref/dbsnp_138.hg19.vcf
mills=/home/david/Scientist_Tasks/ref/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf
phase1_1000g=/home/david/Scientist_Tasks/ref/1000G_phase1.indels.hg19.sites.vcf

# Index reference database
$gatk IndexFeatureFile --input $dbsnp
$gatk IndexFeatureFile --input $mills
$gatk IndexFeatureFile --input $phase1_1000g

cd files
fh=($(ls *bam))
for sp in ${fh[@]}
do
	sample="$(cut -d'.' -f1 <<<$sp)"
	echo $sample
	# Base quality score recalibration
	$gatk BaseRecalibrator -R $ref -I $sp --known-sites $dbsnp --known-sites $phase1_1000g --known-sites $mills -O $sample\_BQSR.output
	# Apply Recalibration
	$gatk ApplyBQSR --bqsr-recal-file $sample\_BQSR.output -R $ref -I $sp -O $sample\_BQSR.bam
	# Generate temp file gvcf for each sample
	$gatk HaplotypeCaller -R $ref -I $sample\_BQSR.bam --emit-ref-confidence GVCF  -O $sample\.g.vcf
done
cd ../

# Combine multiple gvcf files
$gatk GenomicsDBImport -V files/Sample1.g.vcf -V files/Sample2.g.vcf -V files/Sample3.g.vcf --genomicsdb-workspace-path gvcfs_22.db --intervals chr22
# Variant calling
$gatk GenotypeGVCFs -R $ref -V gendb://gvcfs_22.db -O files/final_merge.vcf
