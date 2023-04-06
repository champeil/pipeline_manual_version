#!/bin/bash
# this script is for qc of bwa results
# author: laojp
# time: 2023.03.31
# position: SYSUCC bioinformatic platform
# version: 1.0
# ps: the script is a function and need to source by main script
# usage: gatk_pair_process sample input_dir output_dir

# update: will consider single and paired end
# update: will consider in nextflow
# update: will consider different software version
# update: will consider different reference

function gatk_pair_process {
	local gatk=/home/laojp/software/gatk_4.2.6.1/gatk-4.2.6.1
	local reference_gatk=/home/laojp/reference/human/GATK/hg38/Homo_sapiens_assembly38.fasta
	local reference_dbsnp=/home/laojp/reference/human/GATK/hg38/dbsnp_146.hg38.vcf.gz
	local reference_indel=/home/laojp/reference/human/GATK/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

	if [ ! -f ${3}/${1}_marked.bam ]; then
		${gatk}/gatk --java-options "-Xmx100G -Djava.io.tmpdir=./" MarkDuplicates \
			-I ${2}/${1}.bam \
			--REMOVE_DUPLICATES true \
			-O ${3}/${1}_marked.bam \
			-M ${3}/${1}.metrics \
			1>${3}/${1}_marked_log 2>&1
	fi
	if [ ! -f ${3}/${1}_bqsr.bam ]; then
		${gatk}/gatk --java-options "-Xmx100G -Djava.io.tmpdir=./" BaseRecalibrator \
			-R ${reference_gatk} \
			-I ${3}/${1}_marked.bam \
			--known-sites ${reference_dbsnp} \
			--known-sites ${reference_indel} \
			-O ${3}/${1}_recal.table \
			1>${3}/${1}_recal_log 2>&1
		${gatk}/gatk --java-options "-Xmx100G -Djava.io.tmpdir=./" ApplyBQSR \
			-R ${reference_gatk} \
			-I ${3}/${1}_marked.bam \
			-bqsr ${3}/${1}_recal.table \
			-O ${3}/${1}_bqsr.bam \
			1>${3}/${1}_bqsr_log 2>&1
	fi
}
