      integer function argos_prop_dfr(ncopy)
c
      implicit none
c
#include "argos_prop.fh"
#include "mafdecls.fh"
c
      integer argos_prop_dfr_copy
      external argos_prop_dfr_copy
c
      integer ncopy
c
      argos_prop_dfr=argos_prop_dfr_copy(ncopy,
     + dbl_mb(i_dfr),dbl_mb(i_dfrm))
c
      return
      end
c $Id: argos_prop_dfr.F 21176 2011-10-10 06:35:49Z d3y133 $
