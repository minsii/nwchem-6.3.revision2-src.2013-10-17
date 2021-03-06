*
* $Id: fci_spnfrc.F 19708 2010-10-29 18:04:21Z d3y133 $
*
      subroutine fci_spin_force(c)
      implicit none
#include "fciinfo.fh"
      double precision c(ndets) ! [in/out] Determinant CI vector
c     
c     Force determinant CI vector (using symmetry) to be spin adapted
c     by projecting to and from the CSF space.  When done, renormalize.
c     
      double precision work(ncsfmx), dci
      integer iocc(nactmx), iwalk, idim, ns, ioff, sym
c     
      call fci_tstart(10,.false.)
      do iwalk = 1,nwalko
         call fci_owalk_info(iwalk, iocc, ns, ioff, idim, sym)
         if (sym.eq.statesym .and. idim.gt.1) then
            call fci_spin_adapt(ns, 1, c(ioff+1), work)
            call fci_spin_adapt(ns, 2, c(ioff+1), work)
         endif
      enddo
c     
      call renorm(ndets, c, dci)
      if (dci.lt. 1.0d-4) call fci_err(' spnfrc dci small ',ndets)
c     
      call fci_tfinish(10,.false.)
c     
      end
