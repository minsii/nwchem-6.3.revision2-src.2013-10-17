      subroutine argos_cafe_wrtgib(lfngib)
c
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
      integer lfngib
c
      call argos_cafe_wtgib(lfngib,dbl_mb(i_sti))
c
      return
      end
c $Id: argos_cafe_wrtgib.F 21176 2011-10-10 06:35:49Z d3y133 $
