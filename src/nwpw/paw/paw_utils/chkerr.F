c
c $Id: chkerr.F 19707 2010-10-29 17:59:36Z d3y133 $
c

      subroutine chkerr(string, icode)
      implicit none

      character*(*) string
      integer icode
      
      if(icode.ne.0) then
        print*,"aborting due to error ",string
      stop
      end if

      end
