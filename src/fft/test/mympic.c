/*
 $Id: mympic.c 19695 2010-10-29 16:51:02Z d3y133 $
 */

#include "mpi.h"


mysyncc()
{
int istatus;
MPI_Comm handle;
handle = MPI_COMM_WORLD;
istatus = mpi_barrier(handle);
}
