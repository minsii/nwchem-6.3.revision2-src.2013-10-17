      integer function argos_cafe_atonum(ia,num)
c
      implicit none
c
#include "argos_cafe_common.fh"
c
      integer ia,num(mat,3)
c
      argos_cafe_atonum=num(ia,iset)
c
      return
      end
c $Id: argos_cafe_atonum.F 21176 2011-10-10 06:35:49Z d3y133 $
