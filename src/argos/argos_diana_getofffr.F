      subroutine argos_diana_getofffr()
c
      implicit none
c
#include "argos_diana_common.fh"
c
      integer ftell
      external ftell
c
      character*5 string
c
      if(me.eq.0) then
      read(lfntrj,1000) string
    1 continue
      iofffr=ftell(lfntrj)
      read(lfntrj,1000) string
 1000 format(a5)
      if(string.ne.'frame') goto 1
      close(unit=lfntrj)
      endif
c
      return
      end
 
c $Id: argos_diana_getofffr.F 21176 2011-10-10 06:35:49Z d3y133 $
