#!/usr/bin/env python3
from Bio import AlignIO
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import sys

fasta_file = sys.argv[1]

seqs = []
# for record in AlignIO.parse("spikein/pure_consensus/aligned.fasta","fasta"):
alignment = AlignIO.read(open(fasta_file), "fasta")

#confirm all seqs are same length
for record in alignment:
    seqs.append(len(record.seq))

if len(np.unique(seqs))>1:
    print('unequal seq lengths, check aligment.')

def shannon_entropy(list_input):
    """Calculate Shannon's Entropy per column of the alignment (H=-\sum_{i=1}^{M} P_i\,log_2\,P_i)"""

    import math
    unique_base = set(list_input)
    M   =  len(list_input)
    entropy_list = []
    # Number of residues in column
    for base in unique_base:
        n_i = list_input.count(base) # Number of residues of type i
        P_i = n_i/float(M) # n_i(Number of residues of type i) / M(Number of residues in column)
        entropy_i = P_i*(math.log(P_i,2))
        entropy_list.append(entropy_i)

    sh_entropy = -(sum(entropy_list))

    return sh_entropy

def shannon_entropy_list_msa(alignment):
    """Calculate Shannon Entropy across the whole MSA"""

    shannon_entropy_list = []
    for col_no in range(len(list(alignment[0]))):
        list_input = [li for li in list(alignment[:, col_no]) if li != '-' and li != 'N']
        shannon_entropy_list.append(shannon_entropy(list_input))

    return shannon_entropy_list


se = shannon_entropy_list_msa(alignment)
index = range(1,len(alignment[0].seq)+1)
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
fig, ax = plt.subplots()
ax.bar(index,se,color='black',width=20.0)
ax.set_aspect(1000)
ax.set_xlim([0,len(alignment[0].seq)+2])
plt.savefig('entropy.pdf')