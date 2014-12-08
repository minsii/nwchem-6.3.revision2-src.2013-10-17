#include <stdio.h>
#include <string.h>

void f_memzero_(void* address, int* length)
{
  memset(address,0.0,*length);
  return;
}

/* $Id: f_memset.c 21176 2011-10-10 06:35:49Z d3y133 $ */
