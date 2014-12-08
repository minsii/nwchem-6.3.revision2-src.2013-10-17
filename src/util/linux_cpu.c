/*
 $Id: linux_cpu.c 19707 2010-10-29 17:59:36Z d3y133 $
 */

#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>
#include <stdio.h>

double linux_cputime_(void)
{
  struct rusage rusage_out;

   (void) getrusage (RUSAGE_SELF, &rusage_out);

  return ((double)rusage_out.ru_utime.tv_usec* 1E-6 + (double)(rusage_out.ru_utime.tv_sec));
}
