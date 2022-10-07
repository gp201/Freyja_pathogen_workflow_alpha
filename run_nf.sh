#!/bin/bash

args=($@)
work_dir=${args[0]}
fasta_file=${args[1]}
metadata_file=${args[2]}

# chmod +x bin/*
echo "nextflow -C configs/nextflow.config run process_pathogen.nf -with-report ${work_dir}report/report.html -with-dag ${work_dir}report/flowchart.dot -with-timeline ${work_dir}report/timeline.html -with-trace ${work_dir}report/trace.txt --fasta_file ${fasta_file} --work_dir ${work_dir} --metadata_file ${metadata_file} ${@: 4}"
nextflow -C configs/nextflow.config run process_pathogen.nf -with-report ${work_dir}report/report.html -with-dag ${work_dir}report/flowchart.dot -with-timeline ${work_dir}report/timeline.html -with-trace ${work_dir}report/trace.txt --fasta_file ${fasta_file} --work_dir ${work_dir} --metadata_file ${metadata_file} ${@: 4}
