/*
 $Id: util_mpinap.c 20277 2011-05-05 16:59:07Z d3p852 $
 */
#include <stdio.h>
#include <unistd.h>

#ifdef MPI
#include <mpi.h>
#endif
#include "ga.h"
#include "macdecls.h"
/* This makes each process sleep for Mpirank/factor microsec*/
/*#define DEBUG 1*/
void FATR util_mpinap_(Integer *factor)
{
  int myid, sleeptime;
#ifdef MPI
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
#else
  myid=ga_nodeid_();
#endif
  sleeptime=(myid+1)/((long) *factor);
#ifdef DEBUG
  printf(" %d sleeping for %d usec %d factor \n", myid, sleeptime, (long) *factor);
#endif
  usleep(sleeptime);
}
