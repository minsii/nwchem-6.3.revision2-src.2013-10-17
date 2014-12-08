c
c     $Id: paw_gradient.F 19707 2010-10-29 17:59:36Z d3y133 $
c
      logical function paw_gradient(rtdb)
      implicit none
      integer rtdb
      logical  paw_minimizer,paw_stress
      external paw_minimizer,paw_stress

#include "mafdecls.fh"
#include "rtdb.fh"

*     *** local variables ****
      logical includestress,value

      if (.not.rtdb_get(rtdb,'includestress',mt_log,1,includestress))
     >   includestress = .false.

*     **** only calculate atom gradients ****
      if (.not.includestress) then
         value = paw_minimizer(rtdb,1)

*     **** include stress calculation ****
      else
         value = paw_stress(rtdb)
      end if

      paw_gradient = value
      return
      end

