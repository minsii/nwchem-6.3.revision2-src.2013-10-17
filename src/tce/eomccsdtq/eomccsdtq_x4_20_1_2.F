      SUBROUTINE eomccsdtq_x4_20_1_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k
     &_c_offset)
C     $Id: eomccsdtq_x4_20_1_2.F 24183 2013-05-03 23:47:08Z edo $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i2 ( h9 p13 )_vt + = -1 * Sum ( h11 p10 ) * t ( p10 h11 )_t * v ( h9 h11 p10 p13 )_v
      IMPLICIT NONE
#include "global.fh"
#include "mafdecls.fh"
#include "sym.fh"
#include "errquit.fh"
#include "tce.fh"
      INTEGER d_a
      INTEGER k_a_offset
      INTEGER d_b
      INTEGER k_b_offset
      INTEGER d_c
      INTEGER k_c_offset
      INTEGER NXTASK
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER h9b
      INTEGER p13b
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER p10b
      INTEGER h11b
      INTEGER p10b_1
      INTEGER h11b_1
      INTEGER h9b_2
      INTEGER h11b_2
      INTEGER p13b_2
      INTEGER p10b_2
      INTEGER dim_common
      INTEGER dima_sort
      INTEGER dima
      INTEGER dimb_sort
      INTEGER dimb
      INTEGER l_a_sort
      INTEGER k_a_sort
      INTEGER l_a
      INTEGER k_a
      INTEGER l_b_sort
      INTEGER k_b_sort
      INTEGER l_b
      INTEGER k_b
      INTEGER l_c
      INTEGER k_c
      EXTERNAL NXTASK
      nprocs = GA_NNODES()
      count = 0
      next = NXTASK(nprocs,1)
      DO h9b = 1,noab
      DO p13b = noab+1,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h9b-1)+int_mb(k_spin+p13b-
     &1).ne.4)) THEN
      IF (int_mb(k_spin+h9b-1) .eq. int_mb(k_spin+p13b-1)) THEN
      IF (ieor(int_mb(k_sym+h9b-1),int_mb(k_sym+p13b-1)) .eq. ieor(irrep
     &_v,irrep_t)) THEN
      dimc = int_mb(k_range+h9b-1) * int_mb(k_range+p13b-1)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_20_1_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p10b = noab+1,noab+nvab
      DO h11b = 1,noab
      IF (int_mb(k_spin+p10b-1) .eq. int_mb(k_spin+h11b-1)) THEN
      IF (ieor(int_mb(k_sym+p10b-1),int_mb(k_sym+h11b-1)) .eq. irrep_t) 
     &THEN
      CALL TCE_RESTRICTED_2(p10b,h11b,p10b_1,h11b_1)
      CALL TCE_RESTRICTED_4(h9b,h11b,p13b,p10b,h9b_2,h11b_2,p13b_2,p10b_
     &2)
      dim_common = int_mb(k_range+p10b-1) * int_mb(k_range+h11b-1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range+h9b-1) * int_mb(k_range+p13b-1)
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_20_1_2',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &eomccsdtq_x4_20_1_2',2,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h11b_
     &1 - 1 + noab * (p10b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p10b-1
     &),int_mb(k_range+h11b-1),2,1,1.0d0)
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('eomccsdtq_x4_20_1_2',3,M
     &A_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_20_1_2',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &eomccsdtq_x4_20_1_2',5,MA_ERR)
      IF ((h11b .lt. h9b) .and. (p10b .le. p13b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p13b_
     &2 - 1 + (noab+nvab) * (p10b_2 - 1 + (noab+nvab) * (h9b_2 - 1 + (no
     &ab+nvab) * (h11b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h9b-1),int_mb(k_range+p10b-1),int_mb(k_range+p13b
     &-1),4,2,1,3,-1.0d0)
      END IF
      IF ((h11b .lt. h9b) .and. (p13b .lt. p10b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p10b_
     &2 - 1 + (noab+nvab) * (p13b_2 - 1 + (noab+nvab) * (h9b_2 - 1 + (no
     &ab+nvab) * (h11b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h9b-1),int_mb(k_range+p13b-1),int_mb(k_range+p10b
     &-1),3,2,1,4,1.0d0)
      END IF
      IF ((h9b .le. h11b) .and. (p10b .le. p13b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p13b_
     &2 - 1 + (noab+nvab) * (p10b_2 - 1 + (noab+nvab) * (h11b_2 - 1 + (n
     &oab+nvab) * (h9b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h11b-1),int_mb(k_range+p10b-1),int_mb(k_range+p13b
     &-1),4,1,2,3,1.0d0)
      END IF
      IF ((h9b .le. h11b) .and. (p13b .lt. p10b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p10b_
     &2 - 1 + (noab+nvab) * (p13b_2 - 1 + (noab+nvab) * (h11b_2 - 1 + (n
     &oab+nvab) * (h9b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h11b-1),int_mb(k_range+p13b-1),int_mb(k_range+p10b
     &-1),3,1,2,4,-1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('eomccsdtq_x4_20_1_2',6,M
     &A_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a
     &_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sor
     &t),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('eomccsdtq_x4_20_1_2
     &',7,MA_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('eomccsdtq_x4_20_1_2
     &',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &eomccsdtq_x4_20_1_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+p13b-1
     &),int_mb(k_range+h9b-1),2,1,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p13b 
     &- noab - 1 + nvab * (h9b - 1)))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('eomccsdtq_x4_20_1_2',10,
     &MA_ERR)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('eomccsdtq_x4_20_1_2
     &',11,MA_ERR)
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
