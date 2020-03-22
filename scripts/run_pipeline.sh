#!/bin/bash

## Run example
## ./run_pipeline.sh ../test/test_raw.vcf.gz ../test/genelist.txt ../outdir

if [ $# -ne 6 ]
  then
    echo "Error: wrong number of arguments supplied. Usage: sh run_pipeline.sh --vcf input.vcf --genelist genelist.txt --outdir outdir"
    exit 1
fi

while getopts ":v:g:o:" opt; do
  case $opt in
    v) vcf="$OPTARG"
    ;;
    g) genelist="$OPTARG"
    ;;
    o) outdir="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

printf "Argument vcf is %s\n" "$vcf"
printf "Argument genelist is %s\n" "$genelist"
printf "Argument outdir is %s\n" "$outdir"

## starting analysis
module load anaconda/3
module load java/1.8.0_60

date=`date +%m-%d-%Y`

#vcf=$1
#genelist=$2
#outdir=$3

ref=/cluster/tufts/bio/data/genomes/HomoSapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta/genome.fa

base_out=$(basename $vcf)
out_prefix=${outdir}/${base_out%.vcf.gz}

mkdir -p ${outdir}

echo "----- Starting processing file $vcf ----"

./select_variants_vcf.sh $vcf $outdir $ref


echo "---Starting VEP annotation and conversion to TSV----"
source activate /cluster/tufts/bio/tools/conda_envs/ensembl-vep-versions/98/
./run_vep_pickgene_gencode.sh ${out_prefix}.split.vcf
source deactivate

rm ${out_prefix}.split.vcf*



echo "---- Starting parsing and filtering with Python  -----"

source activate /cluster/tufts/bio/tools/conda_envs/variant_filtering
python formatcsq.py -tsv ${out_prefix}.split.pickgene.gencode.tsv -vcf ${out_prefix}.split.pickgene.gencode.vcf
python filter.py -tsv ${out_prefix}.split.pickgene.gencode.formatcsq.tsv -genelist $genelist
source deactivate


echo "---- Split vcf to chrM and nomt -----"
./select_variants_mt.sh $vcf $outdir $ref

# move intermediate files to tmp location
mkdir -p ${outdir}/tmp
mv ${out_prefix}.split.pickgene.gencode.tsv ${outdir}/tmp
mv ${out_prefix}.split.pickgene.gencode.vcf ${outdir}/tmp 
mv ${out_prefix}.split.pickgene.gencode.vcf_summary.html ${outdir}/tmp
mv ${out_prefix}.split.pickgene.gencode.formatcsq.tsv ${outdir}/tmp

