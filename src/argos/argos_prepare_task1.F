      logical function argos_prepare_task1(irtdb)
c
c $Id: argos_prepare_task1.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      implicit none
c
#include "rtdb.fh"
c
      logical scf,esp
      external scf,esp
c
      integer irtdb
      logical lstate
c
      lstate=rtdb_parallel(.true.)
c
      argos_prepare_task1=.false.
c
c      if(.not.rtdb_cput(irtdb,'scf:print',1,'none'))
c     + call md_abort('argos_prepare_task1: rtdb_cput failed',9999)
c
      if(scf(irtdb)) then
c
c      if(.not.rtdb_cput(irtdb,'esp:print',1,'none'))
c     + call md_abort('argos_prepare_task1: rtdb_cput failed',9999)
c
      if(esp(irtdb)) then
      argos_prepare_task1=.true.
      endif
      endif
c
      lstate=rtdb_parallel(.false.)
c
      return
      end
