#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

enum {
    SYSTEM_1_RANK = 0,
    SYSTEM_2_RANK = 1,
    DATA_TAG = 100,
    RESULT_TAG = 101,
    VALUE_COUNT = 8
};

int main(int argc, char *argv[]) {
    int rank, process_count, name_length;
    char processor_name[MPI_MAX_PROCESSOR_NAME];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &process_count);
    MPI_Get_processor_name(processor_name, &name_length);

    if (process_count != 2) {
        if (rank == SYSTEM_1_RANK) {
            fprintf(stderr, "Run this program with exactly two MPI processes.\n");
        }
        MPI_Abort(MPI_COMM_WORLD, EXIT_FAILURE);
        return EXIT_FAILURE;
    }

    if (rank == SYSTEM_1_RANK) {
        int readings[VALUE_COUNT] = {12, 8, 21, 5, 16, 9, 14, 7};
        int total;

        printf("System 1 (rank %d on %s): sending %d readings to System 2.\n",
               rank, processor_name, VALUE_COUNT);
        fflush(stdout);

        MPI_Send(readings, VALUE_COUNT, MPI_INT, SYSTEM_2_RANK, DATA_TAG,
                 MPI_COMM_WORLD);
        MPI_Recv(&total, 1, MPI_INT, SYSTEM_2_RANK, RESULT_TAG,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        printf("System 1: received total = %d from System 2.\n", total);
    } else { /* System 2 */
        int readings[VALUE_COUNT];
        int total = 0;

        MPI_Recv(readings, VALUE_COUNT, MPI_INT, SYSTEM_1_RANK, DATA_TAG,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        for (int i = 0; i < VALUE_COUNT; ++i) {
            total += readings[i];
        }

        printf("System 2 (rank %d on %s): received readings; computed total = %d.\n",
               rank, processor_name, total);
        fflush(stdout);

        MPI_Send(&total, 1, MPI_INT, SYSTEM_1_RANK, RESULT_TAG,
                 MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return EXIT_SUCCESS;
}
