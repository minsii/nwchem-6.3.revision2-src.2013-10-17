      subroutine mprint(rmat,idim,jdim)
C$Id: mprint.f 19708 2010-10-29 18:04:21Z d3y133 $
      implicit none
      integer idim, jdim
      double precision rmat(idim,jdim)
      integer i, j
c
      do 100 i=1,idim
         write(*,10) (rmat(i,j), j=1,jdim)
100   continue
10    format(19x,4(f10.6))
c
      end
