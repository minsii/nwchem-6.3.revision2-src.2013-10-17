      subroutine argos_space_gtlocal(ibbl,local,lbbl)
c
      implicit none
c
#include "argos_space_common.fh"
#include "global.fh"
c
      integer ibbl
      logical local
      integer lbbl(mbbl,mbb2)
c
      local=lbbl(ibbl,1).eq.me
c
      return
      end
c $Id: argos_space_gtlocal.F 21176 2011-10-10 06:35:49Z d3y133 $
