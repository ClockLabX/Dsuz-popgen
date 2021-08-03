#!/bin/bash

#options for sbatch
#SBATCH --nodes=1
#SBATCH --job-name=theta
#SBATCH --ntasks=1 # Number of tasks (typically one)
#SBATCH --cpus-per-task=40 # number of CPUs for multithreaded programs ($SLURM_CPUS_PER_TASK)
#SBATCH --mem=280G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=6-0:00 # 0 days, 2 hours
#SBATCH --partition=bigmemm
#SBATCH --output=slurmout/%x-%j.out # File to which STDOUT will be written, with job name and Job ID
#SBATCH --error=slurmout/%x-%j.err # File to which STDERR will be written, with job name and Job ID

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

#make a slurmout directory if one does not exist already
if [[ ! -d slurmout ]]
then
        mkdir slurmout
fi

# checking for and setting up variables
if (($#!=4)); then
        echo "Usage: script.sh ref output_prefix bamfilelist '-rf region_file'" >&2
        exit 2
fi

ref=$1
prefix=$2
bamlist=$3
region=$5
#in command line, need to specify as "-rf file.txt", where file.txt contains list of contigs.

# loading modules
angsd="/home/kmlewald/programs/angsd933/angsd"

# running commands
echo "Calculating SAF"
angsd -P $SLURM_CPUS_PER_TASK \
        -minQ 20 \
        -minmapQ 20 \
        -bam $bamlist \
        -doSaf 1 \
        -anc $ref \
        -GL 1 \
        -out saf/$prefix $region

echo "running realSFS"
~/programs/angsd933/misc/realSFS saf/$prefix.saf.idx \
        -P $SLURM_CPUS_PER_TASK \
        -fold 1 \
        -maxIter 400 > sfs/$prefix.sfs

echo "calculating thetas per site"
~/programs/angsd933/misc/realSFS saf2theta saf/$prefix.saf.idx \
        -P $SLURM_CPUS_PER_TASK \
        -sfs sfs/$prefix.sfs \
        -outname theta/$prefix

echo "calc theta stat block windows"
~/programs/angsd933/misc/thetaStat do_stat theta/$prefix.thetas.idx  \
        -win 20000 \
        -step 20000 \
        -outnames theta/"$prefix"-win20000

echo "done"

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed