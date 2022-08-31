#!/usr/bin/env python
# Convert a nexus file to newick format
# Usage: python3 convert_nexus_to_newick.py <input.nex> <output.nwk>

import sys
import argparse
from ete3 import Tree

parser = argparse.ArgumentParser(description='Convert a nexus file to newick format')
parser.add_argument("-i", "--input", help="Nexus file", required=True)
parser.add_argument("-r", "--reformat", help="Reformat using ete3", action="store_true")
parser.add_argument("-o", "--output", help="Newick file", required=True)
args = parser.parse_args()

# Check if dendropy is installed
try:
    import dendropy
except ImportError:
    # If not, install it
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "dendropy"])

import dendropy

# conver nexux to newick format
tree = dendropy.Tree.get_from_path(args.input, "nexus")
tree.write_to_path(args.output, "newick")

if args.reformat:
    # Read newick file as a string and write to newick file
    with open(args.output) as f:
        newick = f.read()

    t = Tree(newick, format=1)
    t.write(format=0, outfile=args.output)
