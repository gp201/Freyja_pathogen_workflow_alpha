#!/bin/bash
# Run this in the docker container.

# # Install python2 and pip2
# cd /
# apt-get update
# apt-get install -y python2.7
# wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
# python2 get-pip.py
# rm get-pip.py

# # Install Phyclip
# ## Install Phyclip
# mkdir /phyclip
# cd /phyclip
# wget https://github.com/alvinxhan/PhyCLIP/archive/refs/tags/2.1.tar.gz
# tar xf 2.1.tar.gz
# cd PhyCLIP-2.1
# pip install numpy scipy Cython ete3 matplotlib gurobipy
# pip install statsmodels==0.10.2
# pip install --upgrade pip setuptools wheel
# python2 setup.py install

# Setup conda
conda init
source ~/.bashrc

# Install via CONDA
## Install Usher
cd /
yes | conda create -n usher
conda activate usher
conda config --add channels bioconda
conda config --add channels conda-forge
yes| conda install -c bioconda usher

## Install Phyclip
yes | conda create -n phyclip python=2.7
yes | conda install -c etetoolkit ete3 ete_toolchain
yes | conda install -c conda-forge cython
yes | conda install -c conda-forge numpy scipy statsmodels
conda config --add channels http://conda.anaconda.org/gurobi
yes| conda install gurobi
wget https://github.com/alvinxhan/PhyCLIP/archive/refs/tags/2.1.tar.gz
tar xf 2.1.tar.gz
cd PhyCLIP-2.1
python2 setup install

# Install Augur
yes | conda create -n augur
conda activate augur
yes| conda install -c conda-forge -c bioconda augur
