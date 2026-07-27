#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --job-name=ds1641_MN307142_MAFFT_wrapper
#SBATCH --output=logs/slurm-%x-%j.out
#SBATCH --error=logs/slurm-%x-%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=your_email@example.com

# Activates conda environment
source "$HOME/.bash_profile"
conda activate artic

# Defines directories
PROJECT_DIR=/your/project/path
RESULTS_DIR="$PROJECT_DIR/results/adeno_E4/ds1641_wrapper"
COMBINED_DIR="$PROJECT_DIR/results/adeno_E4/MN307142_combined_fastas_wrapper"
MAFFT_RESULTS="$PROJECT_DIR/results/adeno_E4/ds1641_wrapper/MN307142_MAFFT"
COMBINED_FASTA="$COMBINED_DIR/ds1641_MN307142_consensus_wrapper.fasta"

# Creates/checks output directory
mkdir -p "$COMBINED_DIR"
mkdir -p "$MAFFT_RESULTS"

# Creates/clears combined fasta
> "$COMBINED_FASTA"

# Loops through each barcode
for BARCODE_DIR in "$RESULTS_DIR"/barcode*
do

    BARCODE=$(basename "$BARCODE_DIR")

    # Replaces long ARTIC headers with barcode names for easier identification in analysis
    echo ">$BARCODE" >> "$COMBINED_FASTA"

    grep -v "^>" \
    "$BARCODE_DIR"/MN307142/*.consensus.fasta \
    >> "$COMBINED_FASTA"

done

# Runs MAFFT on the combined fasta files
mafft --auto \
"$COMBINED_FASTA" \
> "$MAFFT_RESULTS/ds1641_MN307142_mafft_wrapper.fasta"

echo "Finished MAFFT alignment"