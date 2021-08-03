#!/bin/bash

#trimming PE reads with trimmomatic

#options for sbatch
#SBATCH --nodes=1
#SBATCH --ntasks=1 # Number of cores 
#SBATCH --cpus-per-task=4 # number of CPUs for multithreaded programs
#SBATCH --mem=8000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=0-12:00 # 0 days, 2 hours
#SBATCH --partition=med
#SBATCH --output=slurmout/trimming-%N-%j.out # File to which STDOUT will be written, with Node and Job ID
#SBATCH --error=slurmout/trimming-%N-%j.err # File to which STDERR will be written, with Node and Job ID

# Trimmomatic
TRIMMOMATIC_DIR="/home/kmlewald/programs/Trimmomatic-0.35"
TRIMMOMATIC_JAR="$TRIMMOMATIC_DIR/trimmomatic-0.35.jar"
ADAPTER="$TRIMMOMATIC_DIR/adapters/TruSeq3-PE-2.fa"

# Trimmomatic parameters
LEAD_SCORE=10           # leading qscore threshold
TRAIL_SCORE=10          # trailing qscore threshold
MIN_LEN=36              # minimum read length after trimming
CLIP_PARAMS="2:30:10"   # ILLUMINACLIP parameters

if (($#!=3)); then
        echo "Usage: aqtrim.sh read1.fq.gz read2.fq.gz output_prefix.fq.gz" >&2
        exit 2
fi
read1=$1
read2=$2
out_prefix=$3

echo "+++ Running Trimmomatic"
java -jar $TRIMMOMATIC_JAR PE \
  -threads 4 \
  <(gzip -cd $read1)  <(gzip -cd $read2) \
  -baseout $out_prefix \
  ILLUMINACLIP:$ADAPTER:$CLIP_PARAMS \
  LEADING:$LEAD_SCORE \
  TRAILING:$TRAIL_SCORE \
  MINLEN:$MIN_LEN
echo "+++ Done"