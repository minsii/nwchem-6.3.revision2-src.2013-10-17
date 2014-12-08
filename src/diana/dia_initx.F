      subroutine dia_initx
c
c $Id: dia_initx.F 19708 2010-10-29 18:04:21Z d3y133 $
c
c     reference coordinated entry of analysis module:
c
c     integer nx         : number of atoms
c     integer mx         : leading dimension atomic arrays
c     integer ix(1:nx)   : global atom numbers
c     real*8 x(1:nx,1:3) : atomic coordinates
c
      implicit none
c
#include "dia_common.fh"
#include "mafdecls.fh"
c
c
c
      call dia_rdref(dbl_mb(i_xref))
c
      return
      end

