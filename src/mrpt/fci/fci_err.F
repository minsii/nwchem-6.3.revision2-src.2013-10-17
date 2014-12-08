*
* $Id: fci_err.F 19708 2010-10-29 18:04:21Z d3y133 $
*
      subroutine fci_err(string, code)
      implicit none
      character*(*) string
      integer code
c
      write(6,1) string, code
 1    format(/
     $     ' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'/
     $     1x, a, 1x, i8/
     $     ' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'/
     $     )
c
      stop 99
c
      end
