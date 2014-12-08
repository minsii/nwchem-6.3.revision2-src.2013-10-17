      subroutine argos_space_gethdl(ibbl,lhandl,lself,
     + iwfr,iwto,isfr,isto)
c
      implicit none
c
#include "argos_space_common.fh"
#include "mafdecls.fh"
c
      integer ibbl,lhandl
      integer iwfr,iwto,isfr,isto
      logical lself
c
      call argos_space_gthdl(ibbl,lhandl,lself,iwfr,iwto,isfr,isto,
     + int_mb(i_bb),int_mb(i_ipl))
c
      return
      end
c $Id: argos_space_gethdl.F 21176 2011-10-10 06:35:49Z d3y133 $
