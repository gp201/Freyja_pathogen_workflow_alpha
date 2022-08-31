#!/bin/bash

args=($@)
work_dir=${args[0]}
fasta_file=${args[1]}
metadata_file=${args[2]}

chmod +x bin/*
# nextflow -C configs/nextflow.config run process_pathogen.nf -with-report ${work_dir}report/report.html -with-timeline ${work_dir}report/timeline.html -with-trace ${work_dir}report/trace.txt --fasta_file ${fasta_file} --output_dir /raid/gp/Freyja/zika/output --metadata_file ${metadata_file} ${args[3:]}
echo ${args[3@]}