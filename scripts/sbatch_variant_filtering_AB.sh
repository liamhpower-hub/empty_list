#!/bin/bash
#SBATCH --job-name=job
#SBATCH --nodes=1     
#SBATCH --cpus=4
#SBATCH --partition preempt
#SBATCH --mem=100Gb
#SBATCH --time=0-24:00:00
#SBATCH --output=%j.out
#SBATCH --error=%j.err

sh run_pipeline.sh \
-v ../test/test_raw.vcf.gz \
-g ../test/genelist.txt \
-o out

