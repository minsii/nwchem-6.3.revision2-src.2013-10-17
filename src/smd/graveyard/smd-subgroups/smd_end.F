c $Id: smd_end.F 19707 2010-10-29 17:59:36Z d3y133 $
      subroutine smd_end(rtdb)
      implicit none
#include "errquit.fh"
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "util.fh"
#include "global.fh"
c     
      integer rtdb
c
      character*32 pname
c
      pname = "smd_end"
c
c      write(*,*) "in "//pname
c
      call smd_data_destroy()
c
      return
      end

