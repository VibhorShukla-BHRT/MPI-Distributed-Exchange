#!/bin/sh
set -eu

# Open MPI launches the remote rank over SSH. This service stays available as
# an SSH host on the private Docker network.
exec /usr/sbin/sshd -D -e
