###############################################
#        Author: Jiaan Randhawa-Heer          #
# Title: ARTIC Consensus N Percentage Plot    #
#       HAdV-E4 Reference Comparison          #
###############################################


#install.packages("readr") #installs readrr if required
#install.packages("ggplot2") #installs ggplot2 if required
#install.packages("dplyr") #installs dplyr if required

# Load required packages
library(readr) # Loads readr 
library(dplyr) # Loads dplyr 
library(ggplot2) # Loads ggplot2 

artic_metrics <- "artic_consensus_metrics.csv" # Sets the path to the ARTIC metrics CSV file

if (!file.exists(artic_metrics)) {
  stop("ARTIC metrics file not found, check the file path or file name") # Checks that the input file exists
}

artic_metrics <- readr::read_csv(artic_metrics, show_col_types = FALSE) # Loads the metrics data

head(artic_metrics) # Checks the dataframe has loaded correctly
colnames(artic_metrics) # Ouputs the column names of the data
summary(artic_metrics) # Summarises the data

# Removes barcode62 because one primer pool failed to amplify
artic_metrics_no_62 <- artic_metrics |>
  dplyr::filter(Barcode != "barcode62")

table(artic_metrics_no_62$Barcode) # Produces a table of the data to check barcode62 removal

# Removes the "barcode" prefix to shorten the x-axis labels
artic_metrics_no_62$Barcode <- gsub("barcode", "", artic_metrics_no_62$Barcode)

# Creates grouped bar chart that compares the percentage N between reference genomes used
percentage_N_plot <- ggplot(artic_metrics_no_62,
                            aes(x = Barcode, y = Percentage_N, fill = Reference) # Sets data be used in the plot
)+
  geom_col(position = position_dodge(width = 0.75), width = 0.75, colour = "black") + # Seperates the bars, sets the width and colour of the bar's outline
  scale_fill_manual(values = c("MN307142" = "green","KX384945" = "red") # Sets colour differences to indicate the different references
  )+
  labs(x = "Barcode", y = "Ambiguous bases (N%)", fill = "Reference genome") + # Labels the axes and the figure legend
  theme_classic() + theme(axis.title = element_text(face = "bold", size = 12),
                          axis.text = element_text(size = 11),
                          legend.title = element_text(face = "bold"), legend.position = "right") # Positions the figure legend

percentage_N_plot # Outputs the completed plot

# Saves the plot to the current working directory
ggsave("ARTIC_percentage_N_MN_vs_KX.png", 
       plot = percentage_N_plot, width = 8, height = 5, dpi = 300)