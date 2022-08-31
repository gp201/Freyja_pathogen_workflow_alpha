#!/usr/bin/env python3
import pandas as pd
import sys

cluster_file = sys.argv[1]

df = pd.read_csv(cluster_file,sep='\t')

df = df.iloc[:,0:2]
df.iloc[:,0] = ['lineage_' + str(dfi) for dfi in df.iloc[:,0]]
df.to_csv('clade_assignments.tsv',index=False,header=False,sep='\t')
