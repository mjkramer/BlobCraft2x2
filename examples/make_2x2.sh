#!/usr/bin/env bash

# ssh -L 8087:acd-daq05-priv:8086 -L 5461:ifdb11.fnal.gov:5461 acdcs@acd-gw05.fnal.gov

outname=mx2x2runs_v0.2_beta1

minrun=50000
maxrun=50043

for runno in $(seq $minrun $maxrun); do
    if [[ ! -f output/runs_$runno.db ]]; then
        scripts/make_db.sh "$runno"
    fi
done

# absorbed into 50005
rm output/runs_50006.db

scripts/merge_sqlite.py "$outname.sqlite" output/runs_*.db

scripts/sqlite2excel.py -o "$outname.xlsx" -i "$outname.sqlite"

scripts/add_path_column.py -i files.2x2.crs_beam.pkl -d "$outname.sqlite" -t CRS_summary -c nersc_path

scripts/add_path_column.py -i files.2x2.lrs_all.pkl -d "$outname.sqlite" -t LRS_summary -c nersc_path
