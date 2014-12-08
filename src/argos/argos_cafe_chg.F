      real*8 function argos_cafe_chg(iq,chg)
c
      implicit none
c
#include "argos_cafe_common.fh"
c
      integer iq
      real*8 chg(mqt,mqp,mset)
c
      argos_cafe_chg=chg(iq,1,iset)/qfac
c
      return
      end
c $Id: argos_cafe_chg.F 21176 2011-10-10 06:35:49Z d3y133 $
