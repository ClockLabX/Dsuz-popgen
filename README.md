# README.md

Supplemental scripts for the manuscript "Population genomics of Drosophila suzukii reveal longitudinal population structure and signals of migrations in and out of the continental United States", Lewald et al, 2021.

## Index of files

+ **align-sort-dedup.sbatch**: Takes paired fastq sequences, aligns to reference, sorts, and marks duplicates.
+ **call-GLs.sbatch**: Call genotype likelihoods with ANGSD from BAM files.
+ **COX2-variants.sbatch**: Call genotypes with Freebayes from BAM files, and extract consensus sequence for each sample.
+ **fastqc.sbatch**: Run fastqc for quality control of fastq reads before and after trimming.
+ **Fst.sbatch**: Estimate Fst between populations with ANGSD from BAM files and Site Allele Frequency estimates.
+ **ld-decay.sbatch**: Estimate linkage disequilibrium using ngsLD, and plot LD decay rates.
+ **ngsadmix.sbatch**: Estimate admixture proportions from genotype likelihoods with NGSadmix.
+ **PCangsd.sbatch**: Perform from genotype likelihoods with PCangsd, and call genotypes.
+ **pcangsd-to-treemix.R**: Convert genotype calls from PCangsd into Treemix file format.
+ **prune-snps.py**: Prunes SNPs in beagle format to specified distances.
+ **theta-tajimaD.sbatch**: Estimate nucleotide diversity from BAM files using ANGSD.
+ **treemix-bootstraps.sbatch**: Run treemix with 100 bootstraps.
+ **trim-reads.sbatch**: Trim fastq reads for quality prior to alignment to reference.
