#!/bin/bash

#module load anaconda/3
#source activate /cluster/tufts/bio/tools/conda_envs/ensembl-vep-versions/98/

if [ $# -eq 0 ]
  then
    echo "Error: no argument supplied. Usage: sh variants_to_table.sh input.vcf ref"
    exit 1
fi

input_vcf=$1
REF=$2
output_tsv=${input_vcf%vcf}tsv

## Convert to TSV using GATK
/cluster/tufts/bio/tools/GATK/gatk-4.1.2.0/gatk VariantsToTable \
-R $REF \
-V $input_vcf \
--show-filtered \
-F CHROM -F POS -F ID -F REF -F ALT -F TYPE -F QUAL -F FILTER -F AC -F AF -F AN -F DP -F CSQ -GF AD -GF DP -GF GQ -GF GT \
-O $output_tsv 

echo "Done."
