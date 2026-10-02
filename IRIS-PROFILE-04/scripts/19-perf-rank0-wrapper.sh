#!/bin/bash
set -euo pipefail

if [[ "${OMPI_COMM_WORLD_RANK:-}" == "0" ]]; then
    exec perf stat \
        -o logFiles/perf-rank0.stat \
        -e task-clock,cycles,instructions,cache-references,cache-misses,branches,branch-misses \
        -- simpleFoam -parallel
else
    exec simpleFoam -parallel
fi
