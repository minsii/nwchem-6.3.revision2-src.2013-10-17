      SUBROUTINE stpr_readsq (IUNIT,A,LEN,IERR)
c $Id: stpr_readsq.F 19708 2010-10-29 18:04:21Z d3y133 $
      INTEGER LEN, IUNIT, IERR
      REAL*8 A(LEN)
#if defined (SGITFP)
      READ (IUNIT, END=10, ERR=10) (A(IERR),IERR=1,LEN)
#else
      READ (IUNIT, END=10, ERR=10) A
#endif
      IERR = 0
      RETURN
   10 CONTINUE
      IERR = 1
      RETURN
      END
