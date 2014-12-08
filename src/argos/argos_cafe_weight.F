      subroutine argos_cafe_weight(numw,nums,isat,isml,ishop,wbx)
c $Id: argos_cafe_weight.F 19708 2010-10-29 18:04:21Z d3y133 $
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
c
      integer numw,nums,isat(msa),isml(msa),ishop(msa)
      real*8 wbx
c
      call argos_cafe_wbox(numw,nums,int_mb(i_iwa),isat,isml,ishop,
     + dbl_mb(i_wsm),dbl_mb(i_mas))
c
      wbx=wbox
c
      return
      end
