      subroutine util_getarg(iarg_in,arg)
* $Id: util_getarg.F 22339 2012-04-25 21:50:11Z niri $
*
* The statement call util_getarg( k , arg ) gets the  kth  command-
* line argument and puts it into the string arg.
*
      implicit none
#include "errquit.fh"
      integer iarg_in
      character*(*) arg
#if defined(EXT_INT) && !( __GNUC__ >= 4)
      integer*4 iarg
#else
      integer iarg
#if defined(WIN32)
      integer idum
#endif
#endif
#if defined(CRAY)
      integer*4 length,ierror
#endif
#if defined(HPUX)
#ifdef EXT_INT
!$HP$ ALIAS getarg='getarg__'
#else
!$HP$ ALIAS getarg='getarg_'
#endif
#endif
*
      iarg=iarg_in
#if defined(CRAY)
      call pxfgetarg(iarg,arg,length,ierror)
c
      if (ierror.ne.0)
     + call errquit('util_getarg:pxfgetarg fatal error',ierror,
     &       UNKNOWN_ERR)
#elif defined(WIN32)
      call getarg(iarg,arg,idum)
#else
      call getarg(iarg,arg)
#endif
*
      return
      end
