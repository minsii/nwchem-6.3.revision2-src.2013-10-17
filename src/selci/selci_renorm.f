      subroutine selci_renorm(n,a,ia,anorm)
*
* $Id: selci_renorm.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      implicit double precision (a-h,o-z)
      dimension a(*)
c
      aa = 0.0d0
      do 10 i = 1,1+(n-1)*ia,ia
         aa = aa + a(i)*a(i)
 10   continue
      anorm = sqrt(aa)
      if (anorm.ne.0.0d0) then
        scale = 1.0d0 / anorm
        do 20 i = 1,1+(n-1)*ia,ia
           a(i) = scale * a(i)
 20     continue
      endif
c
      end
