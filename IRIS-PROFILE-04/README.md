# IRIS-PROFILE-04

## Purpose

Profile the fastest validated Iris configuration before attempting further
HPC tuning.

This experiment does NOT introduce a performance optimization.

The purpose is to collect CPU/cache evidence from the existing 65M
OpenFOAM simpleFoam workload.

## Baseline

Experiment: IRIS-DECOMP-03

- Platform: Iris
- Nodes: 2
- MPI ranks: 112
- Mesh: occDrivAer-65M
- Solver: simpleFoam
- OpenFOAM: v2512
- Decomposition: Scotch
- Iterations: 80
- Average wall-clock time per time step: 10.51625311116456 s
- Cd at iteration 80: 0.33940695876673532

## Profiling Change

Only MPI rank 0 was instrumented using Linux perf stat.

Counters:

- task-clock
- cycles
- instructions
- cache-references
- cache-misses
- branches
- branch-misses

MPI ranks 1-111 ran simpleFoam normally.

No physics, numerical schemes, solver settings, mesh, decomposition,
rank count, or iteration count were intentionally changed.

## Job

- Job ID: 626814
- Nodes: 2
- MPI ranks: 112
- Iterations: 80
- Decomposition: Scotch
- Slurm state: COMPLETED
- Exit code: 0:0
- Slurm elapsed time: 00:14:26

## Solver Result

Average wall-clock time per time step:

10.37815430105064 s

Cd at iteration 80:

0.33940695876673532

The Cd value is identical to IRIS-DECOMP-03.

VALID: YES

The profiled time is NOT treated as a new competition score because
profiling instrumentation was present.

The unprofiled Scotch reference remains:

10.51625311116456 s/time-step

## Rank-0 perf Results

- task-clock: 854406.41 ms
- CPU utilized: 0.993
- cycles: 2715789278204
- instructions: 1916018120534
- IPC: 0.71
- cache-references: 37390641083
- cache-misses: 34770205032
- reported cache-miss ratio: 92.99%
- branches: 315455545989
- branch-misses: 4751534754
- branch-miss ratio: 1.51%
- elapsed time: 860.7144447740 s

## Interpretation

Rank 0 shows relatively low IPC and a very high cache-miss ratio reported
by the generic perf cache events.

This suggests that memory/cache locality may be important and is worth
investigating during later affinity, NUMA, and process-placement tuning.

However, this experiment does NOT prove that simpleFoam is
memory-bandwidth bound.

Important limitations:

1. Only MPI rank 0 was profiled.
2. Generic perf cache events are architecture dependent.
3. MPI/Open MPI/UCX polling can consume CPU cycles while waiting.
4. High CPU utilization therefore does not prove that all measured cycles
   were useful CFD computation.
5. This experiment does not measure communication imbalance across all
   112 MPI ranks.

Branch prediction does not immediately appear to be the dominant issue,
with a measured branch-miss ratio of 1.51% on rank 0.

## Runtime Verification

The runtime evidence confirms:

- nCores = 112
- decompositionMethod = scotch
- nHierarchical = (7 4 4), retained but unused by Scotch
- startFrom = startTime
- startTime = 0
- endTime = 80
- fvSolution exactly matches fvSolution.fixedIter
- the ready-N112-scotch prepared artifact was reused

## Evidence

- scripts/ : profiling Slurm script and rank-0 wrapper
- logs/ : Slurm output, simpleFoam log, and perf output
- results/ : coefficient.dat
- runtime-config/ : actual runtime dictionaries and verification
- config/ : READY artifact identity
- accounting/ : Slurm accounting
- profiling/ : rank-0 perf stat output

## Conclusion

IRIS-PROFILE-04 is a valid profiling experiment.

The numerical result remained unchanged, while rank-0 profiling produced
evidence of low IPC and substantial cache-pressure behavior.

KEEP the profiling evidence.

Do not treat the profiled runtime as a new optimized competition result.
