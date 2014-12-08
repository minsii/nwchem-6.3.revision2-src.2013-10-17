      real*8 function argos_cafe_am(ia,wgt)
c
      implicit none
c
#include "argos_cafe_common.fh"
c
      integer ia
      real*8 wgt(mat,mset)
c
      argos_cafe_am=wgt(ia,iset)
c
      return
      end
c $Id: argos_cafe_am.F 21176 2011-10-10 06:35:49Z d3y133 $
