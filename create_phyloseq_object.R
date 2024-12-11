library(phyloseq)
library(biomformat)
library(Biostrings)

setwd('/Users/juanjovel/jj/publications/Herath_2024/heshanthi') 
# Set your own path here

metadata_file <- 'metadata.csv'
taxa_file     <- 'GTDB_RDP.tsv'
otus_file     <- 'seqtab_nochimeras.csv'

metadata  <- read.csv(metadata_file, header = T, row.names = 1)
taxonomy  <- read.table(taxa_file, header = T, row.names = 1)
otu_table <- read.csv(otus_file, header = T, row.names = 1)

# Changing names is not necessary but I hate those sequences as column names
# Extract the column names (sequences)
sequences <- colnames(otu_table)

# Generate keys for each sequence
keys <- paste0("OTU", seq_along(sequences))

# Create a table mapping keys to sequences
key_sequence_map <- data.frame(Key = keys, Sequence = sequences)

# Replace column/row names in the OTU table with the generated keys
colnames(otu_table) <- keys
row.names(taxonomy) <- keys

# Transpose otu_table
otu_table <- t(otu_table)

# Convert OTU table to matrix
otu_matrix <- as.matrix(otu_table)

# Create phyloseq OTU table
otu_table_phyloseq <- otu_table(otu_matrix, taxa_are_rows = TRUE)

# Create phyloseq sample data
sample_data_phyloseq <- sample_data(metadata)

# Create phyloseq taxonomy table
taxonomy_matrix <- as.matrix(taxonomy)
tax_table_phyloseq <- tax_table(taxonomy_matrix)

# Combine into phyloseq object
phyloseq_obj <- phyloseq(otu_table_phyloseq, sample_data_phyloseq, tax_table_phyloseq)

# Print the phyloseq object
print(phyloseq_obj)

microbiome_cecum_IBV <- subset_samples(phyloseq_obj, Tissue == "cecum" & Infection == "IBV")

microbiome_cecum_IBV@sam_data
microbiome_cecum_IBV@otu_table

# Export OTU table from the phyloseq object
otu_table <- otu_table(phyloseq_obj)

# Convert to BIOM format and write to file
biom_file <- "otu_table.biom"
biom <- make_biom(data = as(otu_table, "matrix"))
write_biom(biom, biom_file)

# Export representative sequences
otu_names <- rownames(taxonomy)
asv_sequences <- sequences

# Create a named vector mapping OTU names to ASV sequences
otu_to_asv <- setNames(asv_sequences, otu_names)

# Convert to DNAStringSet
asv_dna <- DNAStringSet(otu_to_asv)

writeXStringSet(asv_dna, filepath = "rep_seqs.fasta", format = "fasta")





