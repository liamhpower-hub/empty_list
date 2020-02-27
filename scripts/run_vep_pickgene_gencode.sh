#!/bin/bash

module load anaconda/3
source activate /cluster/tufts/bio/tools/conda_envs/ensembl-vep-versions/98/

if [ $# -eq 0 ]
  then
    echo "Error: no argument supplied. Usage: sh run_vep_pickgene_genecode.sh input.vcf datestring"
    exit 1
fi

input_vcf=$1
date=$2
annotated_vcf=${input_vcf%vcf}${date}.pickgene.gencode.vcf
intermediate_tsv=${annotated_vcf%vcf}tsv

cache_dir=/cluster/tufts/bio/tools/conda_envs/ensembl-vep-versions/cache/
REF=/cluster/tufts/bio/data/genomes/HomoSapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta/genome.fa
species=homo_sapiens
cadd_files=/cluster/tufts/bio/tools/conda_envs/ensembl-vep-versions/cache/CADD/grch38/whole_genome_SNVs.tsv.gz,/cluster/tufts/bio/tools/conda_envs/ensembl-vep-versions/cache/CADD/grch38/InDels.tsv.gz
clinvar=/cluster/tufts/bio/data/clinvar/15oct19/clinvar.vcf.gz

## Annotate vcf, output vcf, filter common variants
echo "---Starting VEP annotation----"
vep -i $input_vcf \
--force_overwrite \
--fork 4 \
--vcf \
--per_gene \
--no_intergenic \
--canonical \
--cache \
--fasta $REF \
--max_af \
--af_1kg \
--af_esp \
--af_gnomad \
--sift b \
--polyphen b \
--plugin CADD,$cadd_files \
--offline \
--dir_cache $cache_dir \
--species $species \
--custom $clinvar,ClinVar,vcf,exact,0,CLNHGVS,GENEINFO,CLNSIG,CLNREVSTAT,CLNDN, \
-o $annotated_vcf

source deactivate

## Convert to TSV using GATK
module load java/1.8.0_60
echo "----Starting conversion to TSV-----"
/cluster/tufts/bio/tools/GATK/gatk-4.1.2.0/gatk VariantsToTable \
-R $REF \
-V $annotated_vcf \
--show-filtered \
-F CHROM -F POS -F ID -F REF -F ALT -F TYPE -F QUAL -F FILTER -F AC -F AF -F AN -F DP -F CSQ -GF AD -GF DP -GF GQ -GF GT \
-O $intermediate_tsv 

### move files
#final_dir=/cluster/tufts/chinlab/rbator01/wes_vcf/vcf/annotated_vcf/
#mv $annotated_vcf $final_dir
#mv $intermediate_tsv $final_dir

echo "Done."
