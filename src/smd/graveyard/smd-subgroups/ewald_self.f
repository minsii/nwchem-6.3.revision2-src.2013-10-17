c
c $Id: ewald_self.f 19707 2010-10-29 17:59:36Z d3y133 $
c

      SUBROUTINE ewald_self(ewald1)

      implicit none

      include 'p_array.inc'
      include 'p_const.inc'
      include 'cm_atom.inc'
      include 'cm_ewld.inc'

      integer i,iatm

      real*8 ewald1

      ewald1=0.0

      do i=1,natms

       iatm=atmtype(i)
       ewald1=ewald1+typchge(iatm)*typchge(iatm)

      enddo

      ewald1=-convfct1*alpha*ewald1/sqrpi

      return

      END
