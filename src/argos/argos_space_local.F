      logical function argos_space_local(ibbl)
c
      implicit none
c
#include "argos_space_common.fh"
#include "mafdecls.fh"
c
      integer ibbl
      logical local
c
      call argos_space_gtlocal(ibbl,local,int_mb(i_bb))
c
      argos_space_local=local
c
      return
      end
c $Id: argos_space_local.F 21176 2011-10-10 06:35:49Z d3y133 $
