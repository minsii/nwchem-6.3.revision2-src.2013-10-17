      subroutine argos_cafe_comw(xw,xwm,iwfr,iwto)
c
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
      integer iwfr,iwto
      real*8 xw(mwm,3,mwa),xwm(mwm,3)
c
      call argos_cafe_cmw(xw,xwm,iwfr,iwto,int_mb(i_iwa),dbl_mb(i_mas))
c
      return
      end
c $Id: argos_cafe_comw.F 21176 2011-10-10 06:35:49Z d3y133 $
