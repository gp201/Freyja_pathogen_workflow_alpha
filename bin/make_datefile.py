#!/usr/bin/env python3
from Bio import SeqIO
import pandas as pd 
import sys

fasta_file = sys.argv[1]
metadata_file = sys.argv[2]


df = pd.read_csv('nextstrain_zika_metadata.tsv',sep='\t')
df = df.set_index('accession',drop=False)
with open("zika_aligned.fasta") as input_handle:
    for record in SeqIO.parse(input_handle, "fasta"):
        print(record.id)
        df.loc[record.id.split('.')[0],'name'] = record.id

df2 = df[['name','date']]
df2['date'] = df2['date'].apply(lambda x:x.split(' ')[0])
df2.to_csv('zika_dates.csv',index=False)