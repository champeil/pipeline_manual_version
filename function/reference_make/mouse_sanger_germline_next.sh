#!/bin/bash
# this script is for handle the sanger_mouse vcf file which outputed from mouse_sanger_germline.pl
# author: laojp
# time: 2023.04.07
# position: SYSUCC bioinformatic platform
# usage: bash mouse_sanger_germline_next.sh [input vcf file] 

# update: will update together with mouse_sanger_germline.pl

#sort --- generate index
filedir=$(dirname $(readlink -f ${1}))
name=$(basename ${1} .vcf)
gzip ${1}

/home/laojp/software/gatk_4.2.6.1/gatk-4.2.6.1/gatk SortVcf \
	-I ${1}.gz \
	-O ${filedir}/${name}_sort.vcf.gz
