# IRIS-SCALE-02

## Purpose
Test strong scaling of the same 65M-cell OpenFOAM case from 1 Iris node to 2 Iris nodes.

This is a PRACTICE result only. Iris timing is not the final competition score.

## Baseline
Experiment: IRIS-BASE-01
Nodes: 1
MPI ranks: 56
Decomposition method: hierarchical
nHierarchical: (7 4 2)
Iterations: 40
Average wall-clock time per time step: 21.2734 s/step
Cd at iteration 40: 0.44055

## Change
Nodes: 1 -> 2
MPI ranks: 56 -> 112
nHierarchical: (7 4 2) -> (7 4 4)
Iterations: 40 -> 80

The same OpenFOAM v2512 case, 65M mesh, simpleFoam solver,
fvSchemes, fvSolution.fixedIter, and physics were retained.

## Configuration
Platform: Iris
OpenFOAM: v2512
Case: occDrivAerStaticMesh
Mesh: approximately 65 million cells
Solver: simpleFoam
Nodes: 2
MPI ranks: 112
Decomposition method: hierarchical
nHierarchical: (7 4 4)
Iterations: 80

7 x 4 x 4 = 112 subdomains.

## Preparation
Prep script: 06-prep-65M-N112.sbatch
Prep job ID: 626316
Prep status: COMPLETED / PASS
Prep ExitCode: 0:0
Prep elapsed: 00:03:59

Preparation stages:
- decomposePar
- restore0Dir
- renumberMesh
- potentialFoam
- applyBoundaryLayer

Prepared artifact:
../artifacts/ready-N112-h744/

## Solver Run
Solver script: 07-simpleFoam-65M-N112.sbatch
Solver job ID: 626341
Status: COMPLETED / PASS
ExitCode: 0:0
Total Slurm elapsed: 00:15:21

IMPORTANT:
Total Slurm elapsed is not the performance metric.

## Performance Result
Average wall-clock time per time step:
11.05076184934177 s/step

Rounded:
11.0508 s/step

Baseline:
21.2734 s/step

Time-per-step reduction:
48.05%

Speedup:
1.925x

Parallel efficiency relative to ideal 2x scaling:
96.25%

## CFD Validation
Final iteration: 80

Cd:
0.33859083941328877

Rounded:
0.33859

Validation status:
PASS / reasonable for the 80-step sanity check.

## Interpretation
Doubling the MPI resources reduced the amount of mesh work handled
by each rank. Communication overhead remained relatively small,
giving strong scaling close to the ideal 2x speedup.

## Decision
KEEP.

The 2-node hierarchical configuration showed strong scaling compared
with IRIS-BASE-01.

## Evidence Files
scripts/
- 06-prep-65M-N112.sbatch
- 07-simpleFoam-65M-N112.sbatch

logs/
- 626316.out
- 626341.out
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
