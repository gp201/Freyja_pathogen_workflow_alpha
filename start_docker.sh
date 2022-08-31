#!/bin/bash

# Ensure that the mount_loc contains the fasta file you want to process.
# Warning: this will create a new continer everytime it is executed.
args=($@)
mount_loc=${args[0]}

cwd=$(pwd)

# Build Docker
docker build . -t freyja_pathogen_workflow

# Start docker
docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${mount_loc}:/data -v ${cwd}:/workflow -it freyja_pathogen_workflow /bin/bash
