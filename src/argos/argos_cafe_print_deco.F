      subroutine argos_cafe_print_deco(lfnout,dec)
c
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
      integer lfnout
      real*8 dec(6,nsatot)
c
      call argos_cafe_print_d(lfnout,byte_mb(i_snam),dec)
c
      return
      end
c $Id: argos_cafe_print_deco.F 21176 2011-10-10 06:35:49Z d3y133 $
