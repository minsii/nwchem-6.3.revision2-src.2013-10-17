      subroutine dia_inirms(xref,xrms,wt)
c
c $Id: dia_inirms.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      implicit none
c
#include "dia_common.fh"
#include "dia_params.fh"
c
      real*8 xref(nsa,3),xrms(nsa),wt(nsa)
c
      integer i
c
      do 1 i=1,nsa
      xrms(i)=zero
      wt(i)=one
    1 continue
c
      return
      end
