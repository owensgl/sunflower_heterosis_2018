#!/bin/bash
#SBATCH --account=ACCOUNT
#SBATCH --time=24:00:00
#SBATCH --job-name=genecounter
#SBATCH --array=14,159%200
#SBATCH --mem=10G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=logs/%A.%a.genecount_log

module load samtools
gff3=/home/gowens/bin/ref/HanXRQr1.0-20151230-EGN-r1.1.gff3
input=/scratch/gowens/heterosis/heterosis_list.txt
sample=$(cat $input | sed -n ${SLURM_ARRAY_TASK_ID}p)
[[ -z "$sample" ]] && { echo "No sample to try" ; exit 1; }


cat /scratch/gowens/heterosis/heterosis_infofile.txt | grep $sample > /scratch/gowens/wild_gwas/heterosis/tmp.$sample.list.txt

perl /scratch/gowens/heterosis/bam2countreadspergene.pl $gff3 /scratch/gowens/wild_gwas/heterosis/tmp.$sample.list.txt > /scratch/gowens/wild_gwas/heterosis/genecount.$sample.txt
rm /scratch/gowens/heterosis/tmp.$sample.list.txt

echo "Run on node $SLURMD_NODENAME"
