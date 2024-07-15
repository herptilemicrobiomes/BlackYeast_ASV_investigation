#!/usr/bin/bash -l
#SBATCH -p short -c 24 --mem 24gb --out logs/make_Chaeto_tree.log


OUTDIR=analysis/Chaetothryiales
mkdir -p $OUTDIR
# make a file from UNITE of all Chaetothyriales
gzip -dc data/sh_general_release_dynamic_s_all_29.11.2022_dev.fasta.gz | \
    ./ASV_phylo_investigate/scripts/extract_taxon_UNITE.py \
	-o $OUTDIR/ITS__Chaetothyriales_UNITE.fa \
	--query o__Chaetothyriales

# make a file from Vargas et al 2024 UHM ITS1 of all Chaetothryiales
gzip -dc data/UHM_220913_herptile_microbiome/asv_tax_UNITE.fasta.gz | \
    ./ASV_phylo_investigate/scripts/extract_taxon_ASVfasta.py \
	-o $OUTDIR/ITS__Chaetothyriales_UHM_220913_herptile.fa \
	--query o__Chaetothyriales

module load mafft
module load fasttree

pushd $OUTDIR
cat ITS__Chaetothyriales_UNITE.fa ITS__Chaetothyriales_UHM_220913_herptile.fa > ITS__Chaetothyriales_combined.fa
mafft ITS__Chaetothyriales_combined.fa > ITS__Chaetothyriales_combined.fasaln
FastTreeMP -nt -gtr -gamma ITS__Chaetothyriales_combined.fasaln > ITS__Chaetothyriales_combined.FT.tre
