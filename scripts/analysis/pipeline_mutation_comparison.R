###############################################
#        Author: Jiaan Randhawa-Heer          #
#  Title: Pipeline Mutation Comparison Plot   #
#       HAdV-E4 Pipeline Comparison           #
###############################################

mutation_counts <- data.frame(
  Sample = c("65", "66", "67", "68", "69", "70", "71", "72", "77"),
  ARTIC_MN = c(0, 0, 1, 3, 2, 0, 0, 0, 0),
  ARTIC_KX = c(49, 47, 48, 50, 49, 46, 47, 47, 47),
  Viro_MN = c(0, 0, 1, 3, 2, 0, 0, 0, 0),
  Viro_KX = c(56, 55, 54, 57, 56, 55, 55, 58, 57)
)
write.csv(mutation_counts, "mutation_counts.csv", row.names = FALSE)

#install.packages("ggplot2") # Installs ggplot2 if required
#install.packages("dplyr") # Installs dplyr if required
#install.packages("tidyr") # Installs tidyr if required

# Load required packages
library(dplyr) # Loads dplyr
library(tidyr) # Loads tidyr
library(ggplot2) # Loads ggplot2

mutations_file <- "mutation_counts.csv" # Sets path to the mutations CSV file

if (!file.exists(mutations_file)) {
  stop("Mutations file not found, check the file path or file name") # Checks that the input file exists
}

mutation_counts <- read.csv(mutations_file, header = TRUE) # Loads the mutations data

head(mutation_counts) # Checks the dataframe has loaded correctly
colnames(mutation_counts) # Outputs column names
summary(mutation_counts) # Summarises the data

# Removes the "barcode" prefix to shorten the x-axis labels
mutation_counts$Sample <- gsub("barcode", "", mutation_counts$Sample)

# Pivots to long format for ggplot
mutation_long <- mutation_counts |>
  tidyr::pivot_longer(cols = c(ARTIC_MN, ARTIC_KX, Viro_MN, Viro_KX), names_to = "Pipeline_Ref", values_to = "Mutations")

# Creates a pipeline column to use for the fill colour
mutation_long$Pipeline <- ifelse(grepl("ARTIC", mutation_long$Pipeline_Ref), "ARTIC", "ViroConstrictor")

# Creates groups for the MN307142 and KX384945 reference panels
mutation_long$Reference_Group <- ifelse(mutation_long$Pipeline_Ref %in% c("ARTIC_MN", "Viro_MN"),
                                        "MN307142 reference", "KX384945 reference")

# Creates grouped bar chart comparing mutations across pipelines and references
mutation_plot <- ggplot(mutation_long, aes(x = Sample, y = Mutations, fill = Pipeline) # Sets axes and fill to pipeline
)+
  geom_col(position = position_dodge(width = 0.75), width = 0.75, colour = "black") + # Sets bar sizes and outline
  scale_fill_manual(values = c("ARTIC" = "blue", "ViroConstrictor" = "red")) + # Sets one colour per pipeline
  facet_wrap(~Reference_Group, scales = "free_y") + # Splits plot into MN and KX panels with independent y-axes
  labs(x = "Barcode", y = "Mutation count", fill = "Pipeline" # Labels axes and legend
  )+
  theme_classic() + theme(axis.title = element_text(face = "bold", size = 12), axis.text = element_text(size = 11), legend.title = element_text(face = "bold"), legend.position = "right") # Styles the plot

mutation_plot # Outputs the completed plot

# Saves the plot to the current working directory
ggsave("pipeline_mutation_comparison.png", plot = mutation_plot, width = 8, height = 5, dpi = 300)