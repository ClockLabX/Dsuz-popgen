#!/bin/bash

#options for sbatch
#SBATCH --nodes=1
#SBATCH --job-name=ngsLD
#SBATCH --ntasks=1 # Number of tasks (typically one)
#SBATCH --cpus-per-task=12 # number of CPUs for multithreaded programs (FARM CPUs can handle 2 threads/core simultaneously)
#SBATCH --mem=20G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=7-0:00 # 0 days, 2 hours
#SBATCH --partition=med
#SBATCH --output=slurmout/%x-%j.out # File to which STDOUT will be written, with job name and Job ID
#SBATCH --error=slurmout/%x-%j.err # File to which STDERR will be written, with job name and Job ID

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME


# checking for and setting up variables
if (($#!=5)); then
        echo "Usage: script.sh regions_files.intervals GL_directory Output_directory bam_list.txt positions-files-w/-header" >&2
        exit 2
fi

REGIONS=$1
INDIR=$2
OUTDIR=$3
BAMLIST=$4
POSITIONS=$5
BASENAME=$(basename $REGIONS .intervals)

SNPCOUNT=$(expr $(zcat $INDIR/$BASENAME.mafs.gz | wc -l) - 1)
#length of mafs file, minus the header line.

echo "Number of SNPs used:" $SNPCOUNT

echo "Running ngsLD to estimate LD"
ngsLD --n_threads $SLURM_CPUS_PER_TASK \
    --geno $INDIR/$BASENAME.beagle.gz \
    --probs \
    --n_ind `wc $BAMLIST -l` \
    --posH $POSITIONS \
    --n_sites $SNPCOUNT \
    --max_kb_dist 100 \
    --outH $OUTDIR/$BASENAME.100kb.ld

echo "Gzipping ld file"
pigz -p $SLURM_CPUS_PER_TASK $OUTDIR/$BASENAME.100kb.ld

# estimating linkage. Need to supply ngsLD with number of individuals, number of sites, GLs.
# also supplying SNP locations, so it doesn't waste time to calc LD for monomorphics.
# using max distance of 100kb for calculation.
#using outH to output with headers.

echo "subsample 1% of LD results"
zcat $OUTDIR/$BASENAME.100kb.ld.gz | awk '/#/ {print}; rand()<0.01 {print}' | gzip -c > $OUTDIR/$BASENAME.100kb.1%.ld.gz

echo "plot LD decay "
echo $OUTDIR/$BASENAME.100kb.1%.ld.gz | \
    Rscript --vanilla --slave ~/programs/ngsLD-1.1.1/scripts/fit_LDdecay.R \
    --ld r2 \
    --fit_bin_size 100 \
    --recomb_rate 2.3 \
    --fit_boot 100 \
    --plot_size 1.5,4.5 \
    --fit_level 10 \
    --plot_data \
    -o $OUTDIR/decay-plots/$i-1percent.lddecay.png


# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
