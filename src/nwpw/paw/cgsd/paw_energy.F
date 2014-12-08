c     $Id: paw_energy.F 19707 2010-10-29 17:59:36Z d3y133 $
      logical function paw_energy(rtdb)
      implicit none
      integer rtdb

      logical  paw_minimizer
      external paw_minimizer

      paw_energy = paw_minimizer(rtdb,0)
      return
      end
