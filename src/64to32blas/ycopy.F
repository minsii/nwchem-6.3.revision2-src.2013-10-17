      subroutine  ycopy(n,dx,incx,dy,incy)
*
* $Id: ycopy.F 19697 2010-10-29 16:57:34Z d3y133 $
*
      implicit none
#include "y64.fh"
      double precision dx(*),dy(*)
      integer incx,incy,n
c
      INTGR4  n4,incx4,incy4
c
      n4=n
      incx4=incx
      incy4=incy
c
      call  dcopy(n4,dx,incx4,dy,incy4)
      return
      end
