      SUBROUTINE stpr_wrtsq (IUNIT,A,LEN,IERR)
c $Id: stpr_wrtsq.F 19708 2010-10-29 18:04:21Z d3y133 $
      INTEGER LEN, IUNIT, IERR
      REAL*8 A(LEN)
#if defined (SGITFP)
      WRITE (IUNIT, ERR=10) (A(IERR),IERR=1,LEN)
#else
      WRITE (IUNIT, ERR=10) A
#endif
      IERR = 0
      RETURN
   10 CONTINUE
      IERR = 1
      RETURN
      END
