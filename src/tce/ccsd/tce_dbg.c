#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <mpi.h>

#ifdef ENABLE_TPI_DEBUG

static int env_dbg_ga_print = 0;
static int read_env = 0;

static inline void read_tpi_env()
{
    int rank = 0;

    /* only read from environment once */
    if (read_env == 0) {
        char *envval = 0;
        envval = getenv("TPI_DBG_GA_PRINT");
        if (envval && strlen(envval)) {
            env_dbg_ga_print = 1;
        }
    }
    read_env = 1;
}

extern void armci_dbg_set_ga_name(const char *name);
extern void armci_dbg_reset_ga_name();

void tpi_dbg_set_ga_name_(const char *name)
{
    armci_dbg_set_gmr_name(name);
}

void tpi_dbg_reset_ga_name_()
{
    armci_dbg_reset_gmr_name();
}

void tpi_dbg_ga_print_(int *ga, const char *name)
{
    FILE *fp = NULL;
    int rank = -1;

    read_tpi_env();
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (env_dbg_ga_print) {
        fp = fopen(name, "w");
        if (fp != NULL) {
            if (rank == 0)
                printf("TPI print array to %s...", name);
            fflush(stdout);

            GA_Print_file(fp, *ga);

            if (rank == 0)
                printf("done\n");
            fflush(stdout);

            fclose(fp);
        }
    }
}
#else
void tpi_dbg_set_ga_name_(const char *name)
{
    /*do nothing */
}

void tpi_dbg_reset_ga_name_()
{
    /*do nothing */
}

void tpi_dbg_ga_print_(int *ga, const char *name)
{
    /*do nothing */
}
#endif /* ENABLE_TPI_DEBUG */
