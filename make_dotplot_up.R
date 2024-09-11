# Load necessary libraries
library(ggplot2)
library(tidyverse)

# Set working directory (adjust as needed)
setwd('/Users/juanjovel/OneDrive/jj/UofC/data_analysis/heshanthi/DESeq2_analysis/data_4_dotplot')

# Read the filtered data, treating '.' as missing values (NA)
data <- read.delim("filtered_new40_up.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE, na.strings = ".")

# Prepare the data for plotting
data_long <- data %>%
  pivot_longer(cols = -Taxa, 
               names_to = c("Condition", "Metric"), 
               names_pattern = "(.*)_(FC|pAdj)$", 
               values_to = "Value") %>%
  pivot_wider(names_from = Metric, values_from = Value) %>%
  # Convert FC and pAdj to numeric (in case they are characters)
  mutate(FC = as.numeric(FC), pAdj = as.numeric(pAdj))

# Check for any remaining problematic values in FC and pAdj
print("Summary of FC values:")
print(summary(data_long$FC))
print("Summary of pAdj values:")
print(summary(data_long$pAdj))

# Filter out rows where FC or pAdj is NA, infinite, or out of valid range
# Filter out rows where pAdj is NA or invalid
data_long <- data_long %>%
  filter(!is.na(FC) & !is.infinite(FC),  # Ensure valid FC values
         !is.na(pAdj) & !is.infinite(pAdj) & pAdj > 0 & pAdj <= 1)  # Ensure valid pAdj values

# Create the dot plot
ggplot(data_long, aes(x = Condition, y = Taxa)) +
  geom_point(aes(size = abs(FC), color = pAdj), alpha = 0.8) +
  scale_size_continuous(name = "Fold Change", range = c(1, 10)) +
  scale_color_gradient(
    low = "black",  # Low pAdj values (e.g., small p-values)
    high = "#FF0000", # High pAdj values (e.g., larger p-values)
    limits = c(1e-10, 1),  # Adjusted for p-value range
    name = "Adjusted p-value",
    na.value = "white",  # This can be changed to any color, or we can filter out NA
    trans = "log10"
  ) +
  theme_minimal() +  # Ensure the basic white background theme is applied
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),  # Increase x-axis text size
    axis.text.y = element_text(size = 14),                         # Increase y-axis text size
    legend.text = element_text(size = 12),                         # Increase legend text size
    plot.title = element_text(size = 20, face = "bold"),           # Increase title size
    legend.title = element_text(size = 14),
    panel.background = element_rect(fill = "white", color = NA),   # Set panel background to white
    plot.background = element_rect(fill = "white", color = NA)     # Set overall plot background to white
  ) +
  labs(title = "",
       x = "",
       y = "")

# Save the plot to a file with larger size
ggsave("dotplot_fc_padj_up.png", width = 10, height = 10, dpi = 300)