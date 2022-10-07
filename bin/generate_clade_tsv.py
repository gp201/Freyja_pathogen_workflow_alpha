#!/usr/bin/env python3

import pandas as pd
import argparse

# extract the strain and lineage columns from the metadata file and create a tsv file with lineage and strain columns.
# this is used to create the lineage to strain mapping file for the matutils step.

# argparse
parser = argparse.ArgumentParser(description='Extract lineage and strain columns from metadata file')
parser.add_argument("-i", "--input", help="Metadata file", required=True)
parser.add_argument("-s", "--strain", help="Strain column name", default='strain')
parser.add_argument("-l", "--lineage", help="Lineage column name", default='lineage')
parser.add_argument("-o", "--output", help="Output file", required=True)
args = parser.parse_args()

if args.input.endswith(".tsv"):
    df = pd.read_csv(args.input, header=0, sep='\t')
elif args.input.endswith(".csv"):
    df = pd.read_csv(args.input, header=0)
# reverse the order of the columns
df = df.loc[:,[args.lineage, args.strain]]
df.to_csv(args.output,index=False,header=False,sep='\t')
