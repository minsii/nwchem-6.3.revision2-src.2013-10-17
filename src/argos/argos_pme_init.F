      subroutine argos_pme_init()
c
      implicit none
c
#include "argos_pme_common.fh"
#include "global.fh"
c
      call ga_zero_list(mgz,lslab)
      call argos_pme_flag(0,0,me)
      call argos_pme_flag(1,0,me)
      call ga_sync()
c
      return
      end
c $Id: argos_pme_init.F 21176 2011-10-10 06:35:49Z d3y133 $
