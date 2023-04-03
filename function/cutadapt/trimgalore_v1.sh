#!/bin/bash
# this script is for trimgalore the raw file
# author: laojp
# time: 2023.03.31
# position: SYSUCC bioinformatic platform
# version: 1.0
# ps: the script is a function and need to source by main script
# usage: trimgalore_pair_process sample input_dir output_dir

# update: will consider single and paired end
# update: will consider in nextflow
# update: will consider different software version

function trimgalore_pair_process {
	local trimgalore=[your trimgalore file]	

	if [ -f ${3}/${1}_1.fq.gz -a -f ${3}/${1}_2.fq.gz ] 
	then
		echo " "
	else
		${trimgalore}/trim_galore \
			--paired \
			-q 28 --phred33 --length 30 --stringency 3 --gzip --cores 6 \
			-o ${3}/ \
			${2}/${1}_1.fq.gz \
			${2}/${1}_2.fq.gz \
			1>${3}/${1}_log 2>&1
		mv ${3}/${1}_1_val_1.fq.gz ${3}/${1}_1.fq.gz
		mv ${3}/${1}_2_val_2.fq.gz ${3}/${1}_2.fq.gz
	fi			 
}
