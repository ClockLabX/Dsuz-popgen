#!/bin/bash
#variant calling samples for the mitogenome. Haploid.

#options for sbatch
#SBATCH --nodes=1
#SBATCH --ntasks=1 # Number of tasks (typically one)
#SBATCH --cpus-per-task=1 # number of CPUs for multithreaded programs
#SBATCH --mem=20G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=12:00:00 # 0 days, 2 hours
#SBATCH --partition=med
#SBATCH --output=slurmout/%x-%j.out # File to which STDOUT will be written, with job name and Job ID
#SBATCH --error=slurmout/%x-%j.err # File to which STDERR will be written, with job name and Job ID

module load samtools/1..3.1
module load bcftools/1.10.2

# Freebayes
FB_HOME="/home/kmlewald/programs/freebayes-1.1.0"
PATH=$FB_HOME/bin:$FB_HOME/scripts:$PATH
LD_LIBRARY_PATH=/home/kmlewald/programs/htslib
export TMPDIR=/home/kmlewald/temp

if (($#<4)); then
        echo "Usage: call_variants_populations.sh output_vcf_prefix fasta_reference input_bams ..."
        exit 2
fi


VCF_PREFIX=$1
shift
REF_FASTA=$1
shift
bams="$*"

echo "+++ creating a temp file for each run"
mkdir /home/kmlewald/temp/$VCF_PREFIX
export TMPDIR=/home/kmlewald/temp/$VCF_PREFIX

echo "+++ Starting freebayes on $bams"
bam_str=""
#create a single string list of all bam files input
for f in $bams; do
        bam_str="$bam_str -b $f"
done

#arguments to feed to freebayes
fb_args="--ploidy 1 --use-mapping-quality --genotype-qualities --use-best-n-alleles 4 --report-genotype-likelihood-max --standard-filters --fasta-reference $REF_FASTA $bam_str"

echo "+++ Running freebayes"
freebayes $fb_args > ${VCF_PREFIX}.vcf

echo "+++ deleting temp directory"
rm -r /home/kmlewald/temp/$VCF_PREFIX/

echo "+++ extracting consensus fasta from each sample"
for i in sample_names.txt; do
        samtools faidx $REF_FASTA KU588141.1:3090-3774 | \
        bcftools consensus $VCF_PREFIX.vcf -H A -M ? -s $i | \
        sed "s/>.*/>$i/" >> COX2.fas
done

echo "+++ Done"
