c
c     $Id: perfm_end.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      subroutine perfm_end()
      implicit none
#include "perfm.fh"
#ifdef USE_PAPI
      double precision flpsum,flpmax,flpmin
      double precision util_wallsec,util_cpusec
      external util_wallsec,util_cpusec
      integer retvals
#endif
#ifdef FDIST
      call finalize_dist( ga_nodeid() )
#endif
#ifdef USE_PAPI
#ifdef PAPI_FPINS
      if(lfailed) return
      call  PAPIf_flips( real_time, proc_time, flpins, mflops, retval)
      usn=util_wallsec()
      proc1=util_cpusec()
      retvals=retval
      if (retval .NE. PAPI_OK) call perfm_error(retval,
     $     ' perfm_end: could not get papi flpins ')
      call ga_sync()
c
c     sum,max and min dgops
c     
      flpsum=flpins
      flpmax=flpins
      flpmin=flpins
      call ga_dgop(msg_perfm_max,flpmax,1, 'max')
      call ga_dgop(msg_perfm_min,flpmin,1, 'min')
      call ga_dgop(msg_perfm_sum,flpsum,1, '+')
c
      real_time = usn - uso
      proc_time=proc1-proc0
      if(ga_nodeid().eq.0.and.
     A     (real_time.gt.0.1d0).and.
     A     (abs(proc_time).gt.0.1d0)) then
         write(luout,12) ' Aggregate GFloating-point ops: ', 
     ,        flpsum*conv2m
         write(luout,12) ' Aggregate GFLOPS (Real_time): ', 
     ,        flpsum/real_time*conv2m
         write(luout,12) ' Aggregate GFLOPS (Proc_time): ', 
     ,        flpsum/proc_time*conv2m
         write(luout,12) ' Average   GFLOPS: ', 
     ,        conv2m*flpsum/real_time/ga_nnodes()
         write(luout,12) ' Max       GFLOPS: ', 
     ,        flpmax/real_time*conv2m
         write(luout,12) ' Min       GFLOPS: ', 
     ,        flpmin/real_time*conv2m
 12      format(A38,F10.2) 
      endif
#else
      call PAPIf_stop(es, values(1), retval)
      if (retval .NE. PAPI_OK) call
     $ perfm_error(retval,
     $     'perfm_start: could not stop papi')
      usn=util_wallsec()
      usn = usn - uso
      write(luout,*) 'Real_time: ', usn, 'secs'
      ll=inp_strlen(eventname(1))
      write(luout,*) eventname(1)(1:ll),'      : ',values(1)
      write(luout ,*) eventname(1)(1:ll),'/sec : ',values(1)/usn
#endif
#endif
      return
      end
