      subroutine argos_cafe_pmecor(ipset,xw,nwmloc,xs,isq,isgm,
     + nsaloc,ecorr)
c
      implicit none
c
#include "argos_cafe_common.fh"
#include "mafdecls.fh"
c
      integer ipset,nwmloc,nsaloc
      real*8 xw(mwm,3,mwa),xs(msa,3),ecorr
      integer isq(msa),isgm(msa)
c
      call argos_cafe_pmec(ipset,xw,nwmloc,xs,isq,isgm,nsaloc,
     + ecorr,int_mb(i_iwq),dbl_mb(i_chg),int_mb(i_lseq))
c
      return
      end
c $Id: argos_cafe_pmecor.F 21176 2011-10-10 06:35:49Z d3y133 $
