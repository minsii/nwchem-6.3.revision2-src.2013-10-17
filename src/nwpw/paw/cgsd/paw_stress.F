c     $Id: paw_stress.F 19707 2010-10-29 17:59:36Z d3y133 $

      logical function paw_stress(rtdb)
      implicit none
      integer rtdb

      logical  paw_stress_numerical
      external paw_stress_numerical

      paw_stress = paw_stress_numerical(rtdb)
      return
      end
