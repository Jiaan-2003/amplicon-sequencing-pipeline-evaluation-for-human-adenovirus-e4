#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --job-name=viroconstrictor_matchref_metrics
#SBATCH --output=logs/slurm-%x-%j.out
#SBATCH --error=logs/slurm-%x-%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=your_email@example.com

# Activates conda environment
source "$HOME/.bash_profile"
conda activate viroconstrictor

# Defines directories
PROJECT_DIR=/your/project/path
RESULTS_DIR="$PROJECT_DIR/results/adeno_E4/viroconstrictor/ds1641_matchref/results/combined/by_sample"
METRICS_DIR="$PROJECT_DIR/results/adeno_E4/metrics/viroconstrictor_matchref"

# Creates/checks output directory
mkdir -p "$METRICS_DIR"

# Defines output file
OUTPUT_FILE="$METRICS_DIR/viroconstrictor_matchref_consensus_metrics.tsv"

# Creates a table header
echo -e "Barcode\tPipeline\tReference\tLength\tA\tC\tG\tT\tN\tPercentage_N" > "$OUTPUT_FILE"

# Loops through each barcode
for BARCODE_DIR in "$RESULTS_DIR"/barcode*
do

    BARCODE=$(basename "$BARCODE_DIR")
    FASTA="$BARCODE_DIR/consensus.fasta"

    # Obtains the reference selected by MatchRef from the FASTA header
    REFERENCE=$(grep "^>" "$FASTA" | awk '{print $3}')

    # Obtains the sequence length
    LENGTH=$(grep -v "^>" "$FASTA" | tr -d '\n' | wc -c)

    # Obtains base counts ("i" in grep counts lowercase and uppercase bases)
    A_COUNT=$(grep -v "^>" "$FASTA" | tr -d '\n' | grep -oi "A" | wc -l)
    C_COUNT=$(grep -v "^>" "$FASTA" | tr -d '\n' | grep -oi "C" | wc -l)
    G_COUNT=$(grep -v "^>" "$FASTA" | tr -d '\n' | grep -oi "G" | wc -l)
    T_COUNT=$(grep -v "^>" "$FASTA" | tr -d '\n' | grep -oi "T" | wc -l)
    N_COUNT=$(grep -v "^>" "$FASTA" | tr -d '\n' | grep -oi "N" | wc -l)

    # Calculates the Percentage N count
    PERCENT_N=$(awk "BEGIN {printf \"%.2f\", ($N_COUNT/$LENGTH)*100}")

    echo -e "${BARCODE}\tViroConstrictor\t${REFERENCE}\t${LENGTH}\t${A_COUNT}\t${C_COUNT}\t${G_COUNT}\t${T_COUNT}\t${N_COUNT}\t${PERCENT_N}" >> "$OUTPUT_FILE"

done

echo "ViroConstrictor MatchRef consensus metrics obtained"