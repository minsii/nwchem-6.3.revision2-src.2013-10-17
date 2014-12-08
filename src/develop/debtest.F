      Logical Function DEBTest(RTDB)
C$Id: debtest.F 19708 2010-10-29 18:04:21Z d3y133 $
      Implicit NONE
      Integer RTDB
      Logical Status
      Logical SCF, RIMP2
      External SCF, RIMP2
c$$$      Integer LUOut
c$$$      Parameter (LuOut = 6)
#include "stdio.fh"
*********************************************#include "stdio_init.fh"
      Status = SCF( RTDB)
      Status = RIMP2( RTDB)
      DEBTest = Status
      Return
      End
