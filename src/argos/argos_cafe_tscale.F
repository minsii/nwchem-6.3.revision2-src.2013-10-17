      subroutine argos_cafe_tscale()
c
      implicit none
c
#include "argos_cafe_common.fh"
c
      scalew=one
      scales=one
      if(itscal.eq.1) then
      if(temp.gt.small) scalew=sqrt(one+(tmpext/temp-one)*tstep/tmwrlx)
      scales=scalew
      elseif(itscal.gt.1) then
      if(tempw.gt.small)
     + scalew=sqrt(one+(tmpext/tempw-one)*tstep/tmwrlx)
      if(temps.gt.small)
     + scales=sqrt(one+(tmpext/temps-one)*tstep/tmsrlx)
      endif
c
      return
      end
c $Id: argos_cafe_tscale.F 21176 2011-10-10 06:35:49Z d3y133 $
