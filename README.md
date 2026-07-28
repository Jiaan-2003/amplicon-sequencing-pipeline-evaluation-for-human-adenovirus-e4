# Evaluating and Optimising Amplicon Sequencing Pipelines for Genetically Diverse Viral Cohorts

This repository contains the computational workflow used to evaluate the effect of reference genome selection on Oxford Nanopore Technology (ONT) tiled-amplicon sequencing analysis of Human adenovirus species E (HAdV-E4).

The analysis in this study primarily used the ARTIC fieldbioinformatics pipeline to process samples against two HAdV-E4 reference genomes, MN307142 and KX384945. The analysis was then expanded to use the ViroConstrictor pipeline to assess the same sequenced samples against the two reference genomes with an alternative workflow, allowing similarities and differences between pipeline outputs to be evaluated.

This repository contains the scripts, reference genomes, primer schemes, software environments, output examples and relevant downstream analysis code used in the project. Raw sequencing reads are not available in this repository due to confidentiality.

## Clone the Repository

```bash
git clone https://github.com/Jiaan-2003/amplicon-sequencing-pipeline-evaluation-for-human-adenovirus-e4.git
```
## Data Overview


The data in this project were pass ONT FASTQ reads derived from sequencing run ds1641. The following ten HAdV-E4 barcode samples were analysed:

barcode62, barcode65, barcode66, barcode67, barcode68, barcode69, barcode70, barcode71, barcode72 and barcode77.

Reads were generated at DeepSeq, University of Nottingham.

While the raw sequencing data are not available within this repository, the workflow expects the reads to be structured correctly to ensure script functionality. The following example shows how reads should be placed within the file paths:

```bash
reads/
└── ds1641/
    ├── barcode62/
    │   └── *.fastq.gz
    ├── barcode65/
    │   └── *.fastq.gz
    ├── barcode66/
    │   └── *.fastq.gz
    ├── barcode67/
    │   └── *.fastq.gz
    ├── barcode68/
    │   └── *.fastq.gz
    ├── barcode69/
    │   └── *.fastq.gz
    ├── barcode70/
    │   └── *.fastq.gz
    ├── barcode71/
    │   └── *.fastq.gz
    ├── barcode72/
    │   └── *.fastq.gz
    └── barcode77/
        └── *.fastq.gz
```

## Software and Tools

The computational use of the ARTIC and ViroConstrictor pipelines whas conducted via a series of custom Bash scripts on the University of Nottingham high-performance computer (HPC), which used a Slurm system for job submission. Additional analysis included the use of Inkscape for figure formatting, NCBI BLASTn to search sequences and RStudio to utilise packages for figure generation.
The following tables list the tools and packages with their versions at the time of use.

