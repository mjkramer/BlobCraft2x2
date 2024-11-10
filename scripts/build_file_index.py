#!/usr/bin/env python3

import argparse
from pathlib import Path
import pickle


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-p', '--path',
                    help='Path to scan',
                    required=True, type=Path)
    ap.add_argument('-e', '--ext',
                    help='File extension (e.g.: h5, hdf5, data)',
                    required=True)
    ap.add_argument('-o', '--output',
                    help='Pickle file in which to save the index dict',
                    required=True, type=Path)
    args = ap.parse_args()

    result = {}

    for p in args.path.rglob(f'*.{args.ext}'):
        result[p.name] = str(p)

    with open(args.output, 'wb') as f:
        pickle.dump(result, f)


if __name__ == '__main__':
    main()
