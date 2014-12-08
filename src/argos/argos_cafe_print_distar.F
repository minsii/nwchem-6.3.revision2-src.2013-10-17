      subroutine argos_cafe_print_distar(lfnout)
c
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
      integer lfnout
c
      call argos_cafe_print_dstr(lfnout,byte_mb(i_snam),
     + int_mb(i_idrs),dbl_mb(i_rdrs))
c
      return
      end
c $Id: argos_cafe_print_distar.F 21176 2011-10-10 06:35:49Z d3y133 $
