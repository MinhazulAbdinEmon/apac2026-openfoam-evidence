# IRIS-PROFILE-05

## Purpose

Identify the functions consuming CPU cycles on MPI rank 0 of the fastest
validated Iris Scotch configuration.

This is a profiling experiment, NOT a performance optimization.

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

Only MPI rank 0 was sampled with Linux perf:

perf record -F 99 -e cycles:u

MPI ranks 1-111 ran simpleFoam normally.

No mesh, physics, numerical schemes, solver settings, decomposition,
rank count, or iteration count were intentionally changed.

## Job

- Job ID: 626831
- Nodes: 2
- MPI ranks: 112
- Iterations: 80
- Decomposition: Scotch
- Slurm state: COMPLETED
- Exit code: 0:0
- Slurm elapsed time: 00:14:38

## Solver Result

Average wall-clock time per time step:

10.5051697363038 s

Cd at iteration 80:

0.33940695876673532

VALID: YES

The Cd value is identical to IRIS-DECOMP-03.

The profiled runtime is NOT treated as a new competition score.

The unprofiled Scotch reference remains:

10.51625311116456 s/time-step

## perf Sampling

- Event: user-space CPU cycles
- Frequency: 99 Hz
- Samples: approximately 85K
- Lost samples: 0

## Major Rank-0 Hotspots

- Foam::GaussSeidelSmoother::smooth: 18.44%
- Foam::lduMatrix::residual: 11.97%
- __memmove_evex_unaligned_erms: 6.60%
- Foam::lduMatrix::Amul: 6.17%
- Foam::multiply: 3.25%
- Foam::fv::gaussGrad<double>::gradf: 2.23%

The three largest sparse-matrix solver kernels:

- GaussSeidelSmoother::smooth
- lduMatrix::residual
- lduMatrix::Amul

account for approximately 36.58% of rank-0 sampled user-space cycles.

Visible memory copy/set routines:

- memmove: 6.60%
- memset: 1.63%

total approximately 8.23%.

Visible communication/progress routines include:

- uct_mm_iface_progress: 1.96%
- ucc_tl_shm_reduce_read: 1.54%
- uct_dc_mlx5_iface_progress_ll: 1.34%
- opal_progress: 0.88%
- ucp_worker_progress: 0.79%

These visible routines total approximately 6.51% of sampled cycles.

This 6.51% is NOT a measurement of total MPI communication cost.
Other communication/waiting activity may appear elsewhere or below the
report threshold.

## Interpretation

Rank 0 is primarily spending sampled CPU cycles in OpenFOAM sparse
linear-solver operations, with significant memory/data-movement activity.

The results are consistent with the low IPC and high cache-pressure
evidence observed in IRIS-PROFILE-04.

The profile supports investigating the following on the target platform:

1. MPI rank count
2. process placement / CPU affinity
3. NUMA and memory locality
4. MPI/UCX tuning after placement/locality tests

The profile does NOT prove that the entire 112-rank application is
memory-bandwidth bound or that total MPI overhead is only 6.51%.

## Limitations

1. Only MPI rank 0 was sampled.
2. Only user-space cycles were sampled.
3. Results are specific to Iris hardware and software environment.
4. Performance conclusions must be revalidated on Gadi.
5. The profiled runtime is not a competition score.

## Runtime Verification

Evidence confirms:

- nCores = 112
- decompositionMethod = scotch
- nHierarchical = (7 4 4), retained but unused by Scotch
- startFrom = startTime
- startTime = 0
- endTime = 80
- fvSolution exactly matches fvSolution.fixedIter
- ready-N112-scotch artifact was reused

## Evidence

- scripts/ : Slurm script and rank-0 perf-record wrapper
- logs/ : Slurm output, simpleFoam log, hotspot report
- profiling/ : raw perf-rank0.data
- results/ : coefficient.dat
- runtime-config/ : actual runtime dictionaries and verification
- config/ : READY artifact identity
- accounting/ : Slurm accounting

## Conclusion

IRIS-PROFILE-05 is a valid hotspot-profiling experiment.

Rank 0 is dominated mainly by OpenFOAM sparse matrix / linear-solver work
and memory/data movement, with a smaller but meaningful visible
communication/progress component.

KEEP the profiling evidence.

Stop Iris optimization after this experiment and revalidate optimization
choices on Gadi.
