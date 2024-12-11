#!/usr/bin/env bash

# Activate the conda environment
# Uncomment the line below if the environment is not already active
# conda activate qiime2-2022.8

start=`date +%s`

echo "Starting PICRUSt2 pipeline..."

eval "$(conda shell.bash hook)"
conda activate picrust2

##### PICRUSt2 Pipeline #####
# Reference: https://github.com/picrust/picrust2/wiki/PICRUSt2-Tutorial-(v2.5.0)

# Define input files and parameters
REP_SEQS="rep_seqs.fasta"
OTU_TABLE="otu_table.biom"
THREADS=48
INTERMEDIATE_DIR="intermediate/place_seq"
OUT_TREE="out.tre"
EC_OUTPUT="EC_predicted.tsv.gz"
MARKER_OUTPUT="marker_predicted_and_nsti.tsv.gz"
METAGENOME_DIR="EC_metagenome_out"
PATHWAYS_DIR="pathways_out"

#  Place sequences in the reference tree
if [ -f "$REP_SEQS" ]; then
  echo "Placing sequences in reference tree..."
  mkdir -p "$INTERMEDIATE_DIR"
  place_seqs.py -s "$REP_SEQS" -o "$OUT_TREE" -p "$THREADS" --intermediate "$INTERMEDIATE_DIR"
else
  echo "Error: Representative sequences file '$REP_SEQS' not found!"
  exit 1
fi

#  Hidden-state prediction of gene families
if [ -f "$OUT_TREE" ]; then
  echo "Performing hidden-state prediction for gene families..."
  hsp.py -i 16S -t "$OUT_TREE" -o "$MARKER_OUTPUT" -p "$THREADS" -n
  hsp.py -i EC -t "$OUT_TREE" -o "$EC_OUTPUT" -p "$THREADS"
else
  echo "Error: Tree file '$OUT_TREE' not found!"
  exit 1
fi

#  Generate metagenome predictions
if [ -f "$OTU_TABLE" ] && [ -f "$MARKER_OUTPUT" ] && [ -f "$EC_OUTPUT" ]; then
  echo "Generating metagenome predictions..."
  mkdir -p "$METAGENOME_DIR"
  metagenome_pipeline.py -i "$OTU_TABLE" -m "$MARKER_OUTPUT" -f "$EC_OUTPUT" -o "$METAGENOME_DIR" --strat_out
else
  echo "Error: Required files for metagenome prediction not found!"
  exit 1
fi

#  Convert to PICRUSt1 format
if [ -f "$METAGENOME_DIR/pred_metagenome_contrib.tsv.gz" ]; then
  echo "Converting to PICRUSt1 format..."
  convert_table.py "$METAGENOME_DIR/pred_metagenome_contrib.tsv.gz" -c contrib_to_legacy -o "$METAGENOME_DIR/pred_metagenome_contrib.legacy.tsv.gz"
else
  echo "Error: Metagenome contribution file not found!"
  exit 1
fi

#  Infer pathway-level abundances
if [ -f "$METAGENOME_DIR/pred_metagenome_contrib.tsv.gz" ]; then
  echo "Inferring pathway-level abundances..."
  mkdir -p "$PATHWAYS_DIR"
  pathway_pipeline.py -i "$METAGENOME_DIR/pred_metagenome_contrib.tsv.gz" -o "$PATHWAYS_DIR" -p "$THREADS"
else
  echo "Error: Pathway prediction input file not found!"
  exit 1
fi

#  Add functional descriptions
if [ -f "$METAGENOME_DIR/pred_metagenome_unstrat.tsv.gz" ]; then
  echo "Adding functional descriptions for metagenome..."
  add_descriptions.py -i "$METAGENOME_DIR/pred_metagenome_unstrat.tsv.gz" -m EC -o "$METAGENOME_DIR/pred_metagenome_unstrat_descrip.tsv.gz"
fi

if [ -f "$PATHWAYS_DIR/path_abun_unstrat.tsv.gz" ]; then
  echo "Adding functional descriptions for pathways..."
  add_descriptions.py -i "$PATHWAYS_DIR/path_abun_unstrat.tsv.gz" -m METACYC -o "$PATHWAYS_DIR/path_abun_unstrat_descrip.tsv.gz"
fi

# Print runtime
end=`date +%s`
runtime=$((end-start))
echo "PICRUSt2 pipeline completed in $runtime seconds."

