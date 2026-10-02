#!/bin/bash
set -euo pipefail

if [[ "${OMPI_COMM_WORLD_RANK:-}" == "0" ]]; then
    exec perf record \
        -F 99 \
        -e cycles:u \
        -o logFiles/perf-rank0.data \
        -- simpleFoam -parallel
else
    exec simpleFoam -parallel
fi
