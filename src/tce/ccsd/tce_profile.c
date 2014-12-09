#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#define MPI 1
//#define DEBUG 1

#if defined(MPI)
#  include <mpi.h>
#elif defined(OMP)
#  include <omp.h>
#else
#  error You need a timer!
#endif

double timer_start, timer_stop;
double timer_push, timer_pop;
double timer_gstart, timer_gend;

int max_timers = -1;
int *active_timers = NULL;
double *timer_total = NULL;

char stack_name[40];
int stack_name_in_use = 0;

#ifdef ENABLE_TPI
static int env_print_per_rank = -1;
static int tpi_level = -1;

static inline void read_tpi_env()
{
    /* only read from environment once */
    if (tpi_level < 0) {
        char *envval = 0;
        int level = 0;
        envval = getenv("TPI_LEVEL");
        if (envval && strlen(envval)) {
            level = atoi(envval);
            switch (level) {
            case 1:
                tpi_level = 1;
                break;
            case 2:
                tpi_level = 2;
                break;
            default:
                tpi_level = 0;
            }
        }
        else {
            tpi_level = 0;
        }
    }

    /* only read from environment once */
    if (env_print_per_rank < 0) {
        char *envval = 0;
        envval = getenv("TPI_PRINT_PER_RANK");
        if (envval && strlen(envval)) {
            env_print_per_rank = 1;
        }
        else {
            env_print_per_rank = 0;
        }
    }
}

void tpi_start_(int *n)
{
#if defined(MPI)
//    HPM_Init();
#endif

#if defined(MPI) && defined(DEBUG)
    int rank = 0;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    fprintf(stderr, "%4d: tpi_start \n", rank);
#endif

    read_tpi_env();

    max_timers = (*n);

    active_timers = malloc(max_timers * sizeof(int));
    assert(active_timers != NULL);
    timer_total = malloc(max_timers * sizeof(double));
    assert(timer_total != NULL);

    int i;
    for (i = 0; i < max_timers; i++)
        active_timers[i] = 0;
    for (i = 0; i < max_timers; i++)
        timer_total[i] = 0.0;

#if defined(MPI)
    timer_gstart = MPI_Wtime();
#elif defined(OMP)
    timer_gstart = omp_get_wtime();
#endif

    return;
}

void tpi_stop_(void)
{
    int rank = 0;
#if defined(MPI) && defined(DEBUG)
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    fprintf(stderr, "%4d: tpi_stop \n", rank);
#endif

#if defined(MPI)
    timer_gend = MPI_Wtime();
#elif defined(OMP)
    timer_gend = omp_get_wtime();
#endif

    double global_time = timer_gend - timer_gstart;

#if defined(MPI) && !defined(DEBUG)
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
#endif
    if (env_print_per_rank == 1) {
        fprintf(stderr, "rank = %4d                 global total = %lf \n", rank, global_time);
        fflush(stderr);
    }
    else {
        if (rank == 0) {
            fprintf(stderr, "global total = %lf \n", global_time);
            fflush(stderr);
        }
    }

    free(active_timers);
    free(timer_total);

#if defined(MPI)
//    HPM_Print();
//    HPM_Print_Flops();
//    HPM_Print_Flops_Agg();
#endif

    return;
}
#else
void tpi_start_(int *n)
{
    /* do nothing */
}

void tpi_stop_(void)
{
    /* do nothing */
}
#endif

#ifdef ENABLE_TPI
static void tpi_push_name_(char *name, int n)
{
#if defined(MPI) && defined(DEBUG)
    int rank = 0;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    fprintf(stderr, "%4d: tpi_push_name \n", rank);
#endif

    if (stack_name_in_use == 1) {
        fprintf(stderr, "tpi_push_name: name is already in use by %s \n", stack_name);
        fflush(stderr);
    }

    if (n > 40) {
        fprintf(stderr, "tpi_push_name: name is too long (max = 40) \n");
        fflush(stderr);
    }

    memset(stack_name, '\0', 40);
    strncpy(stack_name, name, n);

    int i;
    for (i = 0; i < max_timers; i++)
        active_timers[i] = 0;
    for (i = 0; i < max_timers; i++)
        timer_total[i] = 0.0;

    stack_name_in_use = 1;

#if defined(MPI)
//    HPM_Start(stack_name);
    timer_push = MPI_Wtime();
#elif defined(OMP)
    timer_push = omp_get_wtime();
#endif

    return;
}

