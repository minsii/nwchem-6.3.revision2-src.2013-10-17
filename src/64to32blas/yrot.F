      subroutine  yrot (n,dx,incx,dy,incy,c,s)
*
* $Id: yrot.F 22591 2012-06-18 21:06:29Z d3p852 $
*
      implicit none
#include "y64.fh"
      double precision dx(*),dy(*),c,s
      integer incx,incy,n
c
      INTGR4 incx4,incy4,n4
c
      if(n.le.0)return
c
      n4=n
      incx4=incx
      incy4=incy
c
      call  drot (n4,dx,incx4,dy,incy4,c,s)
      return
      end
