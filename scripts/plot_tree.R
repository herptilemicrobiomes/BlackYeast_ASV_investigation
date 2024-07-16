#!/usr/bin/env Rscript

library(argparse)
library(ggtree)
library(ggplot2)
library(tidyverse)
library(phytools)
# Define command-line arguments
parser <- ArgumentParser(description = "Plot a phylogenetic tree coloring ASVs")
parser$add_argument("treefile", help = "Path to the tree file")
parser$add_argument("outfile", help = "Path to the output PDF or PNG")
args <- parser$parse_args()

tree <- read.tree(args$treefile)
rootedtree = midpoint.root(tree)

dd = tibble(label = tree$tip.label) %>% mutate(ITStype = ifelse(
  startsWith(label,"ASV"), "ASV",
  "Reference"))

df <- as.data.frame(dd)
rownames(df) <- df$label
df$label <- NULL

p1 <- ggtree(rootedtree, layout="rectangular",size=0.5) %<+% dd + 
  geom_tiplab(size=1.75, aes(color=ITStype)) +
  scale_color_manual(values = c("red","black")) + theme_tree() + theme(legend.position="none")

ggsave(args$outfile,p1,height=20,width=20)
