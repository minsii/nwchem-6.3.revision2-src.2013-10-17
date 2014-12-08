      SUBROUTINE stpr_stepper(A,ILEFT,G,C,ETOT,NATD,
     &    CONVGE,CONVGG,CONVGGM,
     &    converged, rtdb, step_number)
c $Id: stpr_stepper.f 19708 2010-10-29 18:04:21Z d3y133 $
      IMPLICIT  REAL*8(A-H,O-Z), INTEGER(I-N)
      integer rtdb
      integer step_number
      logical converged
      DIMENSION G(NATD*3),A(ILEFT)
      DIMENSION C(3,NATD)
C
C     Calculate number of 64 bit words that core will need for
C     the calculation.
C
      CALL stpr_cneed (INEED, NATD)
C
C     Convergence tolerances.
C
      IF (INEED.GT.ILEFT) THEN
        WRITE(6,*)'   NOT ENOUGH MEMORY NEED ',INEED-ILEFT,
     *         ' MORE WORDS!'
        stop
      ELSE
        CALL stpr_stepcor(A,INEED,G,C,ETOT,NATD,CONVGE,CONVGG,CONVGGM,
     &      converged,rtdb, step_number)
      ENDIF
      RETURN
      END
