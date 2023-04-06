#!/bin/bash
# this script is for qc of bwa results
# author: laojp
# time: 2023.03.31
# position: SYSUCC bioinformatic platform
# version: 1.0
# ps: the script is a function and need to source by main script
# usage: fastqc_multiqc input_dir output_dir

# update: will consider single and paired end
# update: will consider in nextflow

function fastqc_multiqc {
	local fastqc=fastqc=/home/laojp/software/fastqc/FastQC
	local multiqc=/home/laojp/software/multiqc/bin

	${fastqc}/fastqc -o ${2} --threads 10 ${1}/*.fq.gz
	${multiqc}/multiqc -o ${2} ${2}*.zip
}
