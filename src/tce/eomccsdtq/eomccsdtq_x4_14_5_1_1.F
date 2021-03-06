      SUBROUTINE eomccsdtq_x4_14_5_1_1(d_a,k_a_offset,d_c,k_c_offset)
C     $Id: eomccsdtq_x4_14_5_1_1.F 24183 2013-05-03 23:47:08Z edo $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i3 ( h12 p5 p10 p14 )_v + = 1 * v ( h12 p5 p10 p14 )_v
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
      INTEGER p5b
      INTEGER h12b
      INTEGER p10b
      INTEGER p14b
      INTEGER dimc
      INTEGER p5b_1
      INTEGER h12b_1
      INTEGER p10b_1
      INTEGER p14b_1
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
      DO p5b = noab+1,noab+nvab
      DO h12b = 1,noab
      DO p10b = noab+1,noab+nvab
      DO p14b = p10b,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+p5b-1)+int_mb(k_spin+h12b-
     &1)+int_mb(k_spin+p10b-1)+int_mb(k_spin+p14b-1).ne.8)) THEN
      IF (int_mb(k_spin+p5b-1)+int_mb(k_spin+h12b-1) .eq. int_mb(k_spin+
     &p10b-1)+int_mb(k_spin+p14b-1)) THEN
      IF (ieor(int_mb(k_sym+p5b-1),ieor(int_mb(k_sym+h12b-1),ieor(int_mb
     &(k_sym+p10b-1),int_mb(k_sym+p14b-1)))) .eq. irrep_v) THEN
      dimc = int_mb(k_range+p5b-1) * int_mb(k_range+h12b-1) * int_mb(k_r
     &ange+p10b-1) * int_mb(k_range+p14b-1)
      CALL TCE_RESTRICTED_4(p5b,h12b,p10b,p14b,p5b_1,h12b_1,p10b_1,p14b_
     &1)
      dim_common = 1
      dima_sort = int_mb(k_range+p5b-1) * int_mb(k_range+h12b-1) * int_m
     &b(k_range+p10b-1) * int_mb(k_range+p14b-1)
      dima = dim_common * dima_sort
      IF (dima .gt. 0) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_14_5_1_1',0,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &eomccsdtq_x4_14_5_1_1',1,MA_ERR)
      IF ((h12b .le. p5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p14b_
     &1 - 1 + (noab+nvab) * (p10b_1 - 1 + (noab+nvab) * (p5b_1 - 1 + (no
     &ab+nvab) * (h12b_1 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+h12b-1
     &),int_mb(k_range+p5b-1),int_mb(k_range+p10b-1),int_mb(k_range+p14b
     &-1),4,3,1,2,1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('eomccsdtq_x4_14_5_1_1',2
     &,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &eomccsdtq_x4_14_5_1_1',3,MA_ERR)
      CALL TCE_SORT_4(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range+p14b-1
     &),int_mb(k_range+p10b-1),int_mb(k_range+h12b-1),int_mb(k_range+p5b
     &-1),4,3,2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p14b 
     &- noab - 1 + nvab * (p10b - noab - 1 + nvab * (h12b - 1 + noab * (
     &p5b - noab - 1)))))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('eomccsdtq_x4_14_5_1_1',4
     &,MA_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('eomccsdtq_x4_14_5_1
     &_1',5,MA_ERR)
      END IF
      END IF
      END IF
      END IF
      next = NXTASK(nprocs,1)
      END IF
      count = count + 1
      END DO
      END DO
      END DO
      END DO
      next = NXTASK(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
