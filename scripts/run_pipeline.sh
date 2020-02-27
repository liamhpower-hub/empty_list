#!/bin/bash


module load anaconda/3
date=`date +%m-%d-%Y`

vcf=$1
genelist=$2

./select_variants_vcf.sh $vcf
./run_vep_pickgene_gencode.sh ${vcf%.vcf.gz}.split.vcf $date

source activate /cluster/tufts/bio/tools/conda_envs/biopython

python formatcsq.py -tsv ${vcf%.vcf.gz}.split.${date}.pickgene.gencode.tsv -vcf ${vcf%.vcf.gz}.split.${date}.pickgene.gencode.vcf
python filter.py -tsv ${vcf%.vcf.gz}.split.${date}.pickgene.gencode.formatcsq.tsv -genelist $genelist

