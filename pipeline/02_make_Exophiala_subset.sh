#!/usr/bin/bash -l
#SBATCH -p short -c 24 --mem 24gb --out logs/make_Exophiala_tree.log
CPU=2
if [ ! -z "$SLURM_CPUS_ON_NODE" ]; then
	CPU=$SLURM_CPUS_ON_NODE
fi
PREFIX=Exophiala
TAXONLEVEL="g"
OUTDIR=analysis/$PREFIX
mkdir -p $OUTDIR
# make a file from UNITE of all Exophiala
gzip -dc data/sh_general_release_dynamic_s_all_29.11.2022_dev.fasta.gz | \
    ./ASV_phylo_investigate/scripts/extract_taxon_UNITE.py \
	-o $OUTDIR/ITS__${PREFIX}_UNITE.fa \
	--query ${TAXONLEVEL}__${PREFIX}

# make a file from Vargas et al 2024 UHM ITS1 of all Exophiala
gzip -dc data/UHM_220913_herptile_microbiome/asv_tax_UNITE.fasta.gz | \
    ./ASV_phylo_investigate/scripts/extract_taxon_ASVfasta.py \
	-o $OUTDIR/ITS__${PREFIX}_UHM_220913_herptile.fa \
	--query ${TAXONLEVEL}__${PREFIX}

module load ITSx
module load mafft
module load fasttree

pushd $OUTDIR || exit
if [ ! -f ITS__${PREFIX}_UNITE.ITSx.ITS1.fasta ]; then
	ITSx -i ITS__${PREFIX}_UNITE.fa -o ITS__${PREFIX}_UNITE.ITSx --save_regions ITS1 --cpu $CPU -t F 
fi
# previously wanted to screen for IDentity matching but let's trust taxonomy from ASV assignment
# module load fasta
# module load samtools
#ssearch36 -E 100 -b 2 -m 8c ITS__${PREFIX}_UHM_220913_herptile.fa ITS__${PREFIX}_UNITE.ITSx.ITS1.fasta  > ITS__${PREFIX}_UHM_220913_herptile.ITS1.ssearch.tsv
#cut -f1 ITS__${PREFIX}_UHM_220913_herptile.ITS1.ssearch.tsv | sort | uniq > ITS__${PREFIX}_UHM_220913_herptile.ITS1.ids
#samtools faidx ITS__${PREFIX}_UHM_220913_herptile.fa -r ITS__${PREFIX}_UHM_220913_herptile.ITS1.ids -o ITS__${PREFIX}_UHM_220913_herptile.ITS1.fa
#cat ITS__${PREFIX}_UHM_220913_herptile.ITS1.fa ITS__${PREFIX}_UNITE.ITSx.ITS1.fasta | perl -p -e 's/\|/ /g' > ITS__${PREFIX}_combined.fa

cat ITS__${PREFIX}_UHM_220913_herptile.fa ITS__${PREFIX}_UNITE.ITSx.ITS1.fasta | perl -p -e 's/\|/ /g' > ITS__${PREFIX}_combined.fa
mafft ITS__${PREFIX}_combined.fa > ITS__${PREFIX}_combined.fasaln
FastTreeMP -nt -gtr -gamma ITS__${PREFIX}_combined.fasaln > ITS__${PREFIX}_combined.FT.tre

Rscript ../../scripts/plot_tree.R ITS__${PREFIX}_combined.FT.tre ITS__${PREFIX}_combined.FT.pdf
