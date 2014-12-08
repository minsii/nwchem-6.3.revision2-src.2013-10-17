      subroutine ccsd_mktau(nocc,nvir,av,t1,t2,tau)
C     $Id: ccsd_mktau.f 19708 2010-10-29 18:04:21Z d3y133 $
      implicit none
      integer nocc,nvir,av
      double precision t1(*),t2(*),tau(*)
c
      integer bv,i,j,icnt
c
      icnt=0
      do bv=1,nvir
       do i=1,nocc
        do j=1,nocc
         icnt=icnt+1
         tau(icnt)=t2(icnt)+t1((av-1)*nocc+i)*t1((bv-1)*nocc+j)
        enddo
       enddo
      enddo
c
      return
      end

