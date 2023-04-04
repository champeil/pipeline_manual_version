#!/bin/bash
# this script is for mapping to the raw file by bwa
# author: laojp
# time: 2023.03.31
# position: SYSUCC bioinformatic platform
# version: 1.1
# new: with consideration of mouse genome (ensembl grcm_38)
# ps: the script is a function and need to source by main script
# usage: bwa_pair_process sample input_dir output_dir species

# update: will consider single and paired end
# update: will consider in nextflow
# update: will consider different software version
# update: will consider different reference

function bwa_pair_process {
	local bwa=/home/laojp/software/bwa/bin
	local samtools=/home/laojp/software/samtools_1.9/bin
	case ${4} in
		"human")
			local reference_bwa=/home/laojp/reference/human/GATK/hg38/gatk_hg38
		;;
		"mouse")
			local reference_bwa=/home/laojp/reference/mouse/ensembl_GRCm38/gatk_grcm38
	esac
	if [ ! -f ${3}/${1}.bam ]; then
		${bwa}/bwa mem -M -t 16 \
			-R "@RG\tID:${1}\tSM:${1}\tLB:WXS\tPL:Illumina" \
			${reference_bwa} \
			${2}/${1}_1.fq.gz \
			${2}/${1}_2.fq.gz | ${samtools}/samtools sort -@ 10 -m 1G -o ${3}/${1}.bam -
	fi		
}
