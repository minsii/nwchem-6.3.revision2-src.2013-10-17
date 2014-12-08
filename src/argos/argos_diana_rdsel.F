      subroutine argos_diana_rdsel()
c
      implicit none
c
#include "argos_diana_common.fh"
#include "mafdecls.fh"
c
      filsel=card(8:80)
      call argos_diana_readsel(lfnsel,filsel,int_mb(i_wsel),
     + int_mb(i_isel))
      call argos_diana_wcount(int_mb(i_wsel),int_mb(i_ndxw))
c
      return
      end
c $Id: argos_diana_rdsel.F 21176 2011-10-10 06:35:49Z d3y133 $
