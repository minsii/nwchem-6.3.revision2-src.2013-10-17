      subroutine selci_icopy(n,x,ix,y,iy)
      implicit integer (a-z)
*
* $Id: selci_icopy.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      dimension x(*),y(*)
c
      ixx = 1
      iyy = 1
      do 10 i = 1,n
         y(iyy) = x(ixx)
         ixx = ixx + ix
         iyy = iyy + iy
 10   continue
c
      return
      end
