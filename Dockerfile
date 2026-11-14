FROM ubuntu:24.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        openssh-client \
        openssh-server \
        openmpi-bin \
        libopenmpi-dev \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash mpi \
    && mkdir -p /run/sshd /home/mpi/.ssh \
    && ssh-keygen -q -t ed25519 -N '' -f /home/mpi/.ssh/id_ed25519 \
    && cp /home/mpi/.ssh/id_ed25519.pub /home/mpi/.ssh/authorized_keys \
    && chmod 700 /home/mpi/.ssh \
    && chmod 600 /home/mpi/.ssh/authorized_keys /home/mpi/.ssh/id_ed25519 \
    && chown -R mpi:mpi /home/mpi/.ssh

COPY mpi_two_systems.c /opt/mpi/mpi_two_systems.c
RUN mpicc -Wall -Wextra -O2 -o /opt/mpi/mpi_two_systems /opt/mpi/mpi_two_systems.c \
    && chmod 755 /opt/mpi/mpi_two_systems

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
