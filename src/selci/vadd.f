      subroutine selci_vadd(n,a,ia,b,ib,c,ic)
*
* $Id: vadd.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      real*8 a(ia,*),b(ib,*),c(ic,*)
c
c     c(*) = b(*) + a(*)
C
      do 10 m = 1,n
         c(1,m) = b(1,m) + a(1,m)
 10   continue
c
      end
