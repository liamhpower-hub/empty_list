# variant_filtering
This directory contains scripts to process and annotate variant call files

There are two sub directories:
1) scripts - contains all code

2) test - contains test data

To run the test data on the Tufts HPC:

1. `git clone https://github.com/rbatorsky/variant_filtering.git`
2. `cd variant_filtering/scripts`
3. `To submit to slurm in batch mode: sbatch sbatch_variant_filtering_test.sh`
4. To run in interactive mode, first get an interactive session, e.g.: `srun --pty --mem=100Gb --cpus=4 bash`.
Then run `sh sbatch_variant_filtering_test.sh`

In order to run this on a new vcf, edit the file sbatch_variant_filtering_test.sh to replace the line:
`-v ../test/test_raw.vcf.gz \`

With the path to the new vcf.

To change the genelist, specify the full path to the genelist in this line:
`-g ../test/genelist.txt \`

The output directory can be specified in the last line:
`-o out`



