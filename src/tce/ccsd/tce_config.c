#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <mpi.h>


#ifdef ENABLE_TPI

typedef struct {
    char name[40];
    char value[10];
} TPI_config;

#define TPI_CONFIG_MAP_SIZE 10
TPI_config tpi_async_config_map[TPI_CONFIG_MAP_SIZE];
int tpi_async_config_map_size = 0;
static int read_env = 0;

static inline void read_tpi_env()
{
    int rank = 0;

    /* only read from environment once */
    if (read_env == 0) {
        char *envval = 0;
        envval = getenv("TPI_ASYNC_CONFIG");
        if (envval && strlen(envval)) {
            char *items = NULL, *keyval = NULL;
            char *ptr1 = NULL, *ptr2 = NULL;
            int idx = 0, i = 0;

            /*export TPI_ASYNC_CONFIG=name1=value1:name2=value2: */
            items = strtok_r(envval, ":", &ptr1);
            while (items != NULL) {
                i = 0;
                keyval = strtok_r(items, "=", &ptr2);
                while (keyval != NULL && i < 3) {
                    if (i == 0)
                        memcpy(tpi_async_config_map[idx].name, keyval, strlen(keyval));
                    if (i == 1)
                        memcpy(tpi_async_config_map[idx].value, keyval, strlen(keyval));

                    keyval = strtok_r(NULL, "=", &ptr2);
                    i++;
                }
                items = strtok_r(NULL, ":", &ptr1);
                idx++;
            }

            tpi_async_config_map_size = idx;

            MPI_Comm_rank(MPI_COMM_WORLD, &rank);
            if (rank == 0) {
                fprintf(stderr, "TPI set config: ");
                for (idx = 0; idx < tpi_async_config_map_size; idx++)
                    fprintf(stderr, "%s=%s, ", tpi_async_config_map[idx].name,
                            tpi_async_config_map[idx].value);
                fprintf(stderr, "\n");
            }
        }
    }
    read_env = 1;
}

extern void armci_enable_async();
extern void armci_disable_async();
extern void armci_auto_async();
extern void armci_reset_async();

void tpi_config_async_(char *name)
{
    int idx;
    int rank = 0;

    read_tpi_env();
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    for (idx = 0; idx < tpi_async_config_map_size; idx++) {
        char *c_name = tpi_async_config_map[idx].name;
        char *c_val = tpi_async_config_map[idx].value;

        if (!strncmp(c_name, name, strlen(name))) {
            if (!strncmp(c_val, "on", strlen("on"))) {
                armci_enable_async();
            }
            else if (!strncmp(c_val, "off", strlen("off"))) {
                armci_disable_async();
            }
            else if (!strncmp(c_val, "auto", strlen("auto"))) {
                armci_auto_async();
            }
            else if (!strncmp(c_val, "default", strlen("default"))) {
                armci_reset_async();
            }
            else {
                if (rank == 0)
                    fprintf(stderr, "unknown asynchronous %s for %s!\n", c_val, name);
                break;  /* go out */
            }

            if (rank == 0)
                fprintf(stderr, "config asynchronous %s for %s\n", c_val, name);
            break;
        }
    }

    if (idx == tpi_async_config_map_size) {
        if (rank == 0)
            fprintf(stderr, "config %s is not defined\n", name);
    }

    return;
}

void tpi_config_async_reset_()
{
    armci_reset_async();
}

#else
void tpi_config_async_(char *name)
{
    /* do nothing */
}

void tpi_config_async_reset_()
{
    /* do nothing */
}
#endif
