*
* $Id: mmq.F 19707 2010-10-29 17:59:36Z d3y133 $
*

*     ***********************************
*     *                                 *
*     *           mmq_init              *
*     *                                 *
*     ***********************************
      subroutine mmq_init(rtdb)
      implicit none
      integer rtdb

#include "mafdecls.fh"
#include "rtdb.fh"
#include "errquit.fh"
#include "mmq.fh"

*     **** local variables ****
      integer l,ia,nzv
      character*5  element
      character*50 fname

*     **** external functions *****
      integer     ion_nkatm
      character*4 ion_atom
      external    ion_nkatm
      external    ion_atom

      nzv = ion_nkatm()
      if (.not.MA_alloc_get(mt_dbl,(nzv),'zv',zv(2),zv(1)))
     >   call errquit('mmq_init:out of heap memory',0, MA_ERR)

      do ia = 1,nzv
         element = ion_atom(ia)
         l = index(element,' ') - 1
         fname = element(1:l)//':zv'
         if (.not.rtdb_get(rtdb,fname,mt_dbl,1,dbl_mb(zv(1)+ia-1)))
     >     dbl_mb(zv(1)+ia-1) = 0.0
      end do

      return
      end


*     ***********************************
*     *                                 *
*     *           mmq_end               *
*     *                                 *
*     ***********************************
      subroutine mmq_end()
      implicit none

#include "errquit.fh"
#include "mafdecls.fh"
#include "mmq.fh"

      if (.not.MA_free_heap(zv(2)))
     >  call errquit('mmq_end:error freeing heap memory',0,MA_ERR)
      return
      end

*     ***********************************
*     *                                 *
*     *            mmq_zv               *
*     *                                 *
*     ***********************************
      real*8 function mmq_zv(ia)
      implicit none
      integer ia

#include "mafdecls.fh"
#include "mmq.fh"

      mmq_zv = dbl_mb(zv(1)+ia-1)
      return
      end

*     ***********************************
*     *                                 *
*     *            mmq_zv_ptr           *
*     *                                 *
*     ***********************************
      integer function mmq_zv_ptr()
      implicit none

#include "mmq.fh"

      mmq_zv_ptr = zv(1)
      return
      end
