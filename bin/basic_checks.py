#!/usr/bin/env python3
# Check if duplicate fasta headers are present in a fasta file
# Check if duplicate fasta headers are present in a metadata file
# Check if the all fasta headers are present in the metadata file

import sys
import pandas as pd

def check_duplicate_fasta_headers(fasta_file):
    fasta_headers = []
    # Read fasta file as a txt file.
    with open(fasta_file, "r") as f:
        fasta_headers = f.read().splitlines()
    fasta_headers = [x[1:] for x in fasta_headers if x.startswith(">")]
    if len(fasta_headers) != len(set(fasta_headers)):
        print("The following fasta headers are duplicated: ", set([x for x in fasta_headers if fasta_headers.count(x) > 1]))
        raise ValueError("Duplicate fasta headers found in the fasta file")
    
def check_duplicate_metadata_headers(metadata):
    if len(metadata.index) != len(set(metadata.index)):
        print("The size of the metadata file is: ", len(metadata.index))
        print("The number of unique headers in the metadata file is: ", len(set(metadata.index)))
        print("The following metadata headers are duplicated: ", set([x for x in metadata.index if list(metadata.index).count(x) > 1]))
        raise ValueError("Duplicate fasta headers found in the metadata file")

def check_metadata_fasta_headers(metadata, fasta_file):
    fasta_headers = []
    # Read fasta file as a txt file.
    with open(fasta_file, "r") as f:
        fasta_headers = f.read().splitlines()
    fasta_headers = [x[1:] for x in fasta_headers if x.startswith(">")]
    for fasta in fasta_headers:
        if fasta not in metadata.index:
            raise ValueError(f"The following fasta headers are not present in the metadata file: {set(fasta_headers) - set(metadata.index)}")

def main():
    fasta_file = sys.argv[1]
    metadata_file = sys.argv[2]
    strain_column = sys.argv[3]
    if metadata_file.endswith(".tsv"):
        metadata = pd.read_csv(metadata_file, header=0, sep='\t')
    elif metadata_file.endswith(".csv"):
        metadata = pd.read_csv(metadata_file, header=0, sep=',')
    # Drop rows with missing value in column 0.
    metadata = metadata.dropna(subset=[metadata.columns[0]])
    # set index to column
    metadata = metadata.set_index(strain_column)
    check_duplicate_fasta_headers(fasta_file)
    check_duplicate_metadata_headers(metadata)
    check_metadata_fasta_headers(metadata, fasta_file)
    print("All checks passed")

if __name__ == "__main__":
    main()