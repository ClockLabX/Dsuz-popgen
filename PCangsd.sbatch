#!/bin/bash

#options for sbatch/slurm
#SBATCH --nodes=1
#SBATCH --job-name=pcangsd
#SBATCH --ntasks=1 # Number of tasks (typically one)
#SBATCH --cpus-per-task=4 # number of CPUs for multithreaded programs (variable is $SLURM_CPUS_PER_TASK)
#SBATCH --mem=8G # Memory pool for all cores combined. G=gigabytes. (see also --mem-per-cpu)
#SBATCH --time=1-0 # format: 3-0 means 3 days, 0 hours. 3:10:20 means 3 hours, 10 minutes, 20 seconds.
#SBATCH --partition=med #which node are you using?
#SBATCH --output=slurmout/%x-%j.out # File to which STDOUT will be written, with job name and Job ID
#SBATCH --error=slurmout/%x-%j.err # File to which STDERR will be written, with job name and Job ID

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

# checking for and setting up variables
if (($#!=4)); then
        echo "Usage: script.sh beagle.gz_file text_file_specifying_samples sample_names.txt output_filename" >&2
        exit 2
fi

#set input parameters
BEAGLE=$1
SAMPLES=$2
#text file of 0s or 1s, specifying which samples in beagle.gz to keep.
SAMPLES_NAME=$3
#sample_names file contains sample names, 1/line, in same order as beagle.gz file.
OUTPUT=$4

# loading desired modules/conda environment
module load bio3
PCANGSD=~/programs/pcangsd-1.0/pcangsd.py

# running commands
echo "running PCA to estimate inbreeding F and output genotypes"
python $PCANGSD -beagle $BEAGLE \
        -filter $SAMPLES \
        -threads $SLURM_CPUS_PER_TASK \
        -o $OUTPUT \
        -inbreedSamples \
        -genoInbreed 0.95
#filter needs a input file, containing 0 or 1 to tell which samples to use; same order as beagle file.
#inbreedSamples will estimate inbreeding coefficient of each sample, using estimated indiv allele freqs.
#genoInbreed calls genotypes, using inbreeding values as priors. Using 95% probability cutoff for genotype.

echo "cleaning up output files"
#attach sample names/info to inbreeding file
paste $SAMPLES_NAME $OUTPUT.inbreed.samples > $OUTPUT.inbreed.txt
rm $OUTPUT.inbreed.samples

#converting genotype npy file to text
python3 - <<HERE
import numpy as np
data = np.load("$OUTPUT.geno.inbreed.npy")
np.savetxt("$OUTPUT.temp.txt", data, fmt='%d', delimiter = '\t')
HERE

#add samples as headers to genotype text file.
cat $SAMPLES_NAME | tr "\n" "\t" | sed 's/\t$/\n/' > $OUTPUT.geno.inbreed.txt

cat $OUTPUT.temp.txt >> $OUTPUT.geno.inbreed.txt
rm $OUTPUT.temp.txt

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed