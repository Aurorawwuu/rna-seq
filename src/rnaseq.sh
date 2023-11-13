#! bin/sh

# raw data quality control
module load FastQC

fastqc -t 16 /file-path-to-directory/*.fastq.gz

# quality control trimm
module load fastp

for i in /file-path-to-directory/*.fastq.gz
do
    output="/output-file-directory/$(basename $i)"

    fastp -w 16 -i $i -o $output -j "$output.json" -h "$output.html"
done

# clean data qc

# download reference genome hg38 from UCSC
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz  ### fasta file
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/genes  ### gtf file

# prepare reference genome
STAR --runMode genomeGenerate --genomeDir /output-dir --genomeFastaFiles /input-dir/.fa --runThreadN 4

# alignment
for i in /trimmed-directory/*.fastq.gz
do
    output="/output-file-directory/$(basename $i)"
    
    ### output-dir-of-last-step==where-your-reference-genome-is
    STAR --genomeDir /output-dir-of-last-step \
    --readFilesIn  $i \
    --readFilesCommand zcat \
    --outSAMtype BAM SortedByCoordinate \
    --runThreadN 16 \
    --sjdbGTFfile dir/.gtf \
    --sjdbOverhang 49 \
    --outFileNamePrefix $output
done

# generate bam index
module load samtools
samtools index bam-directory/output.bam

# featurecount
module load subread
feattureCounts -a dir/.gtf -o output-dir/featurecounts.txt bam-dir/*.bam