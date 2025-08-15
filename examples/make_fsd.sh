#!/usr/bin/env bash

minrun=20002
maxrun=20198

for runno in $(seq $minrun $maxrun); do
    if [[ ! -f output/runs_$runno.db ]]; then
        scripts/make_db.sh "$runno"
    fi
done
