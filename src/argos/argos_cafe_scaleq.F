      subroutine argos_cafe_scaleq(iqfr,iqto)
c
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
      integer iqfr,iqto
c
      call argos_cafe_sclq(iqfr,iqto,dbl_mb(i_chg))
c
      return
      end
c $Id: argos_cafe_scaleq.F 21176 2011-10-10 06:35:49Z d3y133 $
