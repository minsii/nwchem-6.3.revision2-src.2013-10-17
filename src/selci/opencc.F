      subroutine opencc
#include "errquit.fh"
*
* $Id: opencc.F 19708 2010-10-29 18:04:21Z d3y133 $
*
      entry putcc
      entry getcc
      entry getccn
      entry srchcc
      entry closecc
c
      call errquit(' C I/O routines not implemented ',-1, CAPMIS_ERR)
c
      end
