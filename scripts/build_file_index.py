#!/usr/bin/env python3

import argparse
from pathlib import Path
import pickle


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-p', '--path',
                    help='Path to scan',
                    required=True)
    ap.add_argument('-e', '--ext',
                    help='File extension (e.g.: h5, hdf5, data)',
                    required=True)
    ap.add_argument('-o', '--output',
                    help='Pickle file in which to save the index dict',
                    required=True)
    ap.add_argument('-b', '--binary2packet',
                    help='convert charge paths from binary to packet',
                    action='store_true')
    ap.add_argument('-B', '--binary-dir',
                    default='/global/cfs/cdirs/dune/www/data/FSD/CRS/CRS')
    ap.add_argument('-P', '--packet-dir',
                    default='/global/cfs/cdirs/dune/www/data/FSD/nearline/packet/CRS')
    args = ap.parse_args()

    result = {}

    for p in Path(args.path).rglob(f'*.{args.ext}'):
        name = p.name
        if args.binary2packet:
            p = Path(args.packet_dir) / p.relative_to(args.binary_dir)
            if p.name.startswith('binary-'):
                p = p.parent / p.name.replace('binary-', 'packet-', 1)
        result[name] = str(p)

    with open(args.output, 'wb') as f:
        pickle.dump(result, f)


if __name__ == '__main__':
    main()
