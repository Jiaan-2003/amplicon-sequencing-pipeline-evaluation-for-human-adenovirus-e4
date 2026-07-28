#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --job-name=combine_ds1641_fastqs
#SBATCH --output=logs/slurm-%x-%j.out
#SBATCH --error=logs/slurm-%x-%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=your_email@example.com

# Defines directories
PROJECT_DIR=/your/project/path
INPUT_DIR="$PROJECT_DIR/reads/ds1641"
OUTPUT_DIR="$PROJECT_DIR/results/adeno_E4/viroconstrictor/raw_combined_fastqs"

# Creates/checks output directory
mkdir -p "$OUTPUT_DIR"

# Combines the original pass FASTQ data into one compressed FASTQ per each barcode
for BARCODE_DIR in "$INPUT_DIR"/barcode*/
do
    BARCODE=$(basename "$BARCODE_DIR")

    echo "Combining $BARCODE"

    zcat "$BARCODE_DIR"/*.fastq.gz \
    | gzip \
    > "$OUTPUT_DIR/${BARCODE}.fastq.gz"
done

echo "Finished combining FASTQ files"