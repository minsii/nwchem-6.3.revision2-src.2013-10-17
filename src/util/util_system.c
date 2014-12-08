/*
 $Id: util_system.c 20277 2011-05-05 16:59:07Z d3p852 $
 */

#include <stdio.h>
#ifndef WIN32
#include <unistd.h>
#endif

extern int system(const char *);

#if defined(CRAY) && !defined(__crayx1)
#include <fortran.h>
#define FATR
#endif
#ifdef WIN32
#include "typesf2c.h"
#endif
#if defined (DECOSF)
#define __USE_BSD
#include <signal.h>
#undef __USE_BSD
#endif

void GA_Error(char *str, int code);

typedef long Integer;		/*  FORTRAN integer */

#if defined(USE_FCD)
int fortchar_to_string(_fcd, int, char *, const int);
#else
int fortchar_to_string(const char *, int, char *, const int);
#endif

#if defined(USE_FCD)
Integer FATR UTIL_SYSTEM(_fcd input)
{
    int lin  = _fcdlen(input);
#else
Integer util_system_(const char *input, int lin)
{
#endif
#if (defined(LINUX) || defined(DECOSF)) && !defined(__x86_64__)
    int i;
	void (*Siginit)();
#endif
    char in[1024];
    if (!fortchar_to_string(input, lin, in, sizeof(in)))
	GA_Error("util_system: fortchar_to_string failed for in",0);

#if defined(DECOSF)
	Siginit = signal(SIGCHLD,SIG_IGN);
	i = system(in);
	Siginit = signal(SIGCHLD,Siginit);
    return i;
#elif defined(CATAMOUNT)
    GA_Error("system calls do not work on this machine", 0);
#else
    return system(in);
#endif
}
