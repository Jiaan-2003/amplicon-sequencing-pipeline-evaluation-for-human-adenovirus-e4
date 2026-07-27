#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --job-name=artic_consensus_metrics
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
METRICS_DIR="$PROJECT_DIR/results/adeno_E4/metrics/ds1641_wrapper"

# Creates/checks output directory
mkdir -p "$METRICS_DIR"

# Defines output file
OUTPUT_FILE="$METRICS_DIR/ds1641_consensus_metrics.tsv"

# Creates a table header
echo -e "Barcode\tReference\tLength\tA\tC\tG\tT\tN\tPercentage_N\tMean_Amplicon_Depth\tPASS_Variants" > "$OUTPUT_FILE"

# Loops through each barcode
for BARCODE_DIR in "$RESULTS_DIR"/barcode*
do

    BARCODE=$(basename "$BARCODE_DIR")

    for REF in MN307142 KX384945
    do

        FASTA="$BARCODE_DIR/$REF"/*.consensus.fasta
        DEPTH_FILE="$BARCODE_DIR/$REF"/*.amplicon_depths.tsv
        VCF_FILE="$BARCODE_DIR/$REF"/*.pass.vcf

        # Obtains the sequence length
        LENGTH=$(grep -v "^>" $FASTA | tr -d '\n' | wc -c)

        # Obtains base counts ("i" in grep counts lowercase and uppercase bases)
        A_COUNT=$(grep -v "^>" $FASTA | tr -d '\n' | grep -oi "A" | wc -l)
        C_COUNT=$(grep -v "^>" $FASTA | tr -d '\n' | grep -oi "C" | wc -l)
        G_COUNT=$(grep -v "^>" $FASTA | tr -d '\n' | grep -oi "G" | wc -l)
        T_COUNT=$(grep -v "^>" $FASTA | tr -d '\n' | grep -oi "T" | wc -l)
        N_COUNT=$(grep -v "^>" $FASTA | tr -d '\n' | grep -oi "N" | wc -l)

        # Calculates the Percentage N count
        PERCENT_N=$(awk "BEGIN {printf \"%.2f\", ($N_COUNT/$LENGTH)*100}")

        # Obtains the mean depth coverage
        MEAN_DEPTH=$(awk 'NR>1 {sum+=$3; n++} END {print sum/n}' $DEPTH_FILE)

        # Obtains pass variant values
        PASS_VARIANTS=$(grep -vc "^#" $VCF_FILE)

        echo -e "${BARCODE}\t${REF}\t${LENGTH}\t${A_COUNT}\t${C_COUNT}\t${G_COUNT}\t${T_COUNT}\t${N_COUNT}\t${PERCENT_N}\t${MEAN_DEPTH}\t${PASS_VARIANTS}" >> "$OUTPUT_FILE"

    done

done

echo "Barcode metrics obtained"