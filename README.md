# MPI data exchange between two systems

`mpi_two_systems.c` is a two-process MPI program. MPI rank 0 represents System 1 and MPI rank 1 represents System 2.

1. System 1 sends eight integer readings to System 2.
2. System 2 receives them, computes their total, and sends the result back.
3. System 1 receives and displays the result (`92`).

## Prerequisites

Install an MPI implementation on both systems, such as Open MPI or MPICH. The executable must be available on a shared filesystem, or copy the compiled executable to an identical path on each host.

Both systems also need passwordless SSH (or the launcher-specific equivalent), and their firewalls must permit the MPI implementation's communications.

## Build

```sh
mpicc -Wall -Wextra -O2 -o mpi_two_systems mpi_two_systems.c
```

## Run on one machine (test)

```sh
mpirun -np 2 ./mpi_two_systems
```

## Run across System 1 and System 2

Create a host file named `hosts` containing the two resolvable hostnames or IP addresses:

```text
system1.example.net slots=1
system2.example.net slots=1
```

Then launch one MPI process on each host:

```sh
mpirun --hostfile hosts -np 2 ./mpi_two_systems
```

For MPICH/Hydra, the commonly equivalent command is:

```sh
mpiexec -f hosts -n 2 ./mpi_two_systems
```

The actual machines selected for rank 0 and rank 1 are shown in the output. Keep the host file ordered with System 1 first so rank 0 maps to System 1 and rank 1 maps to System 2.

## Expected output

Hostnames will differ, and lines may appear in a different order:

```text
System 1 (rank 0 on system1): sending 8 readings to System 2.
System 2 (rank 1 on system2): received readings; computed total = 92.
System 1: received total = 92 from System 2.
```
