# IRIS-DECOMP-03 — Hierarchical vs Scotch Decomposition

## Purpose

Test whether changing only the OpenFOAM mesh decomposition method from
hierarchical to Scotch improves simpleFoam performance on the real
65-million-cell occDrivAerStaticMesh case.

Iris is a practice platform. This result is not a competition score.

---

## Baseline

Experiment: IRIS-SCALE-02

Platform: Iris
Nodes: 2
MPI ranks: 112
OpenFOAM: v2512
Mesh: occDrivAerStaticMesh (~65M cells)
Solver: simpleFoam
Iterations: 80

Decomposition method:
hierarchical

nHierarchical:
(7 4 4)

Average wall-clock time per time step:
11.05076184934177 s

Cd at iteration 80:
0.33859083941328877

---

## Experimental Change

Only the decomposition method was intentionally changed:

hierarchical (7 4 4) -> Scotch

The following remained unchanged:

- OpenFOAM v2512
- 65M mesh
- simpleFoam
- 2 nodes
- 112 MPI ranks
- 80 iterations
- fvSchemes
- fvSolution.fixedIter
- controlDict.noWrite
- physics
- preparation chain
- double precision

---

## Preparation

### Step 16.1 — Scotch decomposition

Script:
scripts/16.1-cut-65M-N112-scotch.sbatch

Job:
626590

Operations:
decomposePar -constant
restore0Dir -processor

Result:
PASS

Slurm state:
COMPLETED

Exit code:
0:0

Elapsed:
00:04:55

This elapsed time is preparation time and is NOT the solver performance metric.

---

### Step 16.2 — Parallel initialization

Script:
scripts/16.2-init-65M-N112-scotch.sbatch

Job:
626597

Resources:
2 nodes
112 MPI ranks

Operations:
renumberMesh -constant -overwrite -parallel
potentialFoam -initialiseUBCs -parallel
applyBoundaryLayer -ybl 0.0450244 -parallel

Result:
PASS

Slurm state:
COMPLETED

Exit code:
0:0

Elapsed:
00:00:58

This elapsed time is preparation time and is NOT the solver performance metric.

---

## Timed Solver Run

Script:
scripts/17-simpleFoam-65M-N112-scotch.sbatch

Job:
626598

Resources:
2 nodes
112 MPI ranks

Iterations:
80

Decomposition:
Scotch

Slurm state:
COMPLETED

Exit code:
0:0

Job elapsed:
00:14:33

Official-style solver metric:

Average wall-clock time per time step =
10.51625311116456 s

The Slurm elapsed time is NOT used as the performance metric.

---

## Physical Validation

Final iteration:
80

Cd:
0.33940695876673532

Expected competition sanity value near iteration 80:
~0.34

Hierarchical baseline Cd:
0.33859083941328877

The Scotch result is consistent with the expected physical result.

VALID: YES

---

## Performance Comparison

Hierarchical:
11.05076184934177 s/step

Scotch:
10.51625311116456 s/step

Improvement:
approximately 4.84%

Speedup:
approximately 1.051x

Decision:
KEEP

Scotch is faster than hierarchical for this Iris 2-node / 112-rank test.

The exact cause is not proven by timing alone.
Possible explanations include improved partition balance and/or reduced
MPI communication across partition boundaries.

Profiling is required before attributing the improvement to a specific cause.

---

## Configuration Verification

fvSolution and fvSolution.fixedIter were verified to be identical.

SHA256 for both:

5e1db8548ee82c44f8fa3377a80971af2b5aabb95b3ee7efcd8b723c5dcab1ba

Runtime settings:

nCores = 112
decompositionMethod = scotch
startFrom = startTime
startTime = 0
endTime = 80

READY records:

N=112
method=scotch
mesh=occDrivAer-65M
stages=decomposePar restore0Dir renumberMesh potentialFoam applyBoundaryLayer

---

## Evidence Layout

scripts/
    exact Slurm scripts used

logs/
    job stdout/stderr
    preparation logs
    simpleFoam.log

results/
    coefficient.dat

config/
    prepared configuration
    READY stamp
    configuration verification

runtime-config/
    configuration actually used by solver job 626598
    runtime verification

accounting/
    Slurm sacct proof

---

## Conclusion

On Iris, changing the decomposition method from hierarchical (7 4 4)
to Scotch reduced average simpleFoam wall-clock time per time step from
11.0508 s to 10.5163 s while maintaining a valid Cd near 0.34.

Result: KEEP Scotch as a promising decomposition method for later
machine-specific testing.
