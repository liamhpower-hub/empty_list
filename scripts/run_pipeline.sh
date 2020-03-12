#!/bin/bash

## Run example
## ./run_pipeline.sh ../test/test_raw.vcf.gz ../test/genelist.txt ../outdir

if [ $# -ne 3 ]
  then
    echo "Error: wrong number of arguments supplied. Usage: sh run_pipeline.sh input.vcf genelist.txt outdir"
    exit 1
fi

date=`date +%m-%d-%Y`

vcf=$1
genelist=$2
outdir=$3

base_out=$(basename $vcf)
out_prefix=${outdir}/${base_out%.vcf.gz}

mkdir -p ${outdir}

./select_variants_vcf.sh $vcf $outdir
./run_vep_pickgene_gencode.sh ${out_prefix}.split.vcf
rm ${out_prefix}.split.vcf*

module load anaconda/3
source activate /cluster/tufts/bio/tools/conda_envs/variant_filtering
python formatcsq.py -tsv ${out_prefix}.split.pickgene.gencode.tsv -vcf ${out_prefix}.split.pickgene.gencode.vcf
python filter.py -tsv ${out_prefix}.split.pickgene.gencode.formatcsq.tsv -genelist $genelist
source deactivate

mkdir ${outdir}/tmp
mv ${out_prefix}.split.pickgene.gencode.tsv ${outdir}/tmp
mv ${out_prefix}.split.pickgene.gencode.vcf ${outdir}/tmp 
mv ${out_prefix}.split.pickgene.gencode.vcf_summary.html ${outdir}/tmp
mv ${out_prefix}.split.pickgene.gencode.formatcsq.tsv ${outdir}/tmp

