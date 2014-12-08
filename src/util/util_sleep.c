/*
 $Id: util_sleep.c 19707 2010-10-29 17:59:36Z d3y133 $
 */

#if defined(CRAY) &&!defined(__crayx1)

void UTIL_SLEEP(long *t)
{}

#elif defined(WIN32)

#include "winutil.h"
#include "typesf2c.h"
void FATR UTIL_SLEEP(long *t) 
{
  unsigned s = *t;
  sleep(s);
}

#else

#include <unistd.h>
void util_sleep_(long *t) 
{
  unsigned s = *t;
  sleep(s);
}

#endif
