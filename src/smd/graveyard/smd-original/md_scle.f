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
c $Id: md_scle.f 22502 2012-05-20 06:11:57Z d3y133 $
