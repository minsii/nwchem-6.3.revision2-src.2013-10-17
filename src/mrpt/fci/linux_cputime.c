/*
 $Id: linux_cputime.c 19708 2010-10-29 18:04:21Z d3y133 $
*/

#include <time.h>

double linux_cputime_(void)
{
  unsigned long thetime = clock();
  double value = ((double) thetime) / ((double) CLOCKS_PER_SEC);

  /* printf("t = %ld, value = %f\n", thetime, value); */

  return value;
}
