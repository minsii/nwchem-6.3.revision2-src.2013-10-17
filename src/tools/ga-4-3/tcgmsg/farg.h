/* $Header: /tmp/hpctools/ga/tcgmsg-mpi/farg.h,v 1.14 2005-11-24 01:14:27 manoj Exp $ */
/*
  This include file defines ARGC_ and ARGV_ which are the appropriate
  global variables to get at the command argument list in the
  FORTRAN runtime environment. 
  This will need to be modified for each new machine (try using nm or 
  generating a full load map). 
*/

/* Used to be SEQUENT here but charged to _X_argv */
#if defined(SUN) || defined(ALLIANT) || defined(ENCORE) || defined(CONVEX) || \
  defined(KSR)
#   define ARGC_ xargc
#   define ARGV_ xargv
#endif

#if defined(ARDENT)
#   define ARGC_ _UT_argc
#   define ARGV_ _UT_argv
#endif

#if (defined(SGI) || defined(ULTRIX))
#   define ARGC_ f77argc
#   define ARGV_ f77argv
#endif

#if defined(DECOSF)
#   define ARGC_ __Argc
#   define ARGV_ __Argv
#endif

#if defined(AIX)
#   define ARGC_ p_xargc
#   define ARGV_ p_xargv
#endif

#if defined(CRAY) 
#   define ARGC_ _argc
#   define ARGV_ _argv
#endif

#if defined(GFORTRAN) 
#   ifdef EXT_INT
#       warning define getarg_ _gfortran_getarg_i8
#       define getarg_ _gfortran_getarg_i8
#   else
#       warning define getarg_ _gfortran_getarg_i4
#       define getarg_ _gfortran_getarg_i4
#   endif
#   define iargc_  _gfortran_iargc
#endif

#if defined(PGLINUX) /* PGI compilers on Linux */
#   define ARGC_ __argc_save
#   define ARGV_ __argv_save
#elif defined(IFCLINUX)
#   ifdef IFCV8
#       define ARGC_ for__l_argc
#       define ARGV_ for__a_argv
#   else
#       define ARGC_ xargc
#       define ARGV_ xargv
#   endif
#elif defined(SGILINUX)
#   define ARGC_ _f90argc
#   define ARGV_ _f90argv
#elif defined(MACX) && defined(XLFMAC)
#   define ARGC_ NXArgc
#   define ARGV_ NXArgv
#else
/* g77/gcc fortran argc/argv interface on linux is unstable */
#   if defined(LINUX) || defined(INTERIX) || defined(CYGWIN) || defined(MACX)
#       if ((__GNUC__ > 2) || ((__GNUC__ == 2) && (__GNUC_MINOR__ > 90)))
#           define ARGC_ f__xargc
#           define ARGV_ f__xargv
#       else
#           define ARGC_ xargc
#           define ARGV_ xargv
#       endif
#   endif
#endif

#ifdef SEQUENT
#   define ARGC_ _X_argc
#   define ARGV_ _X_argv
#endif

#if defined(NEXT)
#   define ARGC_ _NXArgc
#   define ARGV_ _NXArgv
#endif

#if defined(HPUX)
    /* ARGC_ and ARGV_ are allocated and constructed in pbeginf */
#else
    extern int ARGC_;
    extern char **ARGV_;
#endif

#if defined(HPUX)    || defined(SUN)       || defined(SOLARIS)  || \
    defined(PARAGON) || defined(FUJITSU)   || defined(WIN32)    || \
    defined(LINUX64) || defined(NEC)       || defined(LINUX)    || \
    defined(HITACHI) || defined(__crayx1)  || \
    defined(BGL)     || defined(BGP)       || defined(BGQ)      || \
    defined (XLFMAC) || defined(ABSOFTMAC) || defined(GFORTRAN) || \
   (defined(MACX) && defined(GFORTRAN))    || \
   (defined(LINUX64) && defined(__alpha__))
#   define HAS_GETARG 1
#endif

#ifndef WIN32
#   define FATR 
#endif

#ifdef WIN32
#   define getarg_ GETARG
#   define iargc_  IARGC
#   include <windows.h>
#   include "winutil.h"
#   define NTYPE short
    extern int  FATR iargc_(void);
    extern void FATR getarg_( NTYPE *, char*, int, NTYPE*);
#elif defined(HPUX)
#   ifndef EXTNAME
#       define hpargv_ hpargv
#       define hpargc_ hpargc
#   endif
    extern int hpargv_();
    extern int hpargc_();
#else /* ALL OTHER PLATFORMS */
    extern int iargc_();
    extern void getarg_();
#endif

#if defined(__crayx1) 
#   define getarg_  pxfgetarg_
#   define IARGC  ipxfargc_
#   define NTYPE  int 
    extern void FATR getarg_( NTYPE *, char*, NTYPE*, NTYPE*, int);
#endif

/* Eample use

static void PrintCommandArgList()
{
  int i;

  for (i=0; i<ARGC_; i++)
    (void) printf("argv(%d)=%s\n", i, ARGV_[i]);
}

*/

