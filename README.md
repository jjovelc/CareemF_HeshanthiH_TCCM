# Delmarva IBV Microbiome Analysis Pipeline

## :cherry_blossom: Overview :cherry_blossom:
This repository contains the bioinformatics analysis workflow for investigating how Delmarva (DMV1639) infectious bronchitis virus infection alters the microbiome of gastrointestinal and respiratory tracts of broiler chickens. The analysis characterizes tracheal and cecal microbiome changes at 6, 9, and 15 days post-infection.

## :cyclone: Analysis Workflow

### ✅ Quality Control
- Raw sequencing reads were assessed using **FastQC (Version 0.12.1)**

### ✅ Taxonomy Analysis
- **Kraken2** was used for taxonomic classification of reads
- Viral-associated reads were excluded from further analysis

### ✅ Assembly
Reads passing quality control were assembled using two de novo assembly approaches:
- **metaSPAdes (Version 3.15.5)**
- **megahit**

### ✅ Functional Analysis
- **HUMAnN3** was employed for functional analysis on 5 million forward reads
- Results were visualized in R (4.4.1)

### ✅ Resistome Analysis
- **AMRFinderPlus** database was used to analyze assembled contigs for antimicrobial resistance genes

### ✅ Statistical Analysis and Visualization
All statistical analyses and visualizations were performed in R and RStudio (4.4.1) using:
- **phyloseq** - for microbiome data analysis
- **ggplot2** - for data visualization
- **dplyr** - for data manipulation
- **vegan** - for ecological diversity analysis
- **MaAsLin2** - for microbiome multivariable association with linear models

#### ✅ Diversity Metrics
**Alpha Diversity Analysis:**
- Simpson index
- Shannon index
- Evenness
- Statistical significance assessed using Wilcoxon rank-sum test

**Beta Diversity Analysis:**
- Non-metric multidimensional scaling (NMDS) ordination
- Statistical significance assessed with Permutational Multivariate Analysis of Variance (PERMANOVA)

#### ✅ Metabolic Pathway Analysis
- **PICRUSt** was used to derive the metabolic capacity of the microbiome
- Greengenes database was used to develop a reference phylogenetic tree
- Gene counts per sample were linked to KEGG pathways

## :cyclone: References

1. Wood DE, Lu J, Langmead B. Improved metagenomic analysis with Kraken 2. Genome Biol. 2019;20(1):257.
2. Nurk S, et al. metaSPAdes: a new versatile metagenomic assembler. Genome Res. 2017;27(5):824-834.
3. Beghini F, et al. Integrating taxonomic, functional, and strain-level profiling of diverse microbial communities with bioBakery 3. eLife. 2021;10:e65088.
4. Mallick H, et al. Multivariable association discovery in population-scale meta-omics studies. PLoS Comput Biol. 2021;17(11):e1009442.
5. Feldgarden M, et al. AMRFinderPlus and the Reference Gene Catalog facilitate examination of the genomic links among antimicrobial resistance, stress response, and bacterial taxonomy. Scientific Reports. 2021;11(1):12728.
6. Dixon P. VEGAN, a package of R functions for community ecology. J Veg Sci. 2003;14(6):927-930.
7. McMurdie PJ, Holmes S. phyloseq: an R package for reproducible interactive analysis and graphics of microbiome census data. PLoS ONE. 2013;8(4):e61217.
```
