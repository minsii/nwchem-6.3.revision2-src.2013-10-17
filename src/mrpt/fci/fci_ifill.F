*
* $Id: fci_ifill.F 19708 2010-10-29 18:04:21Z d3y133 $
*
      subroutine ifill(ival,ix,iskip,n)
      implicit none
      integer ival, ix(*), iskip, n, ipt, i
      ipt=1
      do 10 i=1,n
          ix(ipt)=ival
10        ipt=ipt+iskip
      return
      end
