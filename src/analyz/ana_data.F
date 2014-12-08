      subroutine ana_data(t,nx,ix,x)
c
c $Id: ana_data.F 19708 2010-10-29 18:04:21Z d3y133 $
c
c     data entry of analysis module:
c
c     real*8 t           : simulation time in ps
c     integer nx         : number of atoms
c     integer mx         : leading dimension atomic arrays
c     integer ix(1:nx)   : global atom numbers
c     real*8 x(1:nx,1:3) : atomic coordinates
c
      implicit none
c
#include "ana_common.fh"
#include "mafdecls.fh"
c
      real*8 t
      integer nx
      integer ix(msa)
      real*8 x(msa,3)
c
      time=t
      ndata=ndata+1
c
      if(irmsd.gt.0) then
      call ana_rmsdev(x,ix,nx,dbl_mb(i_xref),dbl_mb(i_wt),
     + dbl_mb(i_xrms))
      endif
c
      return
      end
