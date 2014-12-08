c     $Id: band_noit_energy.F 19707 2010-10-29 17:59:36Z d3y133 $

      logical function band_noit_energy(rtdb)
      implicit none
      integer rtdb
      logical  band_minimizer
      external band_minimizer

      band_noit_energy = band_minimizer(rtdb,-1)
      return
      end

