      logical function task_smd_energy(rtdb)
      implicit none
      integer rtdb

#include "inp.fh"
#include "mafdecls.fh"
#include "rtdb.fh"
#include "stdio.fh"
#include "errquit.fh"
      character*72 namespace
      character*32 pname
      double precision etime1,etime2,etime3,etime4,etime5,etime6
      double precision energy,ewald1,ewald2,evdw
      logical operiodic

      pname = "task_smd_energy"
      write(*,*) "in "//pname
c
c     start the clock
c     ---------------
      etime1=0.0
      etime2=0.0
      etime3=0.0
      etime4=0.0
      etime5=0.0
      etime6=0.0
      call cpu_time(etime1)
c
      call cpu_time(etime1)
      call smd_init("energy",rtdb)
      call cpu_time(etime2)
cc
c      call smd_vlist_update(.true.,.true.)
c      call cpu_time(etime3)
cc
c      call smd_force_compute()
c      call cpu_time(etime4)
cc
c      call smd_energy_compute()
c      call cpu_time(etime5)
cc
c      call smd_energy_print(6)
cc
c      call smd_end()
c
      if (.not. rtdb_put(rtdb,'smd:energy',mt_dbl,1,energy))
     $     call errquit(pname//'failed put energy', 0, RTDB_ERR)
c

      call cpu_time(etime6)
c      write(luout,'(/,a,f20.3)')'Total CPU time : ',(etime6-etime1)
c      write(luout,'(/,a,f20.3)')'Initialization : ',(etime2-etime1)
c      write(luout,'(/,a,f20.3)')'Verlet         : ',(etime3-etime2)
c      write(luout,'(/,a,f20.3)')'Force          : ',(etime4-etime3)

      write(*,*) "Goodbye from task_smd"
      task_smd_energy = .true.

      return
      END
c $Id: task_smd_energy.F 22502 2012-05-20 06:11:57Z d3y133 $
