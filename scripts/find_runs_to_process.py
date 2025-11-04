#!/usr/bin/env python3

import sqlite3
import numpy as np
import pandas as pd
import re
import os

def main():
    morcs_db='config/morcs.sqlite'
    # find list of runs from sqlite
    conn = sqlite3.connect(morcs_db)
    df = pd.read_sql_query(f"SELECT * FROM {'run_data'}", conn)
    sqlite_runs = df.id.to_numpy()
    
    # look for runs already processed
    runs_processed = []
    for file in sorted(os.listdir('output')):
        if not file.endswith('.db'):
            continue
        match = re.search(r"runs_(\d+)\.db", file)
        if match:
            runnumber = int(match.group(1))
            runs_processed.append(runnumber)

    # Always reprocess the last processed run, in case of new subruns.
    # FIXME: Use the end_date in morcs.sqlite to avoid this if not
    # needed (first need to get MORCs to write the right end_date)
    if runs_processed:
        runs_processed.pop()

    runs_to_process = sqlite_runs[~np.isin(sqlite_runs, runs_processed)]
    print(f'Need to add the following runs to the DB: {runs_to_process}')
    
    np.savetxt('runs_to_process.txt', runs_to_process, fmt="%d")

if __name__ == '__main__':
    main()
