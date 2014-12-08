c     $Id: paw_noit_energy.F 19707 2010-10-29 17:59:36Z d3y133 $
      logical function paw_noit_energy(rtdb)
      implicit none
      integer rtdb

      logical  paw_minimizer
      external paw_minimizer

      paw_noit_energy = paw_minimizer(rtdb,-1)
      return
      end
