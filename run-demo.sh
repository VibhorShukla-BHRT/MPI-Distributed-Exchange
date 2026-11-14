#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir"

mkdir -p results
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
log_file="results/run-${timestamp}.log"

cleanup() {
  docker compose down --remove-orphans >>"$log_file" 2>&1 || true
}
trap cleanup EXIT

{
  echo "MPI Docker demo"
  echo "Started (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Docker: $(docker version --format '{{.Server.Version}}')"
  echo
  docker compose up --build --detach
  echo
  echo "Launching one MPI rank on each service:"
  docker compose exec -T system1 su - mpi -c \
    'mpirun --host system1:1,system2:1 --map-by ppr:1:node -np 2 \
    --mca plm_rsh_agent "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    /opt/mpi/mpi_two_systems'
  echo
  echo "Finished (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)"
} 2>&1 | tee "$log_file"

echo "Saved result: $log_file"
