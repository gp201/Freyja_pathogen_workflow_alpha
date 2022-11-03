# Freyja Pathogen Workflow

This is a workflow for the Freyja Pathogen pipeline. It is designed to be run using docker.


## Installation
1. Install the following software:
    - [Conda](https://docs.conda.io/en/latest/miniconda.html)
    - Install outside conda environment:
        - [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)
        - [TreeTime](https://treetime.readthedocs.io/en/latest/installation.html)
        - [MAFFT](https://mafft.cbrc.jp/alignment/software/)
    - Install inside conda environment:
        - [usher]()
        - [augur]()
        - [PhyCLIP]()
    > **Note**  
    > [setup.sh](/setup.sh) installs all the **conda** packages listed above.  
    > It is recommended to run this script to install all the required packages.  
    > If you want to install the packages run `bash setup.sh`.
2. Clone this repository.
    - `git clone https://github.com/gp201/Freyja_pathogen_workflow.git`
3. Enter the cloned repository.
    - `cd Freyja_pathogen_workflow`
4. Make the python scripts executable.
    - `chmod +x bin/*`
4. Run the nextflow pipeline
    - `nextflow -C configs/nextflow.config run process_pathogen.nf`
    - Modify the [nextflow.config](/configs/nextflow.config) file to change the parameters of the pipeline.
> **Warning**
> Edit conda env location in the `nextflow.config` file.

## Installation
1. Clone this repository
2. Install docker
3. Run `bash start_docker.sh {mount_loc}` to start the docker container.
    - `{mount_loc}` is the location of the directory you want to mount to the docker container. This is where the input and output files will be stored.
4. Run `bash setup.sh` to install the necessary packages.
> **Warning**
> The [PhyCLIP](https://github.com/alvinxhan/PhyCLIP) package requires Gurobi
> to be installed. You will require a license **(Cannot be used in a docker container)** to use Gurobi. You will need to get a special license for docker containers.
5. Run `bash run_nf.sh` to run the pipeline. The following steps will run:

> **Note**
> Edit the `nextflow.config` file to change the parameters for the pipeline.