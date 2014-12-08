c     $Id: ofpw_energy.F 19707 2010-10-29 17:59:36Z d3y133 $
      logical function ofpw_energy(rtdb)
      implicit none
      integer rtdb
      logical  ofpw_minimizer
      external ofpw_minimizer

      write(*,*) "hello from ofpw_energy"
      ofpw_energy = ofpw_minimizer(rtdb,0)
      return
      end

