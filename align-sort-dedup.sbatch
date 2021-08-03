#!/bin/bash

#options for sbatch
#SBATCH --nodes=1
#SBATCH --ntasks=1 # Number of cores (NOT FOR MULTITHREADING)
#SBATCH --cpus-per-task=8 # number of CPUs for multithreaded programs
#SBATCH --mem=16000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=6:00:00 # 0 days, 2 hours
#SBATCH --partition=med
#SBATCH --output=slurmout/%x-%J.out # File to which STDOUT will be written, with Node and Job ID
#SBATCH --error=slurmout/%x-%J.err # File to which STDERR will be written, with Node and Job ID


if (($#!=5)); then
        echo "Usage: align.sh sample_name reference.fa read1.fq.gz read2.fq.gz readgroup_str" >&2
        exit 2
fi
sample=$1
reference=$2
read1=$3
read2=$4
readgroup=$5

module load bwa/0.7.9a
module load samtools/1.3.1
module load picardtools/2.7.1
module load java/1.8

echo "+++ Running BWA and sorting bams"
bwa mem \
        -t $SLURM_CPUS_PER_TASK \
        -R $readgroup \
        $reference \
        $read1 $read2 | \
samtools sort -@ $SLURM_CPUS_PER_TASK -O bam -o ${sample}.sorted.bam -
echo "+++ Mark duplicates"
java -Xmx8g -jar $picardtools_HOME/picard.jar MarkDuplicates \
        I=${sample}.sorted.bam \
        O=${sample}.nodup.bam \
        M=${sample}.dup_metrics.txt
echo "+++ Indexing"
samtools index ${sample}.nodup.bam

echo "+++ Done"