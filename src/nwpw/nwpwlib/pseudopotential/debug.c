/*
 $Id: debug.c 19707 2010-10-29 17:59:36Z d3y133 $
   get_word.c -
   Author - Eric Bylaska

*/
#include	<stdio.h>
#include	"debug.h"


static	int	debug;

int debug_print()
{
    return debug;
}

void set_debug_print(int i)
{
    debug = i;
}
