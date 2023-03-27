#!/bin/bash

args=($@)
profile=${args[0]}
work_dir=${args[1]}
fasta_file=${args[2]}
metadata_file=${args[3]}

# chmod +x bin/*
nextflow -C configs/nextflow.config run process_pathogen.nf -profile ${profile} -with-report ${work_dir}report/report.html -with-timeline ${work_dir}report/timeline.html -with-trace ${work_dir}report/trace.txt --fasta_file ${fasta_file} --output_dir ${work_dir}output --metadata_file ${metadata_file} ${args[@]:3}
