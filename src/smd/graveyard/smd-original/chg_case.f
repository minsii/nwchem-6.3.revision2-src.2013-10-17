      SUBROUTINE chg_case(char)

      implicit none

      integer upper_to_lower

      character*1 char

      upper_to_lower=iachar("a")-iachar("A")

      if("a"<=char.and.char<="z")then
        char=ACHAR(IACHAR(char)-upper_to_lower)
      endif

      return

      END
c $Id: chg_case.f 22502 2012-05-20 06:11:57Z d3y133 $
