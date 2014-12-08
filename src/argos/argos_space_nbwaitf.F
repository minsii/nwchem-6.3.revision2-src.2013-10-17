      subroutine argos_space_nbwaitf()
c
      implicit none
c
#include "argos_space_common.fh"
#include "mafdecls.fh"
#include "global.fh"
c
      call argos_space_nbwait3(int_mb(i_bb))
c
      return
      end
c $Id: argos_space_nbwaitf.F 21176 2011-10-10 06:35:49Z d3y133 $
