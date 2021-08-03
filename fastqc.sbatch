#!/bin/bash

# Run FastQC on samples

#options for sbatch
#SBATCH --job-name=fastqc # Job name
#SBATCH --nodes=1
#SBATCH --ntasks=1 # Number of individual processes to run
#SBATCH --cpus-per-task=16 #multithreading
#SBATCH --mem=8000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=3-02:00 # 0 days, 2 hours
#SBATCH --partition=bigmemm
#SBATCH --output=slurmout/fastqc-%N-%j.out # File to which STDOUT will be written, with Node and Job ID
#SBATCH --error=slurmout/fastqc-%N-%j.err # File to which STDERR will be written, with Node and Job ID

USAGE="Usage: runfastqc.sh out_dir in_fastq..."

if (($#<=2)); then
        echo $USAGE 1>&2
        exit 2
fi

OUTDIR=$1
shift
if [[ ! -d $OUTDIR ]]; then
        echo "Output directory \"$out_dir\" does not exist!"
        exit 1
fi

# Check input fastqs exist
for fq in "$@"; do
        if [[ ! -f $fq ]]; then
                echo "Input fastq file \"$fq\" does not exist!"
                exit 1
        fi
done

# Load FastQC
module load fastqc/0.11.5

echo "+++ Output directory is $OUTDIR"
echo "+++ Running fastqc on $@"
fastqc -t 16 -o $OUTDIR "$@"
echo "+++ Done"