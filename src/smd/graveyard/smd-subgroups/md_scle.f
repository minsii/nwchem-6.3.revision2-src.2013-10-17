c
c $Id: md_scle.f 19707 2010-10-29 17:59:36Z d3y133 $
c

      SUBROUTINE md_scle(ntshel)

      implicit none

      integer i,ntshel

      if(ntshel.gt.0)then

       do i=1,4

        call com_motion()
        call scle_velo()
        call shll_qnch(ntshel)

       enddo

      else

       call com_motion()
       call scle_velo()

      endif

      return

      END
