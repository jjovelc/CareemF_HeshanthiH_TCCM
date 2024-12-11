# Load necessary libraries
library(dplyr)
library(tidyr)
library(readr)

# Load metadata and PICRUSt2 results
metadata <- read_tsv("metadata.tsv")
picrust_results <- read_tsv("picrust2_results.tsv")

# Ensure columns are formatted correctly
colnames(metadata) <- c("Sample", "Bird", "Infection", "Time", "Tissue")

# Check if samples in PICRUSt2 match metadata
data_samples <- colnames(picrust_results)[3:ncol(picrust_results)]
missing_samples <- setdiff(data_samples, metadata$Sample)
if (length(missing_samples) > 0) {
  stop("The following samples in PICRUSt2 results are not in metadata: ", paste(missing_samples, collapse = ", "))
}

# Reorder metadata to match the sample order in PICRUSt2 results
metadata_reordered <- metadata %>% 
  filter(Sample %in% data_samples) %>% 
  arrange(match(Sample, data_samples))

# Verify that sample orders now match
if (!all(metadata_reordered$Sample == data_samples)) {
  stop("Sample orders still do not match!")
}

# Create LEfSe input format
# Combine metadata group (e.g., Infection) with PICRUSt2 results
lefse_input <- picrust_results %>%
  select(function, description, all_of(metadata_reordered$Sample)) %>%
  pivot_longer(-c(function, description), names_to = "Sample", values_to = "Abundance") %>%
  left_join(metadata_reordered, by = c("Sample" = "Sample")) %>%
  select(-c(Bird, Time, Tissue)) %>% # Retain only relevant metadata
  pivot_wider(names_from = Sample, values_from = Abundance)

# Add metadata row for LEfSe grouping
lefse_input <- lefse_input %>%
  add_row(function = "Infection", description = "", .before = 1) %>%
  mutate(across(starts_with("Sample"), ~ ifelse(function == "Infection", Infection, .))) %>%
  select(-Infection) # Remove the now-duplicate metadata column

# Save the LEfSe input file
write_tsv(lefse_input, "lefse_input.txt", col_names = FALSE)

cat("LEfSe input file created: lefse_input.txt")
