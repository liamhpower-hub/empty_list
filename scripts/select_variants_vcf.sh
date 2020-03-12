#!/bin/bash
#SBATCH --job-name=select_variants
#SBATCH --nodes=1     
#SBATCH --cpus=2
#SBATCH --mem=64Gb
#SBATCH --time=0-24:00:00
#SBATCH --output=select_variants_%j.out
#SBATCH --error=select_variants%j.err

module load java/1.8.0_60

## This script takes as argument the name of a vcf file with extension vcf.gz
## The result is an index file and another vcf where all multi-allelic sites are split

input_vcf=$1
output_dir=$2

output_base=$( basename $input_vcf )
output_vcf=${output_base%vcf.gz}split.vcf

ref=/cluster/tufts/bio/data/genomes/HomoSapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta/genome.fa

## generate vcf index with tabix

echo "----Starting split VCF -----"

/cluster/tufts/bio/tools/bcbio/1.1.5/bin/tabix -p vcf $input_vcf

/cluster/tufts/bio/tools/GATK/gatk-4.1.2.0/gatk LeftAlignAndTrimVariants \
 -R $ref \
 -V $input_vcf \
 -O ${output_dir}/${output_vcf} \
 --max-indel-length 535 \
 --split-multi-allelics

