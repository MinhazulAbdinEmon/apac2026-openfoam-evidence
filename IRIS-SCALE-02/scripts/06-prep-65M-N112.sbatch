#!/bin/bash
# 65M flags follow official Allrun (not its 512-rank / 4000-step example):
# https://develop.openfoam.com/committees/hpc/-/blob/develop/incompressible/simpleFoam/occDrivAerStaticMesh/Allrun
# Touch: 65M case. One mesh, one split, five prep stages. You do not mesh.
# Not a score. This job does not run the solver.
# Pass = READY stamp after applyBoundaryLayer.
# Same folder as 06.1 then 06.2. This file is those five stages in one job.
#SBATCH -J of-prep-n112
#SBATCH -p iris
#SBATCH -N 2
#SBATCH -n 112
#SBATCH -t 00:50:00
#SBATCH -o runs/%j.out
#SBATCH -e runs/%j.err
set -euo pipefail

SHARED=/global/exafs/groups/rdmaworkshop/2026hpcai-openfoam
BUILD="$SHARED/builds/iris-gcc11-hpcx250-opt"
BASHRC="$BUILD/OpenFOAM-v2512/etc/bashrc"
CASE_SRC="$SHARED/occDrivAer/case"
MESH_SRC="$SHARED/occDrivAer/polyMesh"
ROOT="${SLURM_SUBMIT_DIR:?}"
WORK="$(cd "$ROOT/.." && pwd)"
RANKS=${SLURM_NTASKS:?}
# This path is the N112 hierarchical split only. Another method or factors needs another directory.
ART="$WORK/artifacts/ready-N112-h744"
mkdir -p "$ROOT/runs"

echo "[$(date -Iseconds)] job=${SLURM_JOB_ID} WORK=$WORK ranks=$RANKS"
test -d "$MESH_SRC"
test -r "$BASHRC"

# This cut is already here. Do not recut.
[[ -f "$ART/READY" ]] && { echo "This cut is already here: $ART"; cat "$ART/READY"; echo "06-prep-65M-N112: PASS"; exit 0; }
[[ -e "$ART" ]] && rm -rf "$ART"
mkdir -p "$ART"

module load gcc/11
module load hpcx/2.50
export FOAM_CONFIG_MODE=o
# OpenFOAM etc/bashrc uses unbound vars and `return 1` for missing optional paths.
set +euo pipefail
# shellcheck disable=SC1090
source "$BASHRC"
set -euo pipefail
[[ -n "${FOAM_APPBIN:-}" ]]
set +u
# shellcheck disable=SC1091
source "${WM_PROJECT_DIR:?}/bin/tools/RunFunctions"
set -u

cp -a "$CASE_SRC/." "$ART/"
chmod -R u+w "$ART"
# Working copy only. Group occDrivAer/case stays as shipped.
rm -f "$ART/Allrun" "$ART/Allmesh"
rm -rf "$ART/constant/polyMesh"
# Group polyMesh stays put. This folder only links it.
ln -sfn "$MESH_SRC" "$ART/constant/polyMesh"
cd "$ART"
cp system/controlDict.noWrite system/controlDict
cp system/fvSolution.fixedIter system/fvSolution
# nCores must equal #SBATCH -n.
sed -i "s/^nCores .*/nCores              $RANKS;/" system/include/caseDefinition
# h744 is nHierarchical (7 4 4), not a hash. 7*4*4=112.
sed -i 's/^nHierarchical .*/nHierarchical       (7 4 4);/' system/include/caseDefinition
mkdir -p logFiles

# In: serial constant/polyMesh. Out: processor0 .. processor111 (xyz slabs).
decomposePar -constant > logFiles/decomposePar.log 2>&1
# Out: processor*/0/ from 0.orig/.
restore0Dir -processor > logFiles/restore0Dir.log 2>&1
# `--` ends Open MPI 5 options. `-parallel` makes OpenFOAM read processor*.
# Out: overwrite processor*/constant/polyMesh (reorder cells).
mpirun -np "$RANKS" -- renumberMesh -constant -overwrite -parallel > logFiles/renumberMesh.log 2>&1
# Out: processor*/0/U.
mpirun -np "$RANKS" -- potentialFoam -initialiseUBCs -parallel > logFiles/potentialFoam.log 2>&1
# Out: processor*/0/ with a boundary layer. -ybl 0.0450244 is Allrun's value; do not change it.
mpirun -np "$RANKS" -- applyBoundaryLayer -ybl 0.0450244 -parallel > logFiles/applyBoundaryLayer.log 2>&1

# 112 ranks: processor0 and processor111 must both exist.
test -d processor0
test -d processor111

# Stamp so the next job checks this folder first and refuses the wrong cut.
# The cut is still the processor* folders.
cat > "$ART/READY" <<'EOF'
N=112
method=hierarchical
nHierarchical=(7 4 4)
mesh=occDrivAer-65M
stages=decomposePar restore0Dir renumberMesh potentialFoam applyBoundaryLayer
EOF

echo "06-prep-65M-N112: PASS"