static void tpi_pop_name_(char *name, int n)
{
    int rank = 0;
    int size = 1;
#ifdef MPI
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
# ifdef DEBUG
    fprintf(stderr, "%4d: tpi_pop_name \n", rank);
# endif
#endif

#if defined(MPI)
    timer_pop = MPI_Wtime();
//    HPM_Stop(stack_name);
#elif defined(OMP)
    timer_pop = omp_get_wtime();
#endif

    timer_total[0] = (timer_pop - timer_push);

    if (stack_name_in_use == 0) {
        fprintf(stderr, "tpi_pop_name: stack_name is undefined \n");
        fflush(stderr);
    }

    if (0 != strncmp(name, stack_name, n)) {
        fprintf(stderr, "tpi_pop_name: pop name does not match push name (%s,%s) \n", name,
                stack_name);
        fflush(stderr);
    }

    if (env_print_per_rank == 1) {
        fprintf(stderr, "rank = %4d name = %s        grand total = %lf \n", rank, stack_name,
                timer_total[0]);
    }
    else {
        if (rank == 0) {
            fprintf(stderr, "name = %s        grand total = %lf \n", stack_name, timer_total[0]);
        }
    }

    int i;

    if (env_print_per_rank == 1) {
        for (i = 1; i < max_timers; i++)
            if (active_timers[i] > 0) {
                if (i == 1)
                    fprintf(stderr, "rank = %4d name = %s timer = unused       subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 2)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sort2    subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 3)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sortacc2 subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 4)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sort4    subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 5)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sortacc4 subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 6)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sort6    subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 7)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sortacc6 subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 8)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sort8    subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 9)
                    fprintf(stderr, "rank = %4d name = %s timer = tce_sortacc8 subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 10)
                    fprintf(stderr, "rank = %4d name = %s timer = dgemm        subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 11)
                    fprintf(stderr, "rank = %4d name = %s timer = ga_get       subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 12)
                    fprintf(stderr, "rank = %4d name = %s timer = ga_put       subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 13)
                    fprintf(stderr, "rank = %4d name = %s timer = ga_acc       subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else if (i == 14)
                    fprintf(stderr, "rank = %4d name = %s timer = nxtask       subtotal = %lf \n",
                            rank, stack_name, timer_total[i]);
                else
                    fprintf(stderr, "rank = %4d name = %s timer = %9d subtotal = %lf \n", rank,
                            stack_name, i, timer_total[i]);
            }
    }

#if defined(MPI)
    int *active_timers_sum = NULL;
    double *timers_min = NULL;
    double *timers_max = NULL;
    double *timers_avg = NULL;

    active_timers_sum = malloc(max_timers * sizeof(int));
    timers_min = malloc(max_timers * sizeof(double));
    timers_max = malloc(max_timers * sizeof(double));
    timers_avg = malloc(max_timers * sizeof(double));
    assert(active_timers_sum != NULL && timers_min != NULL && timers_max != NULL &&
           timers_avg != NULL);

    if (rank == 0)
        for (i = 1; i < max_timers; i++)
            timers_min[i] = 10000000.0;
    if (rank == 0)
        for (i = 1; i < max_timers; i++)
            timers_max[i] = 0.0;
    if (rank == 0)
        for (i = 1; i < max_timers; i++)
            timers_avg[i] = -1.0;

    MPI_Reduce(active_timers, active_timers_sum, max_timers, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(timer_total, timers_min, max_timers, MPI_DOUBLE, MPI_MIN, 0, MPI_COMM_WORLD);
    MPI_Reduce(timer_total, timers_max, max_timers, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    MPI_Reduce(timer_total, timers_avg, max_timers, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    double ascal = 1.0 / size;
    if (rank == 0)
        for (i = 1; i < max_timers; i++)
            timers_avg[i] *= ascal;

    for (i = 1; i < max_timers; i++)
        if (rank == 0 && active_timers_sum[i] > 0) {
            if (i == 1)
                fprintf(stderr, "name = %s timers = sd_t_*_[1-9] min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 2)
                fprintf(stderr, "name = %s timers = tce_sort2    min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 3)
                fprintf(stderr, "name = %s timers = tce_sortacc2 min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 4)
                fprintf(stderr, "name = %s timers = tce_sort4    min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 5)
                fprintf(stderr, "name = %s timers = tce_sortacc4 min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 6)
                fprintf(stderr, "name = %s timers = tce_sort6    min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 7)
                fprintf(stderr, "name = %s timers = tce_sortacc6 min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 8)
                fprintf(stderr, "name = %s timers = tce_sort8    min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 9)
                fprintf(stderr, "name = %s timers = tce_sortacc8 min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 10)
                fprintf(stderr, "name = %s timers = dgemm        min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 11)
                fprintf(stderr, "name = %s timers = ga_get       min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 12)
                fprintf(stderr, "name = %s timers = ga_put       min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 13)
                fprintf(stderr, "name = %s timers = ga_acc       min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else if (i == 14)
                fprintf(stderr, "name = %s timers = nxtask       min = %lf max = %lf avg = %lf \n",
                        stack_name, timers_min[i], timers_max[i], timers_avg[i]);
            else
                fprintf(stderr, "unknown timer! \n");
        }

    free(active_timers_sum);
    free(timers_min);
    free(timers_max);
    free(timers_avg);
#endif

    fflush(stderr);

    memset(stack_name, '\0', 40);

    stack_name_in_use = 0;

    return;
}

void tpi_push_name_level1_(char *name, int n)
{
    if (tpi_level == 1) {
        return tpi_push_name_(name, n);
    }
}

void tpi_push_name_level2_(char *name, int n)
{
    if (tpi_level == 2) {
        return tpi_push_name_(name, n);
    }
}

void tpi_pop_name_level1_(char *name, int n)
{
    if (tpi_level == 1) {
        return tpi_pop_name_(name, n);
    }
}

void tpi_pop_name_level2_(char *name, int n)
{
    if (tpi_level == 2) {
        return tpi_pop_name_(name, n);
    }
}
#else
void tpi_push_name_level1_(char *name, int n)
{
    /* do nothing */
}

void tpi_push_name_level2_(char *name, int n)
{
    /* do nothing */
}

void tpi_pop_name_level1_(char *name, int n)
{
    /* do nothing */
}

void tpi_pop_name_level2_(char *name, int n)
{
    /* do nothing */
}
#endif

#ifdef ENABLE_TPI
void tpi_start_timer_(int *id)
{
#if defined(MPI) && defined(DEBUG)
    int rank = 0;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    fprintf(stderr, "%4d: tpi_start_timer \n", rank);
#endif

    if (stack_name_in_use == 0)
        return;

    if ((*id) > max_timers) {
        fprintf(stderr, "tpi_start_timer: timer undefined \n");
        fflush(stderr);
    }

    active_timers[*id] = 1;

#if defined(MPI)
    timer_start = MPI_Wtime();
#elif defined(OMP)
    timer_start = omp_get_wtime();
#endif

    return;
}

void tpi_stop_timer_(int *id)
{
#if defined(MPI) && defined(DEBUG)
    int rank = 0;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    fprintf(stderr, "%4d: tpi_stop_timer \n", rank);
#endif

    if (stack_name_in_use == 0)
        return;

#if defined(MPI)
    timer_stop = MPI_Wtime();
#elif defined(OMP)
    timer_stop = omp_get_wtime();
#endif

    if ((*id) > max_timers) {
        fprintf(stderr, "tpi_stop_timer: timer undefined \n");
        fflush(stderr);
    }

    if (active_timers[*id] == 0) {
        fprintf(stderr, "tpi_stop_timer: timer not started \n");
        fflush(stderr);
    }

    timer_total[*id] += (timer_stop - timer_start);

    return;
}
#else
void tpi_start_timer_(int *id)
{
    /* do nothing */
}

void tpi_stop_timer_(int *id)
{
    /* do nothing */
}
#endif
