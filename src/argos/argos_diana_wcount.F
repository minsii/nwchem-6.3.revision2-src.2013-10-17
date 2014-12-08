      subroutine argos_diana_wcount(iwsel,ndxw)
c
      implicit none
c
#include "argos_diana_common.fh"
#include "mafdecls.fh"
#include "msgids.fh"
c
      integer iwsel(mwm),ndxw(mwm),i
c
      nwsel=0
      do 1 i=1,nwm
      if(iwsel(i).gt.0) then
      nwsel=nwsel+1
      ndxw(nwsel)=i
      endif
    1 continue
c
      return
      end
c $Id: argos_diana_wcount.F 21176 2011-10-10 06:35:49Z d3y133 $
