#!/usr/bin/env python3
# https://github.com/nextstrain/augur/blob/master/augur/refine.py
import sys
from treetime import TreeTime
import treetime
from Bio import Phylo
import pandas as pd
import datetime
import re

tree_file = sys.argv[1]
fasta = sys.argv[2]
dates_file = sys.argv[3]
out_tree = sys.argv[4]
out_fasta = sys.argv[5]
# rtt_plot = sys.argv[6]

def get_numerical_date_from_value(value, fmt=None, min_max_year=None):
    value = str(value)
    if re.match(r'^-*\d+\.\d+$', value):
        # numeric date which can be negative
        return float(value)
    if value.isnumeric():
        # year-only date is ambiguous
        value = fmt.replace('%Y', value).replace('%m', 'XX').replace('%d', 'XX')
    try:
        return treetime.utils.numeric_date(datetime.datetime.strptime(value, fmt))
    except:
        return None


def get_numerical_dates(metadata:pd.DataFrame, date_col='date', fmt=None):
    if fmt:
        strains = metadata.index.values
        dates = metadata[date_col].apply(
            lambda date: get_numerical_date_from_value(
                date,
                fmt
            )
        ).values
    return dict(zip(strains, dates))

tree = Phylo.read(tree_file, 'newick')
dates = get_numerical_dates(pd.read_csv(dates_file, sep='\t').set_index('strain'), fmt="%Y-%m-%d")

tt = TreeTime(tree=tree, aln=fasta, dates=dates)
tt.clock_filter(plot=True)

leaves = [x for x in tt.tree.get_terminals()]
for n in leaves:
    if n.bad_branch:
        tt.tree.prune(n)
        print('pruning leaf ', n.name)
# fix treetime set-up for new tree topology
tt.prepare_tree()
# Filter out seqs in fasta file and tree file

tree_success = Phylo.write(tree, out_tree, 'newick', format_branch_length='%1.8f', branch_length_only=True)
print("updated tree written to", out_tree)
