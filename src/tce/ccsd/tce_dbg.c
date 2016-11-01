#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <mpi.h>

#ifdef ENABLE_TPI_DEBUG
#include <sys/time.h>
#include <unistd.h>

#define TPI_DBG_PRINTF_FILE_PATH_MAXLEN 256
#define TPI_DBG_PRINTF_FILE_MAXLEN 128

static int env_dbg_ga_print = 0;
static int env_dbg_print_file = 0;
static char env_dbg_print_file_path[TPI_DBG_PRINTF_FILE_PATH_MAXLEN];

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
        envval = getenv("TPI_DBG_PRINT_FILE");
        if (envval && strlen(envval)) {
            env_dbg_print_file = 1;
        }
        if(env_dbg_print_file == 1) {
            int rank = -1;
            size_t len = 0;

            memset(env_dbg_print_file_path, 0, sizeof(env_dbg_print_file_path));
            sprintf(env_dbg_print_file_path, "./");

            envval = getenv("TPI_DBG_PRINT_FILE_PATH");
            len = strlen(envval);
            if (envval && len > 0 && len <= TPI_DBG_PRINTF_FILE_PATH_MAXLEN) {
                strncpy(env_dbg_print_file_path, envval, len);
            }

            MPI_Comm_rank(MPI_COMM_WORLD, &rank);
            if (rank == 0) {
                printf("TPI_DBG_PRINT_FILE_PATH=%s\n", env_dbg_print_file_path);
                fflush(stdout);
            }
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

int dbg_print_file_opened = 0;
static FILE *dbg_print_file_fp = NULL;
void tpi_dbg_print_file_init_(const char *suffix)
{
    int rank = 0;
    char fname[TPI_DBG_PRINTF_FILE_PATH_MAXLEN + TPI_DBG_PRINTF_FILE_MAXLEN];
    const char *fnm_tpl = "%s/nwchem_%s_%d.log";

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    read_tpi_env();
    if (env_dbg_print_file) {
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        sprintf(fname, fnm_tpl, env_dbg_print_file_path, suffix, rank);

        dbg_print_file_fp = fopen(fname, "w+");
        if (dbg_print_file_fp == NULL) {
            fprintf(stderr, "TPI debug: cannot open file %s, for rank %d\n.",
                    fname, rank);
            fflush(stderr);
        } else {
            dbg_print_file_opened = 1;
        }
    }
}
void tpi_dbg_print_file_(const char *text)
{
    struct timeval t;

    read_tpi_env();
    if (env_dbg_print_file && dbg_print_file_opened == 1) {
        gettimeofday(&t,NULL);
        fprintf(dbg_print_file_fp, "%d %s\n", t.tv_sec, text);
        fflush(dbg_print_file_fp);
    }
}

void tpi_dbg_print_file_exit_()
{
    if(dbg_print_file_opened == 1) {
        fclose(dbg_print_file_fp);
        dbg_print_file_fp = NULL;
        dbg_print_file_opened = 0;
    }
}

void tpi_dbg_print_(const char *name)
{
    int rank = -1;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if (rank == 0) {
        printf("TPI print: %s\n", name);
        fflush(stdout);
    }
}
void tpi_dbg_print_bcast_(void *buf, const char *name)
{
    int rank = -1;

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if (rank == 0) {
        printf("TPI print: %s: %p\n", name, buf);
    }
    if (buf) {
        MPI_Barrier(MPI_COMM_WORLD);
        MPI_Bcast(buf, 1, MPI_INT, 0, MPI_COMM_WORLD);
        if (rank == 0) {
            printf("after bcast test\n");
        }
    }
}
extern int armci_extern_enable_debug_output;
void tpi_dbg_set_armci_output_(int *flag)
{
    armci_extern_enable_debug_output = (*flag);
}

void tpi_dbg_abort_()
{
    int rank = -1;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if(rank == 0) {
        printf("TPI abort\n");
        fflush(stdout);
    }

    MPI_Abort(MPI_COMM_WORLD, 0);
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
void tpi_dbg_print_file_(const char *text)
{
}
void tpi_dbg_print_file_init_(const char *suffix)
{
}
void tpi_dbg_print_file_exit_()
{
}
void tpi_dbg_print_(const char *name)
{
    /*do nothing */
}
void tpi_dbg_print_bcast_(void *buf, const char *name)
{
    /*do nothing */
}
void tpi_dbg_set_armci_output_(int *flag)
{
    /*do nothing */
}
void tpi_dbg_abort_()
{
}
#endif /* ENABLE_TPI_DEBUG */
