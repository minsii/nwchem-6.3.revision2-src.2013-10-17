      integer function selci_idmin(n,a,ia)
*
* $Id: idmin.f 19747 2010-11-03 18:58:10Z d3p852 $
*
      real *8 a(ia,*)
      real *8 val
c
c     return index of minimum value in array a
c
      val = a(1,1)
      ind = 1
c
      do 10 i = 1,n
         if (a(1,i).lt.val) then
            val = a(1,i)
            ind = i
         endif
10    continue
c
      selci_idmin = ind
      end
