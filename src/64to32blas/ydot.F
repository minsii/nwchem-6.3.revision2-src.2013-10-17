      double precision function ydot(n,dx,incx,dy,incy)
*
* $Id: ydot.F 19697 2010-10-29 16:57:34Z d3y133 $
*
      implicit none
#include "y64.fh"
      double precision dx(*),dy(*)
      integer incx,incy,n
c
      INTGR4 incx4,incy4,n4
      external ddot
      double precision ddot
c
      incx4=incx
      incy4=incy
      n4=n
c
      ydot= ddot(n4,dx,incx4,dy,incy4)
      return
      end
