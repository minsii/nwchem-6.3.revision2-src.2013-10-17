      SUBROUTINE ccsdt_lambda2_5_2_1(d_a,k_a_offset,d_c,k_c_offset)
C     $Id: ccsdt_lambda2_5_2_1.F 24183 2013-05-03 23:47:08Z edo $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i2 ( h3 p5 )_f + = 1 * f ( h3 p5 )_f
      IMPLICIT NONE
#include "global.fh"
#include "mafdecls.fh"
#include "sym.fh"
#include "errquit.fh"
#include "tce.fh"
      INTEGER d_a
      INTEGER k_a_offset
      INTEGER d_c
      INTEGER k_c_offset
      INTEGER NXTASK
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER h3b
      INTEGER p5b
      INTEGER dimc
      INTEGER h3b_1
      INTEGER p5b_1
      INTEGER dim_common
      INTEGER dima_sort
      INTEGER dima
      INTEGER l_a_sort
      INTEGER k_a_sort
      INTEGER l_a
      INTEGER k_a
      INTEGER l_c
      INTEGER k_c
      EXTERNAL NXTASK
      nprocs = GA_NNODES()
      count = 0
      next = NXTASK(nprocs,1)
      DO h3b = 1,noab
      DO p5b = noab+1,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h3b-1)+int_mb(k_spin+p5b-1
     &).ne.4)) THEN
      IF (int_mb(k_spin+h3b-1) .eq. int_mb(k_spin+p5b-1)) THEN
      IF (ieor(int_mb(k_sym+h3b-1),int_mb(k_sym+p5b-1)) .eq. irrep_f) TH
     &EN
      dimc = int_mb(k_range+h3b-1) * int_mb(k_range+p5b-1)
      CALL TCE_RESTRICTED_2(h3b,p5b,h3b_1,p5b_1)
      dim_common = 1
      dima_sort = int_mb(k_range+h3b-1) * int_mb(k_range+p5b-1)
      dima = dim_common * dima_sort
      IF (dima .gt. 0) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('ccsdt_lambda2_5_2_1',0,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &ccsdt_lambda2_5_2_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p5b_1
     & - 1 + (noab+nvab) * (h3b_1 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+h3b-1)
     &,int_mb(k_range+p5b-1),2,1,1.0d0)
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('ccsdt_lambda2_5_2_1',2,M
     &A_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &ccsdt_lambda2_5_2_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range+p5b-1)
     &,int_mb(k_range+h3b-1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p5b -
     & noab - 1 + nvab * (h3b - 1)))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('ccsdt_lambda2_5_2_1',4,M
     &A_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('ccsdt_lambda2_5_2_1
     &',5,MA_ERR)
      END IF
      END IF
      END IF
      END IF
      next = NXTASK(nprocs,1)
      END IF
      count = count + 1
      END DO
      END DO
      next = NXTASK(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
