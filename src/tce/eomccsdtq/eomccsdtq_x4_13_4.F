      SUBROUTINE eomccsdtq_x4_13_4(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c
     &_offset)
C     $Id: eomccsdtq_x4_13_4.F 24183 2013-05-03 23:47:08Z edo $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i1 ( h14 p5 h1 h2 )_vx + = 1 * P( 2 ) * Sum ( h12 p9 ) * x ( p5 p9 h1 h12 )_x * i2 ( h12 h14 h2 p9 )_v
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
      INTEGER p5b
      INTEGER h14b
      INTEGER h1b
      INTEGER h2b
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER p9b
      INTEGER h12b
      INTEGER p5b_1
      INTEGER p9b_1
      INTEGER h1b_1
      INTEGER h12b_1
      INTEGER h14b_2
      INTEGER h12b_2
      INTEGER h2b_2
      INTEGER p9b_2
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
      DO p5b = noab+1,noab+nvab
      DO h14b = 1,noab
      DO h1b = 1,noab
      DO h2b = 1,noab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+p5b-1)+int_mb(k_spin+h14b-
     &1)+int_mb(k_spin+h1b-1)+int_mb(k_spin+h2b-1).ne.8)) THEN
      IF (int_mb(k_spin+p5b-1)+int_mb(k_spin+h14b-1) .eq. int_mb(k_spin+
     &h1b-1)+int_mb(k_spin+h2b-1)) THEN
      IF (ieor(int_mb(k_sym+p5b-1),ieor(int_mb(k_sym+h14b-1),ieor(int_mb
     &(k_sym+h1b-1),int_mb(k_sym+h2b-1)))) .eq. ieor(irrep_v,irrep_x)) T
     &HEN
      dimc = int_mb(k_range+p5b-1) * int_mb(k_range+h14b-1) * int_mb(k_r
     &ange+h1b-1) * int_mb(k_range+h2b-1)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_13_4',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p9b = noab+1,noab+nvab
      DO h12b = 1,noab
      IF (int_mb(k_spin+p5b-1)+int_mb(k_spin+p9b-1) .eq. int_mb(k_spin+h
     &1b-1)+int_mb(k_spin+h12b-1)) THEN
      IF (ieor(int_mb(k_sym+p5b-1),ieor(int_mb(k_sym+p9b-1),ieor(int_mb(
     &k_sym+h1b-1),int_mb(k_sym+h12b-1)))) .eq. irrep_x) THEN
      CALL TCE_RESTRICTED_4(p5b,p9b,h1b,h12b,p5b_1,p9b_1,h1b_1,h12b_1)
      CALL TCE_RESTRICTED_4(h14b,h12b,h2b,p9b,h14b_2,h12b_2,h2b_2,p9b_2)
      dim_common = int_mb(k_range+p9b-1) * int_mb(k_range+h12b-1)
      dima_sort = int_mb(k_range+p5b-1) * int_mb(k_range+h1b-1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range+h14b-1) * int_mb(k_range+h2b-1)
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_13_4',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &eomccsdtq_x4_13_4',2,MA_ERR)
      IF ((p9b .lt. p5b) .and. (h12b .lt. h1b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1
     & - 1 + noab * (h12b_1 - 1 + noab * (p5b_1 - noab - 1 + nvab * (p9b
     &_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p9b-1)
     &,int_mb(k_range+p5b-1),int_mb(k_range+h12b-1),int_mb(k_range+h1b-1
     &),4,2,3,1,1.0d0)
      END IF
      IF ((p9b .lt. p5b) .and. (h1b .le. h12b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h12b_
     &1 - 1 + noab * (h1b_1 - 1 + noab * (p5b_1 - noab - 1 + nvab * (p9b
     &_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p9b-1)
     &,int_mb(k_range+p5b-1),int_mb(k_range+h1b-1),int_mb(k_range+h12b-1
     &),3,2,4,1,-1.0d0)
      END IF
      IF ((p5b .le. p9b) .and. (h12b .lt. h1b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h1b_1
     & - 1 + noab * (h12b_1 - 1 + noab * (p9b_1 - noab - 1 + nvab * (p5b
     &_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p5b-1)
     &,int_mb(k_range+p9b-1),int_mb(k_range+h12b-1),int_mb(k_range+h1b-1
     &),4,1,3,2,-1.0d0)
      END IF
      IF ((p5b .le. p9b) .and. (h1b .le. h12b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h12b_
     &1 - 1 + noab * (h1b_1 - 1 + noab * (p9b_1 - noab - 1 + nvab * (p5b
     &_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p5b-1)
     &,int_mb(k_range+p9b-1),int_mb(k_range+h1b-1),int_mb(k_range+h12b-1
     &),3,1,4,2,1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('eomccsdtq_x4_13_4',3,MA_
     &ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('eomccsdtq_x4_13_4',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &eomccsdtq_x4_13_4',5,MA_ERR)
      IF ((h12b .le. h14b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p9b_2
     & - noab - 1 + nvab * (h2b_2 - 1 + noab * (h14b_2 - 1 + noab * (h12
     &b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h12b-1
     &),int_mb(k_range+h14b-1),int_mb(k_range+h2b-1),int_mb(k_range+p9b-
     &1),3,2,1,4,1.0d0)
      END IF
      IF ((h14b .lt. h12b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p9b_2
     & - noab - 1 + nvab * (h2b_2 - 1 + noab * (h12b_2 - 1 + noab * (h14
     &b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h14b-1
     &),int_mb(k_range+h12b-1),int_mb(k_range+h2b-1),int_mb(k_range+p9b-
     &1),3,1,2,4,-1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('eomccsdtq_x4_13_4',6,MA_
     &ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a
     &_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sor
     &t),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('eomccsdtq_x4_13_4',
     &7,MA_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('eomccsdtq_x4_13_4',
     &8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &eomccsdtq_x4_13_4',9,MA_ERR)
      IF ((h1b .le. h2b)) THEN
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+h2b-1)
     &,int_mb(k_range+h14b-1),int_mb(k_range+h1b-1),int_mb(k_range+p5b-1
     &),4,2,3,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h2b -
     & 1 + noab * (h1b - 1 + noab * (h14b - 1 + noab * (p5b - noab - 1))
     &)))
      END IF
      IF ((h2b .le. h1b)) THEN
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+h2b-1)
     &,int_mb(k_range+h14b-1),int_mb(k_range+h1b-1),int_mb(k_range+p5b-1
     &),4,2,1,3,-1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(h1b -
     & 1 + noab * (h2b - 1 + noab * (h14b - 1 + noab * (p5b - noab - 1))
     &)))
      END IF
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('eomccsdtq_x4_13_4',10,MA
     &_ERR)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('eomccsdtq_x4_13_4',
     &11,MA_ERR)
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
