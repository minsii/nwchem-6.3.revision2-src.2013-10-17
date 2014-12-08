/*
 $Id: primes.c 19708 2010-10-29 18:04:21Z d3y133 $
 */

#include <stdio.h>
#include <math.h>

#define N_PRIME 10000

int main()
{
  int i;
  int p = 1;
  int np = 0;
  int primes[N_PRIME];

  for (p=3, np=0; np<N_PRIME; p+=2) {
    int prime = 1, j;
    for (j=0; j<np && primes[j]<=sqrt((double) p); j++)
      if ((p%primes[j]) == 0) {
	prime = 0;
	break;
      }
    if (prime) {
      primes[np++] = p;
      printf("%d\n", p);
    }
  }

  return 0;
}
