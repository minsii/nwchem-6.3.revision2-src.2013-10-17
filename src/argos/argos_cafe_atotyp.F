      integer function argos_cafe_atotyp(ityp,ia)
c
      implicit none
c
#include "argos_cafe_common.fh"
c
      integer ia
      integer ityp(mat,3)
c
      argos_cafe_atotyp=ityp(ia,iset)
c
      return
      end
c $Id: argos_cafe_atotyp.F 21176 2011-10-10 06:35:49Z d3y133 $
