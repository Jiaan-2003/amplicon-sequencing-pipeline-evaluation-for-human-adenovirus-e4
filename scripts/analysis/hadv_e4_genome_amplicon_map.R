###############################################
#        Author: Jiaan Randhawa-Heer          #
#      Title: HAdV-E4 Linear Genome Map       #
#         Gene and Amplicon Positions         #
###############################################
#install.packages("ggplot2") # Installs ggplot2 if required
#install.packages("gggenes") # Installs gggenes if required
#install.packages("dplyr") # Installs dplyr if required
#install.packages("svglite") # Installs svglite if required

# Load required packages  
library(gggenes) # Loads gggenes  
library(dplyr) # Loads dplyr  
library(ggplot2) # Loads ggplot2  
library(svglite) # Loads svglite

# Creates a dataframe of gene coordinates that were manually extracted from the annotated MN307142 GenBank reference  
genes <- data.frame(  
  molecule = "Genes",  
  gene = c("E1A", "E1B", "IX", "IVa2", "E2B", "L1", "L2", "L3", "E2A", "L4", "E3", "L5", "E4"),  
  start = c(576, 1518, 3441, 3901, 5035, 7816, 13757, 17310, 21697, 23205, 26904, 31459, 32832),  
  end = c(1469, 3884, 3869, 5556, 12155, 13696, 17278, 21660, 23236, 26903, 31279, 32736, 35960),  
  forward = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE)  
)  

# Creates a dataframe of the 18 amplicon positions extracted from the MN307142 primer scheme BED file  
amplicons <- data.frame(  
  molecule = rep(c("Amplicons 1", "Amplicons 2"), 9), # Alternates amplicons between two tracks to display overlaps
  gene = as.character(1:18), # Uses numbers only as amplicon labels
  start = c(26, 2160, 4301, 6205, 8079, 9886, 11954, 14128, 16099,  
            18094, 20216, 22170, 24258, 26364, 28469, 30530, 32646, 33642),  
  end = c(2265, 4385, 6491, 8407, 10291, 12040, 14181, 16314, 18307,  
          20315, 22429, 24382, 26445, 28594, 30631, 32729, 34853, 35934),  
  forward = TRUE  
)  

# Sets the order so alternating amplicon tracks appear above genes
genes$molecule <- factor(genes$molecule, levels = c("Amplicons 1", "Amplicons 2", "Genes"))  
amplicons$molecule <- factor(amplicons$molecule, levels = c("Amplicons 1", "Amplicons 2", "Genes"))  

# Creates the linear genome map with separate gene and amplicon tracks  
genome_plot <- ggplot() +  
  geom_gene_arrow(data = genes, aes(xmin = start, xmax = end, y = molecule, fill = gene, forward = forward) # Draws directional gene arrows  
  ) +
  geom_gene_label(data = genes, aes(xmin = start, xmax = end, y = molecule, label = gene, forward = forward), align = "left" # Labels each gene arrow  
  ) +
  geom_gene_arrow(data = amplicons, aes(xmin = start, xmax = end, y = molecule, forward = forward), fill = "grey70" # Draws the 18 amplicons above the gene track
  ) +
  geom_gene_label(data = amplicons, aes(xmin = start, xmax = end, y = molecule, label = gene, forward = forward), min.size = 2.5 # Labels each amplicon with its number
  ) +
  scale_fill_brewer(palette = "Set3") + # Sets the colour palette for gene arrows  
  scale_x_continuous(limits = c(0, 36000), breaks = seq(0, 35000, 5000)) + # Sets the genome position axis  
  scale_y_discrete(labels = c("Amplicons 1" = "Amplicons", # Formats y axis correctly
                              "Amplicons 2" = "",
                              "Genes" = "Genes")) + 
  
  labs(x = "Genome position (nt)", y = "" # Labels the axis
  ) +
  theme_genes() + theme(axis.title = element_text(face = "bold", size = 12), axis.text = element_text(size = 11),
                        legend.position = "none") # Removes the legend
genome_plot # Outputs the completed plot  
# Saves the plot to the current working directory  
ggsave("HAdV_E4_gene_overlap_amplicon_map.svg", plot = genome_plot, width = 14, height = 5)