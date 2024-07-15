#!/usr/bin/bash -l
#SBATCH -p short -c 24 --mem 24gb --out logs/make_Exophiala_tree.log

OUTDIR=analysis/Exophiala
mkdir -p $OUTDIR
# make a file from UNITE of all Exophiala
gzip -dc data/sh_general_release_dynamic_s_all_29.11.2022_dev.fasta.gz | \
    ./ASV_phylo_investigate/scripts/extract_taxon_UNITE.py \
	-o $OUTDIR/ITS__Exophiala_UNITE.fa \
	--query o__Exophiala

# make a file from Vargas et al 2024 UHM ITS1 of all Exophiala
gzip -dc data/UHM_220913_herptile_microbiome/asv_tax_UNITE.fasta.gz | \
    ./ASV_phylo_investigate/scripts/extract_taxon_ASVfasta.py \
	-o $OUTDIR/ITS__Exophiala_UHM_220913_herptile.fa \
	--query o__Exophiala

module load mafft
module load fasttree

pushd $OUTDIR
cat ITS__Exophiala_UNITE.fa ITS__Exophiala_UHM_220913_herptile.fa > ITS__Exophiala_combined.fa
mafft ITS__Exophiala_combined.fa > ITS__Exophiala_combined.fasaln
FastTreeMP -nt -gtr -gamma ITS__Exophiala_combined.fasaln > ITS__Exophiala_combined.FT.tre
