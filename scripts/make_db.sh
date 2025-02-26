#!/usr/bin/env bash

set -o errexit
set -o pipefail

runno=$1; shift

rm -f config/crs_runs.db ./CRS_*.SQL.json
CRS_query --run "$runno"
for f in ./CRS_*.SQL.json; do
    if [[ -e "$f" ]]; then
        scripts/json2sqlite.py -i "$f" -o config/crs_runs.db
        rm "$f"
    fi
done
rm -rf blobs_CRS
mkdir blobs_CRS
for f in ./CRS_*.json; do
    if [[ -e "$f" ]]; then
        mv CRS_*.json blobs_CRS
    fi
done

start=$(sqlite3 config/morcs.sqlite "select start_time from run_data where id=$runno" | tr ' ' 'T' | cut -c 1-16)
# lol
start_zone_offset=$(scripts/get_zone_offset.py "$start")
start=$start$start_zone_offset

end=$(sqlite3 config/morcs.sqlite "select end_time from run_data where id=$runno" | tr ' ' 'T' | cut -c 1-16)
end_zone_offset=$(scripts/get_zone_offset.py "$end")
end=$end$end_zone_offset

mkdir -p output
rm -f "output/runs_$runno.db"

scripts/test_runsdb.py -o "output/runs_$runno" --run "$runno" --start "$start" --end "$end"

rm -rf blobs_CRS config/crs_runs.db
