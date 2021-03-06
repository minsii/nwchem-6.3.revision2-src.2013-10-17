      SUBROUTINE alpha_2_7_5(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_offse
     &t)
C     $Id: alpha_2_7_5.F 24183 2013-05-03 23:47:08Z edo $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i1 ( h7 p10 h9 h11 )_ytratrb + = 4 * Sum ( h5 p3 ) * trb ( p3 p10 h5 h11 )_trb * i2 ( h5 h7 h9 p3 )_ytra
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
      INTEGER p10b
      INTEGER h7b
      INTEGER h11b
      INTEGER h9b
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER p3b
      INTEGER h5b
      INTEGER p10b_1
      INTEGER p3b_1
      INTEGER h11b_1
      INTEGER h5b_1
      INTEGER h7b_2
      INTEGER h5b_2
      INTEGER h9b_2
      INTEGER p3b_2
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
      DO p10b = noab+1,noab+nvab
      DO h7b = 1,noab
      DO h11b = 1,noab
      DO h9b = 1,noab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h7b-1)+int_mb(k_spin+p10b-
     &1)+int_mb(k_spin+h9b-1)+int_mb(k_spin+h11b-1).ne.8)) THEN
      IF (int_mb(k_spin+h7b-1)+int_mb(k_spin+p10b-1) .eq. int_mb(k_spin+
     &h9b-1)+int_mb(k_spin+h11b-1)) THEN
      IF (ieor(int_mb(k_sym+h7b-1),ieor(int_mb(k_sym+p10b-1),ieor(int_mb
     &(k_sym+h9b-1),int_mb(k_sym+h11b-1)))) .eq. ieor(irrep_y,ieor(irrep
     &_tra,irrep_trb))) THEN
      dimc = int_mb(k_range+h7b-1) * int_mb(k_range+p10b-1) * int_mb(k_r
     &ange+h9b-1) * int_mb(k_range+h11b-1)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('alpha_2_7_5',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p3b = noab+1,noab+nvab
      DO h5b = 1,noab
      IF (int_mb(k_spin+p10b-1)+int_mb(k_spin+p3b-1) .eq. int_mb(k_spin+
     &h11b-1)+int_mb(k_spin+h5b-1)) THEN
      IF (ieor(int_mb(k_sym+p10b-1),ieor(int_mb(k_sym+p3b-1),ieor(int_mb
     &(k_sym+h11b-1),int_mb(k_sym+h5b-1)))) .eq. irrep_trb) THEN
      CALL TCE_RESTRICTED_4(p10b,p3b,h11b,h5b,p10b_1,p3b_1,h11b_1,h5b_1)
      CALL TCE_RESTRICTED_4(h7b,h5b,h9b,p3b,h7b_2,h5b_2,h9b_2,p3b_2)
      dim_common = int_mb(k_range+p3b-1) * int_mb(k_range+h5b-1)
      dima_sort = int_mb(k_range+p10b-1) * int_mb(k_range+h11b-1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range+h7b-1) * int_mb(k_range+h9b-1)
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('alpha_2_7_5',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &alpha_2_7_5',2,MA_ERR)
      IF ((p3b .le. p10b) .and. (h5b .le. h11b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h11b_
     &1 - 1 + noab * (h5b_1 - 1 + noab * (p10b_1 - noab - 1 + nvab * (p3
     &b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+p10b-1),int_mb(k_range+h5b-1),int_mb(k_range+h11b-
     &1),4,2,3,1,1.0d0)
      END IF
      IF ((p3b .le. p10b) .and. (h11b .lt. h5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1
     & - 1 + noab * (h11b_1 - 1 + noab * (p10b_1 - noab - 1 + nvab * (p3
     &b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+p10b-1),int_mb(k_range+h11b-1),int_mb(k_range+h5b-
     &1),3,2,4,1,-1.0d0)
      END IF
      IF ((p10b .lt. p3b) .and. (h5b .le. h11b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h11b_
     &1 - 1 + noab * (h5b_1 - 1 + noab * (p3b_1 - noab - 1 + nvab * (p10
     &b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p10b-1
     &),int_mb(k_range+p3b-1),int_mb(k_range+h5b-1),int_mb(k_range+h11b-
     &1),4,1,3,2,-1.0d0)
      END IF
      IF ((p10b .lt. p3b) .and. (h11b .lt. h5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h5b_1
     & - 1 + noab * (h11b_1 - 1 + noab * (p3b_1 - noab - 1 + nvab * (p10
     &b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p10b-1
     &),int_mb(k_range+p3b-1),int_mb(k_range+h11b-1),int_mb(k_range+h5b-
     &1),3,1,4,2,1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('alpha_2_7_5',3,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('alpha_2_7_5',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &alpha_2_7_5',5,MA_ERR)
      IF ((h5b .le. h7b) .and. (h9b .le. p3b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2
     & - noab - 1 + nvab * (h9b_2 - 1 + noab * (h7b_2 - 1 + noab * (h5b_
     &2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h5b-1)
     &,int_mb(k_range+h7b-1),int_mb(k_range+h9b-1),int_mb(k_range+p3b-1)
     &,3,2,1,4,1.0d0)
      END IF
      IF ((h7b .lt. h5b) .and. (h9b .le. p3b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p3b_2
     & - noab - 1 + nvab * (h9b_2 - 1 + noab * (h5b_2 - 1 + noab * (h7b_
     &2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h7b-1)
     &,int_mb(k_range+h5b-1),int_mb(k_range+h9b-1),int_mb(k_range+p3b-1)
     &,3,1,2,4,-1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('alpha_2_7_5',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a
     &_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sor
     &t),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('alpha_2_7_5',7,MA_E
     &RR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('alpha_2_7_5',8,MA_E
     &RR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &alpha_2_7_5',9,MA_ERR)
      IF ((h9b .le. h11b)) THEN
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h7b-1),int_mb(k_range+h11b-1),int_mb(k_range+p10b-
     &1),2,4,1,3,2.0d0/1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h11b 
     &- 1 + noab * (h9b - 1 + noab * (p10b - noab - 1 + nvab * (h7b - 1)
     &))))
      END IF
      IF ((h11b .le. h9b)) THEN
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h7b-1),int_mb(k_range+h11b-1),int_mb(k_range+p10b-
     &1),2,4,3,1,-2.0d0/1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h9b -
     & 1 + noab * (h11b - 1 + noab * (p10b - noab - 1 + nvab * (h7b - 1)
     &))))
      END IF
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('alpha_2_7_5',10,MA_ERR)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('alpha_2_7_5',11,MA_
     &ERR)
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
