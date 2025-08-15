#!/usr/bin/env python3

import argparse
import pickle
import sqlite3


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i', '--index-file',
                    help='pickle file with index of file paths',
                    required=True)
    ap.add_argument('-d', '--db-file',
                    help='sqlite file to update',
                    required=True)
    ap.add_argument('-t', '--table',
                    help='table to update',
                    required=True)
    ap.add_argument('-c', '--column',
                    help='name of column to contain path',
                    default='nersc_path')
    args = ap.parse_args()

    with open(args.index_file, 'rb') as f:
        path_index: dict[str, str] = pickle.load(f)

    conn = sqlite3.connect(args.db_file)

    q = f"ALTER TABLE {args.table} ADD COLUMN {args.column} TEXT"
    try:
        conn.execute(q)
    except sqlite3.OperationalError:
        # hopefully we're here because the table already exists
        pass

    q = f"SELECT run, subrun, filename FROM {args.table}"
    for run, subrun, filename in conn.execute(q).fetchall():
        if filename not in path_index:
            print(f'Cannot find {filename}')
            continue

        path = path_index[filename]

        # it's faster to use run and subrun in the WHERE instead of using
        # filename because (run, subrun) is the primary key
        q = f"UPDATE {args.table} SET {args.column}='{path}'" + \
            f" WHERE run={run} AND subrun={subrun}"
        conn.execute(q)

    conn.commit()
    conn.close()


if __name__ == '__main__':
    main()
