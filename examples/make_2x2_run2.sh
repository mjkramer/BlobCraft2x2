#!/usr/bin/env bash

outname=2x2runs_run2_v0.0.0.1

minrun=60000
maxrun=60070

ln -sf configs/2x2_run2 config
cp /global/cfs/cdirs/dune/www/data/2x2/LRS_det_config_run2/lrsdetconfig.db config/
scp acd-daq02.fnal.gov:/data/morcs/MORCS/morcs.sqlite config/

scripts/build_file_index.py -o config/files.2x2_run2.crs.pkl \
    --binary2packet --ext h5 \
    --path /global/cfs/cdirs/dune/www/data/2x2/CRS.run2/ColdOperations/data/2025_Operations_Cold \
    --packet-dir /global/cfs/cdirs/dune/www/data/2x2/nearline_run2/packet/ColdOperations/data/2025_Operations_Cold

scripts/build_file_index.py -o config/files.2x2_run2.lrs.pkl \
    --ext data \
    --path /global/cfs/cdirs/dune/www/data/2x2/LRS_run2

seq $minrun $maxrun | parallel -u -j 10 scripts/make_db.sh

scripts/merge_sqlite.py "$outname.sqlite" output/runs_*.db

scripts/add_path_column.py -i config/files.2x2_run2.crs.pkl -d "$outname.sqlite" -t CRS_summary -c nersc_path
scripts/add_path_column.py -i config/files.2x2_run2.lrs.pkl -d "$outname.sqlite" -t LRS_summary -c nersc_path

scripts/sqlite2excel.py -o "$outname.xlsx" -i "$outname.sqlite"
