#include <string.h>
#include "typesf2c.h"

/* A fortran interface to memcpy since on at least one machine
   (LINUX) dcopy() breaks when copying -ve integers even if
   everything is correctly aligned. So you cannot copy common
   blocks or packed buffers, without doing the right thing  */

#if (defined(CRAY) || defined(WIN32)) && !defined(__crayx1)
#define util_memcpy_ UTIL_MEMCPY
#endif

void FATR util_memcpy_(void *dest, void *src, Integer *n) 
{
  memcpy(dest, src, (size_t) *n);
}

/* $Id: util_memcpy.c 21176 2011-10-10 06:35:49Z d3y133 $ */
