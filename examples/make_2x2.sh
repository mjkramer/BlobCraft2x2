#!/usr/bin/env bash

minrun=50000
maxrun=50043

for runno in $(seq $minrun $maxrun); do
    if [[ ! -f output/runs_$runno.db ]]; then
        scripts/make_db.sh "$runno"
    fi
done
