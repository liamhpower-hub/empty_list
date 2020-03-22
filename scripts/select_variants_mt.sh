#!/bin/bash

## This script takes as argument the name of a vcf file with extension vcf.gz
## The result is an index file and another vcf where all multi-allelic sites are split

input_vcf=$1
output_dir=$2
ref=$3

output_base=$( basename $input_vcf )
output_1=${output_base%vcf}nomt.vcf
output_2=${output_base%vcf}mt.vcf

## generate vcf index with tabix

echo "----Starting split VCF -----"

/cluster/tufts/bio/tools/bcbio/1.1.5/bin/tabix -p vcf $input_vcf

/cluster/tufts/bio/tools/GATK/gatk-4.1.2.0/gatk SelectVariants \
 -R $ref \
 -V $input_vcf \
 -O ${output_dir}/${output_1} \
 -XL chrM

/cluster/tufts/bio/tools/GATK/gatk-4.1.2.0/gatk SelectVariants \
 -R $ref \
 -V $input_vcf \
 -O ${output_dir}/${output_2} \
 -L chrM

