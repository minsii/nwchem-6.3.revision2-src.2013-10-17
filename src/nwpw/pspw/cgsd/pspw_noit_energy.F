c     $Id: pspw_noit_energy.F 19707 2010-10-29 17:59:36Z d3y133 $
      logical function pspw_noit_energy(rtdb)
      implicit none
      integer rtdb

      logical  cgsdv5
      external cgsdv5

      pspw_noit_energy = cgsdv5(rtdb,-1)
      return
      end

