c
c $Id: chg_case.f 19707 2010-10-29 17:59:36Z d3y133 $
c
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
