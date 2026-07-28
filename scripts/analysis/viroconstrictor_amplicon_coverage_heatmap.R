################################################
#        Author: Jiaan Randhawa-Heer           #
#     Title: ViroConstrictor Amplicon          #
#              Coverage Heatmap                #
################################################
#install.packages("ggplot2") #installs ggplot2 if required
#install.packages("RColorBrewer") #installs RColorBrewer if required
#install.packages("dplyr") #installs dplyr if required
#install.packages("tidyr") #installs tidyr if required

library(ggplot2) # Loads ggplot2
library(RColorBrewer) # Loads RColorBrewer
library(dplyr) # Loads dplyr
library(tidyr) # Loads tidyr

virocon_coverage_file <- "all_amplicon_coverage.csv" # Sets the path to the ViroConstrictor coverage CSV file
if (!file.exists(virocon_coverage_file)) {
  stop("ViroConstrictor coverage file not found, check the file path or file name") # Checks that the input file exists
}

virocon_coverage <- read.csv(virocon_coverage_file, header = TRUE) # Loads the amplicon coverage data
head(virocon_coverage) # Checks the dataframe has loaded correctly
colnames(virocon_coverage) # Outputs column names
summary(virocon_coverage) # Summarises the data

# Removes barcode62 because one primer pool failed to amplify
virocon_coverage_no_62 <- virocon_coverage |>
  dplyr::filter(amplicon_names != "barcode62")
table(virocon_coverage_no_62$amplicon_names) # Checks that barcode62 has been removed

# Removes the "barcode" prefix to shorten the row labels
virocon_coverage_no_62$amplicon_names <- gsub("barcode", "", virocon_coverage_no_62$amplicon_names)
# Pivots the coverage data into long format for ggplot
coverage_long <- virocon_coverage_no_62 |>
  tidyr::pivot_longer(cols = starts_with("HAdVE4_"), # Selects the amplicon coverage columns
                      names_to = "Amplicon", # Makes a column for the amplicon names
                      values_to = "Coverage") # Makes a column for the coverage values

# Removes the "HAdVE4_" prefix and keeps only the amplicon number
coverage_long$Amplicon <- gsub("HAdVE4_", "", coverage_long$Amplicon)
coverage_long$Amplicon <- gsub("^0+", "", coverage_long$Amplicon) # Removes leading zeros from single-digit amplicons

# Sets the amplicon order as numeric so they plot 1-18 rather than alphabetically
coverage_long$Amplicon <- factor(coverage_long$Amplicon, levels = as.character(1:18))
# Creates the colour scale for the heatmap
coverage_colours <- colorRampPalette(rev(brewer.pal(9, "Reds")))(255)

# Creates the heatmap using geom_tile
coverage_heatmap <- ggplot(coverage_long, aes(x = Amplicon, y = amplicon_names, fill = Coverage) # Sets the data to axes and fill
) +
  geom_tile(colour = "black") + # Colours the tile borders black
  scale_fill_gradientn(colours = coverage_colours, name = "Mean coverage") + # Sets the colour gradient and legend title
  labs(title = "ViroConstrictor Mean Amplicon Coverage Using the MN307142 Reference", # Titles the heatmap
       x = "Amplicon", y = "Barcode") + # Titles the axes
  theme_classic() + theme(axis.title = element_text(face = "bold", size = 12), # Styles the axis titles
                          axis.text = element_text(size = 11), # Styles the axis text
                          plot.title = element_text(face = "bold", size = 12, hjust = 0.5), # Styles the plot title
                          legend.title = element_text(face = "bold")) # Styles the legend title
coverage_heatmap # Outputs the completed plot

# Saves the heatmap to the current working directory
ggsave("ViroConstrictor_MN307142_amplicon_coverage_heatmap.png", plot = coverage_heatmap, width = 8, height = 6, dpi = 300)