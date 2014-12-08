      subroutine argos_cafe_print_solvent(lfnout)
c
      implicit none
c
#include "argos_cafe_common.fh"
c
      integer lfnout
c
      write(lfnout,1000)
 1000 format(/,' SOLVENT',//)
      return
      end
c $Id: argos_cafe_print_solvent.F 21176 2011-10-10 06:35:49Z d3y133 $
