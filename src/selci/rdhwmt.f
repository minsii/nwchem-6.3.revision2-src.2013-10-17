      subroutine selci_rdhwmt(iflwmt,mmulti, nsmax, nf, nfmax, nfmax2)
*
* $Id: rdhwmt.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      dimension nf(0:32)
c
      call ifill(33,0,nf,1)
      read (iflwmt,*) mmulti, nsmax
      read (iflwmt,*) (nf(i),i=mod(nsmax,2),nsmax,2)
      nfmax = nf(nsmax)
      nfmax2 = nf(nsmax-2)
c
      end
