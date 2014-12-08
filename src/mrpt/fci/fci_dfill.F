*
* $Id: fci_dfill.F 19708 2010-10-29 18:04:21Z d3y133 $
*
      subroutine dfill(val,x,iskip,n)
      implicit none
      double precision val, x(*)
      integer iskip, n, ipt, i
c      
      ipt=1
      do 10 i=1,n
          x(ipt)=val
10        ipt=ipt+iskip
      return
      end
