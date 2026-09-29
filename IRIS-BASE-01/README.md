# IRIS-BASE-01

## Purpose
Establish the first real 65M-cell OpenFOAM baseline on Iris.

This is a PRACTICE result only. Iris timing is not the final competition score.

## Configuration
Platform: Iris
OpenFOAM: v2512
Case: occDrivAerStaticMesh
Mesh: approximately 65 million cells
Solver: simpleFoam
Nodes: 1
MPI ranks: 56
Decomposition method: hierarchical
nHierarchical: (7 4 2)
Iterations: 40

7 x 4 x 2 = 56 subdomains.

## Preparation
Prep script: 03-prep-65M-N56.sbatch
Prep job ID: 626242
Prep status: COMPLETED
Prep ExitCode: 0:0
Prep elapsed: 00:04:12

Preparation stages:
- decomposePar
- restore0Dir
- renumberMesh
- potentialFoam
- applyBoundaryLayer

Prepared artifact:
../artifacts/ready-N56-h742/

## Solver Run
Solver script: 04-simpleFoam-65M-N56.sbatch
Solver job ID: 626267
Status: COMPLETED / PASS
ExitCode: 0:0
Total Slurm elapsed: 00:14:55

IMPORTANT:
Total Slurm elapsed is not the performance metric.

## Performance Result
Average wall-clock time per time step:
21.27342698120513 s/step

Rounded:
21.2734 s/step

Lower is better.

## CFD Validation
Final iteration: 40

Cd:
0.44055438144779518

Rounded:
0.44055

Validation status:
PASS / reasonable for the 40-step sanity check.

## Decision
KEEP as the initial Iris baseline.

This experiment is the reference point for later Iris scaling and optimization experiments.

## Evidence Files
scripts/
- 03-prep-65M-N56.sbatch
- 04-simpleFoam-65M-N56.sbatch

logs/
- 626242.out
- 626267.out
- simpleFoam.log

results/
- coefficient.dat

config/
- READY
- caseDefinition
- controlDict
- controlDict.noWrite
- fvSolution
- fvSolution.fixedIter

accounting/
- sacct.txt
