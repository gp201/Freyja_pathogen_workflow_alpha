FROM ubuntu:20.04

RUN apt update &&\
    DEBIAN_FRONTEND=noninteractive &&\
    apt-get install -y software-properties-common &&\
    apt update &&\
    apt install -y yes wget rsync git-all python2 python3 python3-pip python-dev python3-dev parallel r-base default-jre-headless default-jdk ant locales &&\
    apt clean

# Moduify based on the python packages that have to be installed.
RUN pip install --no-input numpy scipy matplotlib pandas biopython baltic tqdm unidecode pyyaml phylo-treetime

# Install MAFFT
RUN wget https://mafft.cbrc.jp/alignment/software/mafft_7.490-1_amd64.deb && dpkg -i mafft_7.490-1_amd64.deb

# Install IQ-TREE
RUN wget https://github.com/iqtree/iqtree2/releases/download/v2.1.3/iqtree-2.1.3-Linux.tar.gz && \
    tar xf iqtree-2.1.3-Linux.tar.gz
ENV PATH="/iqtree-2.1.3-Linux/bin:${PATH}"

# Install Nextflow
RUN mkdir nextflow &&\
    cd nextflow &&\
    wget -qO- https://get.nextflow.io | bash &&\
    chmod +x nextflow

ENV PATH="/nextflow:${PATH}"

# Install python2
# RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
# RUN tar -xvf Python-2.7.18.tgz
# RUN cd Python-2.7.18 && ./configure --enable-optimizations --with-ensurepip=install && make -j 8 && make altinstall
# Install PhyCLIP 2.1
# RUN add-apt-repository ppa:rock-core/qt4
# RUN apt install -y python-numpy python-lxml python-six
# RUN apt install python-qt4
# RUN pip install --no-input Cython ete3 statsmodels numpy scipy matplotlib
# RUN mkdir phyclip &&\
#     cd phyclip &&\
#     wget https://github.com/alvinxhan/PhyCLIP/archive/refs/tags/2.1.tar.gz &&\
#     tar xf 2.1.tar.gz &&\
#     cd PhyCLIP-2.1 &&\
#     python2 setup.py install

# TODO-gp: Setup conda environment and install usher and Phyclip
# COPY ./conda/Anaconda3-2022.05-Linux-x86_64.sh /
# ENV CONDA_DIR /opt/conda
# RUN bash Anaconda3-2022.05-Linux-x86_64.sh -b -p /opt/conda
# ENV PATH=$CONDA_DIR/bin:$PATH

# Install miniconda
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh &&\
    bash Mambaforge-Linux-x86_64.sh -b -p /opt/conda
ENV PATH=/opt/conda/bin:$PATH

# RUN conda init &&\
#     source ~/opt/conda/etc/profile.d/conda.sh
# RUN conda config --show channels
# RUN conda config --remove channels defaults
# RUN conda config --add channels bioconda
# RUN conda config --add channels conda-forge
# RUN conda config --set channel_priority strict


# Install usher
# RUN yes | conda create -n usher
# RUN source ~/opt/conda/etc/profile.d/conda.sh &&\
#     conda activate usher &&\
#     conda config --add channels bioconda &&\
#     conda config --add channels conda-forge &&\
#     yes| conda install usher


# # Install phyclip
# RUN yes | conda create -n phyclip python=2.7
# RUN conda activate phyclip &&\
#     conda install -c etetoolkit ete3 &&\
#     conda install -c conda-forge cython &&\
#     conda install numpy scipy statsmodels &&\
#     conda config --add channels http://conda.anaconda.org/gurobi &&\
#     conda install gurobi &&\
#     wget https://github.com/alvinxhan/PhyCLIP/archive/refs/tags/2.1.tar.gz &&\
#     tar xf 2.1.tar.gz &&\
#     cd PhyCLIP-2.1 &&\
#     python setup.py install

# # Install fatovcf
RUN mkdir faToVcf &&\
    cd faToVcf &&\
    rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/faToVcf . &&\
    chmod +x faToVcf
ENV PATH="/faToVcf:${PATH}"

# Set locale for ant
ENV LC_ALL "en_US.UTF-8"
ENV LC_CTYPE "en_US.UTF-8"
RUN locale-gen en_US.utf8

WORKDIR /workflow/