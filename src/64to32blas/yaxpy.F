      subroutine yaxpy(n,da,dx,incx,dy,incy)
*
* $Id: yaxpy.F 19697 2010-10-29 16:57:34Z d3y133 $
*
      implicit none
#include "y64.fh"
      double precision dx(*),dy(*),da
      integer incx,incy,n
c
      INTGR4 incx4,incy4,n4
c
      if(n.le.0)return
      if (da .eq. 0.0d0) return
      incx4=incx
      incy4=incy
      n4=n
c
      call daxpy(n4,da,dx,incx4,dy,incy4)
      return
      end
