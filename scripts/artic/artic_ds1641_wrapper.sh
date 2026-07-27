#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --job-name=artic_ds1641_wrapper
#SBATCH --output=logs/slurm-%x-%j.out
#SBATCH --error=logs/slurm-%x-%j.err
#SBATCH --mail-type=END,FAIL
# #SBATCH --mail-user=your_email@example.com

# Activates conda environment
source "$HOME/.bash_profile"
conda activate artic

# Set this to the local path of the cloned project repository
PROJECT_DIR=/your/project/path

# Defines main directory paths
RAW_READS_DIR="$PROJECT_DIR/reads/ds1641"
REFERENCES_DIR="$PROJECT_DIR/references"
BEDFILES_DIR="$PROJECT_DIR/bed_files"
RESULTS_DIR="$PROJECT_DIR/results/adeno_E4/ds1641_wrapper"

# Defines pipeline settings
MIN_READLEN=2000
MAX_READLEN=3000
NORMALISE=200
THREADS=8

# Defines references and their corresponding bed files
REF_NAMES=("MN307142" "KX384945")
REF_FILES=("$REFERENCES_DIR/HAdV_E4_MN307142.fas" "$REFERENCES_DIR/HAdV_E4_KX384945.fas")
BED_FILES=("$BEDFILES_DIR/MN307142.scheme.SA.update.bed" "$BEDFILES_DIR/KX384945.scheme.SA.update.bed")

# Creates/checks main output directory
mkdir -p "$RESULTS_DIR"

# A loop to run through every barcode
for READS_DIR in "$RAW_READS_DIR"/barcode*/
do

    # Retrieves barcode names
    BARCODE=$(basename "$READS_DIR")

    echo "Processing $BARCODE"

    # Defines barcode output folder
    BARCODE_OUTPUT="$RESULTS_DIR/$BARCODE"

    # Creates/checks the barcode output directory
    mkdir -p "$BARCODE_OUTPUT"

    # Creates filtered FASTQ only once
    FILTERED_FASTQ="$BARCODE_OUTPUT/${BARCODE}_filtered.fastq"

    # Step 1: length filter the pass reads with ARTIC guppyplex
    artic guppyplex \
      --directory "$READS_DIR" \
      --skip-quality-check \
      --min-length "$MIN_READLEN" \
      --max-length "$MAX_READLEN" \
      --output "$FILTERED_FASTQ"

    # Step 2: run ARTIC minion for each reference and corresponding BED file
    for i in "${!REF_NAMES[@]}"
    do

        REF_NAME="${REF_NAMES[$i]}"
        REFERENCE="${REF_FILES[$i]}"
        BED="${BED_FILES[$i]}"

        OUTPUT_DIR="$BARCODE_OUTPUT/$REF_NAME"

        # Creates/checks the reference output directory
        mkdir -p "$OUTPUT_DIR"

        echo "Running $BARCODE with $REF_NAME"

        artic minion \
          --normalise "$NORMALISE" \
          --threads "$THREADS" \
          --bed "$BED" \
          --ref "$REFERENCE" \
          --read-file "$FILTERED_FASTQ" \
          "$OUTPUT_DIR/${BARCODE}_${REF_NAME}"

    done

done

echo "ARTIC wrapper script finished"