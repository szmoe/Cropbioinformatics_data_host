#!/bin/bash -l
#SBATCH --job-name=align_Brassica
#SBATCH --partition=long
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH -o alignment_log/align_Brassica-%A-%a.out
#SBATCH -e alignment_log/align_Brassica-%A-%a.err
#SBATCH --array=0-250%32

source $HOME/.bashrc
eval "$(conda shell.bash hook)"
conda activate EX_Brassica

# Define paths
reads_1=(/data/applbio/applbio_2026/home/s73smoe/swe/input/seqread_data/fastq/*_1.fastq.gz)
reads_2=(/data/applbio/applbio_2026/home/s73smoe/swe/input/seqread_data/fastq/*_2.fastq.gz)


sample=$(basename "${reads_1[$SLURM_ARRAY_TASK_ID]}" _1.fastq.gz)

index_path=/data/applbio/applbio_2026/home/s73smoe/swe/input/genomic_data/Brassica_index/Bn_index
exp_path=/data/applbio/applbio_2026/home/s73smoe/swe/experiment/Ex_B_experiment/aligned_reads

mkdir -p $exp_path
mkdir -p alignment_log  


hisat2 -p 8 \
-x $index_path \
-1 "${reads_1[$SLURM_ARRAY_TASK_ID]}" \
-2 "${reads_2[$SLURM_ARRAY_TASK_ID]}" | \
samtools view -bS - | \
samtools sort -o $exp_path/${sample}_sorted.bam 


samtools index $exp_path/${sample}_sorted.bam

