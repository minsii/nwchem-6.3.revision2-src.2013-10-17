*
* $Id: mympi.h 19695 2010-10-29 16:51:02Z d3y133 $
*
      integer me, nproc, ierr, status(MPI_STATUS_SIZE), istatus
      common /distvars/ me, nproc
      common /statvars/ ierr, istatus, status 
