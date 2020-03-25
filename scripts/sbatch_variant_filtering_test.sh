#!/bin/bash
#SBATCH --job-name=job
#SBATCH --nodes=1     
#SBATCH --cpus=4
#SBATCH --partition preempt
#SBATCH --mem=100Gb
#SBATCH --time=0-24:00:00
#SBATCH --output=%j.out
#SBATCH --error=%j.err

HOME=/cluster/home/tutln01/

sh $HOME/variant_filtering/scripts/run_pipeline.sh \
-v $HOME/variant_filtering/test/test_raw.vcf.gz \
-g $HOME/variant_filtering/test/genelist.txt \
-o out

