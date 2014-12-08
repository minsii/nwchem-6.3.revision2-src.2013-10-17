C> \ingroup task
C> @{
      function task_smd(rtdb)
      implicit none
#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "errquit.fh"
      integer rtdb
      logical task_smd
c
      character*40 operation
      character*40 pname
c
      pname = " task_smd"

      if (.not. rtdb_cget(rtdb,'task:operation', 1,operation))
     $      call errquit(pname,0, RTDB_ERR)

      write(*,*) "found operation",operation
      write(*,*) "Goodbye from task_smd"
      task_smd = .true.
      return
      END
C> @}
c $Id: task_smd.F 22842 2012-09-12 07:37:03Z d3y133 $
