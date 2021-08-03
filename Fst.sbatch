#!/bin/bash

#options for sbatch
#SBATCH --nodes=1
#SBATCH --job-name=fst
#SBATCH --ntasks=1 # Number of tasks (typically one)
#SBATCH --cpus-per-task=8 # number of CPUs for multithreaded programs ($SLURM_CPUS_PER_TASK)
#SBATCH --mem=32G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=3-0 # 0 days, 2 hours
#SBATCH --partition=bigmemm
#SBATCH --output=slurmout/%x-%j.out # File to which STDOUT will be written, with job name and Job ID
#SBATCH --error=slurmout/%x-%j.err # File to which STDERR will be written, with job name and Job ID


# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

#warn if slurmout directory doesn't exist
if [[ ! -d slurmout ]]
then
        echo "error: slurmout directory does not exist"
        exit 1
fi

# checking for and setting up variables
if (($#==0)); then
        echo "Usage: script.sh saf.idx.1 saf.idx.2 out_prefix" >&2
        exit 2
fi

#saf files are same as those generated for theta and TajimaD.
saf1=$1
saf2=$2
out=$3

pop1=$(basename $saf1 .saf.idx)
pop2=$(basename $saf2 .saf.idx)

# load module
realSFS="/home/kmlewald/programs/angsd933/misc/realSFS"

# running commands
echo "running realSFS with prior on 2 pops:" $(date)
$realSFS $saf1 $saf2 \
        -P $SLURM_CPUS_PER_TASK \
        -fold 1 \
        -maxIter 400 \
        -tole 1e-10 > $out.sfs

echo "indexing/generating fst calculations:" $(date)
$realSFS fst index $saf1 $saf2 -sfs $out.sfs -fstout $out

echo "save global estimate:" $(date)
echo 'pop1' 'pop2' 'fst_unweighted' 'fst_weighted' > $out.global.fst
echo $pop1 $pop2 $($realSFS fst stats $out.fst.idx) >> $out.global.fst

echo "done"
# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed