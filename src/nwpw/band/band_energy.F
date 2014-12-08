c     $Id: band_energy.F 19707 2010-10-29 17:59:36Z d3y133 $
      logical function band_energy(rtdb)
      implicit none
      integer rtdb
      logical  band_minimizer
      external band_minimizer

      band_energy = band_minimizer(rtdb,0)
      return
      end

