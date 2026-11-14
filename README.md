# MPI data exchange between two systems

## Academic Details:
Student name: Vibhor Shukla</br>
Roll Number: 23115107</br>
Programme: CSE, Semester 7</br>
Institute: NIT Raipur</br>
Subject: Distributed System

## 1. Assignment objective

This project demonstrates data exchange between two computer systems using the
Message Passing Interface (MPI). It launches exactly two MPI processes:

- **System 1** is MPI rank `0`. It sends eight integer readings to System 2.
- **System 2** is MPI rank `1`. It receives the readings, calculates their
  total, and sends that total back to System 1.

The expected total is **92**.

The Docker implementation simulates the systems with two containers named
`system1` and `system2`. Each container has its own hostname and network
interface. MPI rank 0 is launched on `system1`; rank 1 is launched on
`system2`.

## 2. Folder Tree

```text
mpi-two-systems/
├── mpi_two_systems.c           # Complete MPI source code
├── Dockerfile                  # Installs Open MPI and SSH in the demo image
├── compose.yaml                # Defines the system1 and system2 containers
├── run-demo.sh                 # Builds, runs, logs, and cleans up the test
├── docker/entrypoint.sh        # Starts SSH for Open MPI remote launching
├── results/
│   ├── execution-summary.txt   # Verified execution transcript
│   └── run-*.log               # Full log created by each test run
└── screenshots/
    ├── 01-source-code.png      # Source-code capture
    └── 02-execution-result.png # Successful execution capture
```

## 3. How the program works

1. `MPI_Init` starts MPI in both processes.
2. `MPI_Comm_rank` assigns each process a rank; rank 0 is System 1 and rank 1
   is System 2.
3. System 1 calls `MPI_Send` with eight values, destination rank `1`, and
   message tag `100`.
4. System 2 calls `MPI_Recv` with the matching source, type, and tag. It adds
   the eight received values.
5. System 2 calls `MPI_Send` to return the total, using tag `101`.
6. System 1 calls `MPI_Recv` and displays the total.
7. Both processes call `MPI_Finalize`.

The program stops with an error if it is not launched with exactly two MPI
processes.

## 4. Requirements

### Docker demonstration (recommended)

- Docker Engine or Docker Desktop running
- Docker Compose v2 (`docker compose version`)
- Internet access on the first run so Docker can download Ubuntu packages

Check the installation:

```sh
docker --version
docker compose version
docker info
```

If `docker info` reports permission denied on Linux, add your account to the
`docker` group or use your administrator-approved Docker setup, then open a
new terminal session.

### Native MPI alternative

For two physical computers instead of containers, install Open MPI or MPICH on
both systems. The systems must resolve each other's hostnames and allow the
MPI launcher's SSH connections.

## 5. Run the Docker demonstration

Open a terminal and run:

```sh
cd ~/Desktop/mpi-two-systems
chmod +x run-demo.sh
./run-demo.sh
```

What the script does:

1. Builds an Ubuntu image containing Open MPI, the compiled program, and SSH.
2. Starts `system1` and `system2` on a private Docker network.
3. Runs one MPI rank on each container.
4. Saves the entire terminal output to `results/run-<UTC timestamp>.log`.
5. Stops and removes the containers and private network.

The first run can take a few minutes while MPI packages are downloaded. Later
runs use Docker's build cache and finish much faster.

## 6. Verify the result

The output must contain all of these facts (their line order can vary because
the processes run concurrently):

```text
System 1 (rank 0 on system1): sending 8 readings to System 2.
System 2 (rank 1 on system2): received readings; computed total = 92.
System 1: received total = 92 from System 2.
```

Open the newest log after a run:

```sh
ls -t results/run-*.log | head -n 1
```

For a quick automated pass/fail check:

```sh
latest_log=$(ls -t results/run-*.log | head -n 1)
grep -q "received total = 92" "$latest_log" && echo "PASS" || echo "FAIL"
```

## 7. Clock-skew demonstration

Containers share the host kernel, so this project deliberately **does not**
attempt to alter the real computer clock. Instead, the source prints safe
application-level timestamps with a simulated offset:

- System 1: UTC−5 minutes
- System 2: UTC+3 minutes

This makes the distributed-systems lesson visible: messages can be exchanged
correctly even while the two systems' displayed timestamps disagree. It also
shows why distributed logs should not be ordered solely by wall-clock time.

## 8. Test result recorded for this submission

The Docker test was run successfully with Docker Engine `29.7.1` and Open MPI
from Ubuntu 24.04. Rank 0 ran on `system1`, rank 1 ran on `system2`, and
System 1 received the expected total of `92`. See
`results/execution-summary.txt`, the full timestamped log, and the two PNG
screenshots in `screenshots/`.

## 9. Run on two physical computers (optional)

On a machine where MPI is installed, compile the source:

```sh
mpicc -Wall -Wextra -O2 -o mpi_two_systems mpi_two_systems.c
```

Create `hosts` with the two reachable machine names, keeping System 1 first:

```text
system1.example.net slots=1
system2.example.net slots=1
```

Launch one rank per system:

```sh
mpirun --hostfile hosts -np 2 ./mpi_two_systems
```

For MPICH/Hydra, the equivalent form is commonly:

```sh
mpiexec -f hosts -n 2 ./mpi_two_systems
```

## 10. Cleanup

`run-demo.sh` cleans up automatically. If a run is interrupted, clean up with:

```sh
docker compose down --remove-orphans
```