| Tool | Version |
|------|--------|
| [ARTIC fieldbioinformatics](https://github.com/artic-network/fieldbioinformatics) | 1.10.1 |
| [ViroConstrictor](https://github.com/RIVM-bioinformatics/ViroConstrictor) | 1.6.6 |
| [MAFFT](https://mafft.cbrc.jp/alignment/software/) | 7.526 |
| [R](https://www.r-project.org/) | 4.5.1 |
| [RStudio](https://posit.co/products/open-source/rstudio/) | 2025.05.1+513 |
| [Inkscape](https://inkscape.org/) | [1.4.4] |
| [NCBI BLASTn](https://blast.ncbi.nlm.nih.gov/Blast.cgi) | Web version |

### R Packages

| Package | Version |
|--------|--------|
| [readr](https://readr.tidyverse.org/) | 2.2.0 |
| [dplyr](https://dplyr.tidyverse.org/) | 1.1.4 |
| [ggplot2](https://ggplot2.tidyverse.org/) | 4.0.2 |
| [RColorBrewer](https://cran.r-project.org/package=RColorBrewer) | 1.1-3 |
| [tidyr](https://tidyr.tidyverse.org/) | 1.3.2 |
| [gggenes](https://cran.r-project.org/package=gggenes) | 0.7.0 |
| [svglite](https://svglite.r-lib.org/) | 2.2.2 |

### Conda Environments

Two separate Conda environment files for both workflows are provided in this repository:

environments/artic_environment.yml
environments/viroconstrictor_environment.yml

These environments can be reproduced with the following commands:

```{r}

conda env create -f environments/artic_environment.yml
conda env create -f environments/viroconstrictor_environment.yml

```

## Placeholder paths

The Bash scripts in this workflow have placeholder paths implemented (/your/project/path), so users should ensure they replace these with the corresponding path of their own repository.

## Reference Genomes and Primer Schemes

Two HAdV-E4 references genomes were used throughout the study to assess reference selection as a FASTA file and corresponding primer schemes:

| Reference | FASTA File | Primer Scheme |
|-----------|------------|---------------|
| MN307142 | `references/HAdV_E4_MN307142.fas` | `bed_files/MN307142.scheme.SA.update.bed` |
| KX384945 | `references/HAdV_E4_KX384945.fas` | `bed_files/KX384945.scheme.SA.update.bed` |

While these were sufficient for the ARTIC analysis, ViroConstrictor required the reference FASTA files and primer schemes to be combined:

|------|----------|
| Combined reference FASTA | `references/HAdV_E4_combined_refs.fasta` |
| Combined primer scheme | `bed_files/HAdV_E4_combined_refs.scheme.SA.update.bed` |

For the KX384945 only ViroConstrictor run in the workflow, an uppercase and ungapped version of the KX384945 reference genome was required.

| File | Location |
|------|----------|
| KX384945 uppercase and ungapped reference | `references/HAdV_E4_KX384945_uppercase_and_ungapped.fasta` |

## Workflow

The following describes each stage of the workflow in this analysis and details the scripts, input files, and output files.

## ARTIC Workflow

### 1.1 ARTIC Consensus Generation

**Script:** scripts/artic/artic_ds1641_wrapper.sh

This ARTIC wrapper script processes each barcode in the analysis against both the MN307142 and KX384945 reference genomes. This uses artic guppyplex to filter reads to an optimised length range of 2,000-3,000 bp. Then, artic minion runs each barcode against the references and their corresponding bed file.
Other parameters include a normalisation set to 200 and the use of eight threads.

**Input:** reads/ds1641/barcode*/
references/HAdV_E4_MN307142.fas
references/HAdV_E4_KX384945.fas
bed_files/MN307142.scheme.SA.update.bed
bed_files/KX384945.scheme.SA.update.bed

**Output:** results/adeno_E4/ds1641_wrapper/
└── barcodeXX/
    ├── MN307142/
    └── KX384945/

ARTIC produces a range of outputs that can be found in output path above for each barcode in two separate reference results directories.

### 1.2 ARTIC Consensus Metrics

**Script:** scripts/artic/artic_consensus_metrics.sh

This script extracts and calculates consensus quality metrics that were generated from the ARITC analysis into a tsv file.
The results contain the consensus sequence length, A, C, G and T base counts, ambiguous base count, ambiguous base percentage (N%), mean amplicon depth and they number of PASS variants per barcode against both references.

**Input:** results/
└── adeno_E4/
    └── ds1641_wrapper/
        └── barcodeXX/
            ├── MN307142/
            │   ├── *.consensus.fasta
            │   ├── *.amplicon_depths.tsv
            │   └── *.pass.vcf
            └── KX384945/
                ├── *.consensus.fasta
                ├── *.amplicon_depths.tsv
                └── *.pass.vcf

**Output:** ds1641_consensus_metrics.tsv

## Multiple Sequence Alignment

Following ARTIC consensus sequence generation, a multiple sequence alignment which aligned both sequences separately was performed with MAFFT v.7.256.

### 2.1 MN307142 Alignment

**Script:** scripts/alignment/ds1641_MN307142_mafft_wrapper.sh

Prior to MAFFT analysis in this script, the consensus sequences generated against MN307142 and combined into a single FASTA file with header manipulation to correct format.

**Input:** results/adeno_E4/ds1641_wrapper/barcode*/MN307142/*.consensus.fasta

**Output:** results/
└── adeno_E4/
    └── MN307142_combined_fastas/
        └── ds1641_MN307142_consensus.fasta

results/
└── adeno_E4/
    └── ds1641_wrapper/
        └── MN307142_MAFFT/
            └── ds1641_MN307142_mafft_wrapper.fasta

### 2.2 KX384945 Alignment

**Script:** scripts/alignment/ds1641_KX384945_mafft_wrapper.sh

Another MAFFT script with the same function was executed for KX384945

**Input**: results/adeno_E4/ds1641_wrapper/barcode*/KX384945/*.consensus.fasta

**Output**: results/
└── adeno_E4/
    └── KX384945_combined_fastas/
        └── ds1641_KX384945_consensus.fasta

results/
└── adeno_E4/
    └── ds1641_wrapper/
        └── KX384945_MAFFT/
            └── ds1641_KX384945_mafft_wrapper.fasta

## 3. ViroConstrictor Workflow

Following ARTIC analysis, ViroConstrictor was configured and optimised to act as an alternative amplicon sequencing pipeline for the same samples and reference genomes in this study.

Two ViroConstrictor analysis scripts were produced, the first was a MatchRef script that included both reference genomes and matched samples to the more suited reference.
The second script only used KX384945, the poorer reference match, to produce results that could be compared to ARTIC performance with the poorer reference.

### 3.1 FASTQ Preparation

**Script:** scripts/viroconstrictor/combine_ds1641_fastqs.sh

The ViroConstrictor pipeline required a single FASTQ file containing each sample, which this script fulfills by combining the individual pass FASTQ files into one .fast.gz file.

**Input:** reads/ds1641/barcode*/*.fastq.gz

**Output:** results/adeno_E4/viroconstrictor/raw_combined_fastqs/
├── barcode62.fastq.gz
├── barcode65.fastq.gz
└── ...

### 3.2 ViroConstrictor MatchRef Analysis

**scripts/viroconstrictor/viroconstrictor_ds1641_matchref.sh** 

The ViroConstrictor MatchRef script runs all barcodes against both references and corresponding bed schemes in combined files, while producing a consensus sequence per barcode against the more suited reference.

Key parameters and configuration options in this analysis script include:

- Nanopore sequencing mode
- end-to-end amplicons
- MatchRef selection enabled
- Minimum coverage of 30
- Analysis presets disabled
- eight threads


**Inputs:** results/adeno_E4/viroconstrictor/raw_combined_fastqs/
references/HAdV_E4_combined_refs.fasta
bed_files/HAdV_E4_combined_refs.scheme.SA.update.bed

**Outputs:** results/adeno_E4/viroconstrictor/ds1641_matchref/

Key outputs of ViroConstrictor include an amplicon coverage csv file, a consensus fasta file, a mutations file and a width of coverage file.
ViroConstrictor produces these in two separate directories within results in the script's output path as a combined output and by sample outputs.

### KX384945 ViroConstrictor Analysis

**Script:** scripts/viroconstrictor/viroconstrictor_ds1641_KX384945.sh

This ViroConstrictor analysis script excluded MatchRef, and ran only the poorer sutied KX384945 reference genome against barcodes to produce results for comparison against KX384945 ARTIC results.

**Input:** results/adeno_E4/viroconstrictor/raw_combined_fastqs/
references/HAdV_E4_KX384945_uppercase_and_ungapped.fasta
bed_files/KX384945.scheme.SA.update.bed

**Output:** results/adeno_E4/viroconstrictor/ds1641_KX384945/

Key ouputs of this analysis were produced by the pipeline in the same way as the ViroConstrictor MatchRef script

### 3.4 ViroConstrictor Metrics

**Scripts:** scripts/viroconstrictor/viroconstrictor_matchref_metrics.sh
scripts/viroconstrictor/viroconstrictor_KX384945_metrics.sh

These two scripts were used to extract consensus sequence metrcis from ViroConstrictor outputs

Similar to ARTIC the scripts extract and calculate consensus sequence length, A, C, G, and T base counts, ambiguous base counts and percentage of ambiguous bases (%N) for barcodes against the reference genomes.

**Output:** viroconstrictor_matchref_consensus_metrics.tsv
viroconstrictor_KX_consensus_metrics.tsv

## 4. Downstream Analysis and Visualisation Barplot

A series of four R scripts are included in this repository that visualised results of the pipelines.
Barcode62 is excluded from every analysis in the scripts as it one primer pool failed to amplify in the laboratory, and this was seen Barcode62's consensus sequences.

### 4.1 ARTIC Reference Comparison

**Script:** scripts/analysis/artic_percentage_n_plot.R

This script compares the percentage of ambiguous bases of barcodes ran against both MN307142 and KX384945 using ARTIC

**Input:** artic_consensus_metrics.csv

*(The artic consensus metrics were converted from tsv to csv for script input)*

**Output:** ARTIC_percentage_N_MN_vs_KX.png

### 4.2 ViroConstrictor Amplicon Coverage Heatmap

**Script:** scripts/analysis/viroconstrictor_amplicon_coverage_heatmap.R

This script visualises the mean amplicon coverage across the MN307142 tiled-amplicon scheme, with amplicons displayed in genomic order (1-18). and barcodes measured against them.

**Input:** all_amplicon_coverage.csv

**Output:** ViroConstrictor_MN307142_amplicon_coverage_heatmap.png

### 4.3 Pipeline Mutation Comparison Grouped-Barplot

**Script:** scripts/analysis/pipeline_mutation_comparison.R

This script compared the reported mutation counts between the consensus genomes generated against MN307142 and KX384945 by both the ARTIC and ViroConstrictor pipelines.
There two separate panels, one panel to show mutation counts for KX384945 consensus sequences between both pipelines, and the other to show the mutation counts for MN307142 consensus sequences between both pipelines.

**Input:** mutation_counts.csv

*It should be noted the script hardcoded mutation counts into a single CSV. ARTIC mutation counts could be seen in the PASS variants column on the ARTIC consensus tsv, and ViroConstrictor mutation counts were automatically produced in the all_mutations.tsv under both result file paths for the MatchRef and KX384945 analyses.*

**Output:** pipeline_mutation_comparison.png

### 4.4 HAdV-E4 Linear Genome and Amplicon Map

**Script:** scripts/analysis/hadv_e4_genome_amplicon_map.R

This script visualises a linear representation of the HAdV-E4 genome that shows genomic postions and the layout of the 18 tiled amplicons of the MN307142 bed scheme.

**Input:** Accessible GenBank annotated MN307142 HAdV genome gene coordinates and MN307142 primer scheme amplicon coordinates (which is provided in this repository).

**Output:**: HAdV_E4_gene_overlap_amplicon_map.svg

### Author 

Jiaan Randhawa-Heer
MSc Bioinformatics
University of Nottingham

### Project Supervisors

Dr Patrick McClure, University of Nottingham

Dr Stuart Astbury, University of Nottingham
