#!/bin/bash -l
#SBATCH --job-name=count_features_Brassica
#SBATCH --partition=long
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH -o count_log/count_features_Brassica-%j.out
#SBATCH -e count_log/count_features_Brassica-%j.err

source $HOME/.bashrc
eval "$(conda shell.bash hook)"
conda activate EX_Brassica

inp_path=/data/applbio/applbio_2026/home/s73smoe/swe/experiment/Ex_B_experiment/aligned_reads
exp_path=/data/applbio/applbio_2026/home/s73smoe/swe/experiment/Ex_B_experiment/count_features
gtf_file=/data/applbio/applbio_2026/home/s73smoe/swe/input/genomic_data/Brassica_napus.AST_PRJEB5043_v1.62.gtf

mkdir -p $exp_path
mkdir -p count_log
mkdir -p "$inp_path/namesorted_bam"

echo "Sorting BAM files by read name..."

for bam in "$inp_path"/*_sorted.bam
do
    base=$(basename "$bam" .bam)
    outbam="$inp_path/namesorted_bam/${base}_namesorted.bam"

    # skip if already done
    if [ -f "$outbam" ]; then
        echo "Skipping $base (already sorted)"
        continue
    fi

    tmpdir="$inp_path/tmp_${base}"
    mkdir -p "$tmpdir"

    echo "Sorting $base..."
    samtools sort -n -@ 8 -T "$tmpdir" -o "$outbam" "$bam"

    rm -rf "$tmpdir"
done

echo "Running featureCounts..."

featureCounts -T 8 -p -B -t CDS -g gene_id \
-a "$gtf_file" \
-o "$exp_path/Brassica_counts.txt" \
$inp_path/namesorted_bam/*_namesorted.bam

echo "Done."
