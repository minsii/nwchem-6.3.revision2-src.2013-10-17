      DOUBLE PRECISION FUNCTION YLANGE( NORM, M, N, A, LDA, WORK )
c
* $Id: ylange.F 19697 2010-10-29 16:57:34Z d3y133 $
c
      implicit none
#include "y64.fh"
      CHARACTER          NORM
      INTEGER            LDA, M, N
      DOUBLE PRECISION   A( LDA, * ), WORK( * )
c
      INTGR4            LDA4, M4, N4
      external dlange
      double precision dlange
c
      m4=m
      n4=n
      lda4=lda
c
      ylange=DLANGE( NORM, M4, N4, A, LDA4, WORK )
      return
      end
