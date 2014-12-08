      SUBROUTINE YSTERF( N, D, E, INFO )
c
* $Id: ysterf.F 19697 2010-10-29 16:57:34Z d3y133 $
c
      implicit none
#include "y64.fh"
      INTEGER            INFO, N
*     ..
*     .. Array Arguments ..
      DOUBLE PRECISION   D( * ), E( * )
*     ..
      INTGR4 n4,info4
c
      n4=n
c
      call dSTERF( N4, D, E, INFO4 )      
      info=info4
      return
      end
