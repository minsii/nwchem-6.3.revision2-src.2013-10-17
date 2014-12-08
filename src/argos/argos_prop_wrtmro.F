      subroutine argos_prop_wrtmro(lfnmro,ndec)
c
      implicit none
c
#include "argos_prop.fh"
#include "mafdecls.fh"
c
      integer lfnmro,ndec
c
      call argos_prop_wtmro(lfnmro,ndec,dbl_mb(i_dfr),dbl_mb(i_dfrm))
c
      return
      end
c $Id: argos_prop_wrtmro.F 21176 2011-10-10 06:35:49Z d3y133 $
