#!/usr/bin/env bash

set -o errexit
set -o pipefail

export HDF5_USE_FILE_LOCKING=FALSE

runno=$1; shift

rm -f config/crs_runs.db-$runno ./CRS_all_ucondb_measurements_run-$runno*.SQL.json
CRS_query --run "$runno"
for f in ./CRS_all_ucondb_measurements_run-$runno*.SQL.json; do
    if [[ ! -e "$f"  ]]; then   # no matching files, so $f is literally ./CRS_all_ucondb_measurements_run-$runno*.SQL.json
        echo "No CRS data for run $runno. Bailing."
        exit 1
    fi
    scripts/json2sqlite.py -i "$f" -o config/crs_runs.db-$runno
    rm "$f"
done

rm -rf blobs_CRS-$runno
mkdir blobs_CRS-$runno
mv ./CRS_all_ucondb_measurements_run-$runno*.json blobs_CRS-$runno

mkdir -p output
rm -f "output/runs_$runno.db"

scripts/test_runsdb.py -o "output/runs_$runno" \
    --run "$runno" --morcs-db config/morcs.sqlite

rm -rf blobs_CRS-$runno config/crs_runs.db-$runno
