#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --job-name=viroconstrictor_ds1641_matchref
#SBATCH --output=logs/slurm-%x-%j.out
#SBATCH --error=logs/slurm-%x-%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=your_email@example.com

# Loads Git required for creating ViroConstrictor environments
module load git-uoneasy/2.42.0-GCCcore-13.2.0

# Activates conda environment
source "$HOME/.bash_profile"
conda activate viroconstrictor

# Defines directories
PROJECT_DIR=/your/project/path
INPUT_DIR="$PROJECT_DIR/results/adeno_E4/viroconstrictor/raw_combined_fastqs"
OUTPUT_DIR="$PROJECT_DIR/results/adeno_E4/viroconstrictor/ds1641_matchref"
REFERENCE="$PROJECT_DIR/references/HAdV_E4_combined_refs.fasta"
PRIMERS="$PROJECT_DIR/bed_files/HAdV_E4_combined_refs.scheme.SA.update.bed"

# Creates/checks output directory
mkdir -p "$OUTPUT_DIR"

# Runs ViroConstrictor
# Uses a combined FASTA reference file and combined reference BED scheme
# No GFF3 features are required, platform is set to nanopore to match the sequencing data, and amplicon type is end-to-end
# Minimum coverage is set to 30, target is set to adenovirus, and analysis presets are disabled
# MatchRef is enabled for all samples, scheduler is set to none to avoid interrupting HPC job scheduling, and update checks are skipped

viroconstrictor \
  --input "$INPUT_DIR" \
  --output "$OUTPUT_DIR" \
  --reference "$REFERENCE" \
  --primers "$PRIMERS" \
  --features NONE \
  --platform nanopore \
  --amplicon-type end-to-end \
  --min-coverage 30 \
  --target Adenovirus_E4 \
  --disable-presets \
  --match-ref \
  --scheduler none \
  --threads 8 \
  --skip-updates

echo "ViroConstrictor analysis finished"