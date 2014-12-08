      SUBROUTINE ewald_setp()

      implicit none

      include 'p_const.inc'
      include 'cm_latt.inc'
      include 'cm_ewld.inc'

      real*8 axb1,axb2,axb3,bxc1,bxc2,bxc3,cxa1,cxa2,cxa3
      integer i

      ralphsq=-0.25/alpha**2

      write(*,*) "rlatt"
      write(*,*) (rlatt(i,1),i=1,3)
      write(*,*) (rlatt(i,2),i=1,3)
      write(*,*) (rlatt(i,3),i=1,3)


      axb1=rlatt(2,1)*rlatt(3,2)-rlatt(3,1)*rlatt(2,2)
      axb2=rlatt(3,1)*rlatt(1,2)-rlatt(1,1)*rlatt(3,2)
      axb3=rlatt(1,1)*rlatt(2,2)-rlatt(2,1)*rlatt(1,2)
      bxc1=rlatt(2,2)*rlatt(3,3)-rlatt(3,2)*rlatt(2,3)
      bxc2=rlatt(3,2)*rlatt(1,3)-rlatt(1,2)*rlatt(3,3)
      bxc3=rlatt(1,2)*rlatt(2,3)-rlatt(2,2)*rlatt(1,3)
      cxa1=rlatt(2,3)*rlatt(3,1)-rlatt(2,1)*rlatt(3,3)
      cxa2=rlatt(1,1)*rlatt(3,3)-rlatt(3,1)*rlatt(1,3)
      cxa3=rlatt(2,1)*rlatt(1,3)-rlatt(1,1)*rlatt(2,3)

      rvol=abs(rlatt(1,1)*bxc1+rlatt(2,1)*bxc2+rlatt(3,1)*bxc3)

      xvector=rvol/sqrt(bxc1*bxc1+bxc2*bxc2+bxc3*bxc3)
      yvector=rvol/sqrt(cxa1*cxa1+cxa2*cxa2+cxa3*cxa3)
      zvector=rvol/sqrt(axb1*axb1+axb2*axb2+axb3*axb3)

      rksqmax=min(real(kmaxx)*xvector,
     $            real(kmaxy)*yvector,
     $            real(kmaxz)*zvector)
      rksqmax=rksqmax*1.05*twopi
      rksqmax=rksqmax**2

      write(*,*) "ewald data"
      write(*,*) "kmax",kmaxx,kmaxy,kmaxz
      write(*,*) "alpha",alpha
      write(*,*) "ralphsq",ralphsq
      write(*,*) "rksqmax",rksqmax

      return

      END
c $Id: ewald_setp.f 22502 2012-05-20 06:11:57Z d3y133 $
