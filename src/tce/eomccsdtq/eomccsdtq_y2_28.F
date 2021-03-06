      SUBROUTINE eomccsdtq_y2_28(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_o
     &ffset)
C     $Id: eomccsdtq_y2_28.F 24183 2013-05-03 23:47:08Z edo $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i0 ( h3 h4 p1 p2 )_yttv + = -1/2 * Sum ( p13 p14 ) * i1 ( p13 p14 p1 p2 )_ytt * v ( h3 h4 p13 p14 )_v
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
      INTEGER h3b
      INTEGER h4b
      INTEGER p1b
      INTEGER p2b
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER p13b
      INTEGER p14b
      INTEGER p13b_1
      INTEGER p14b_1
      INTEGER p1b_1
      INTEGER p2b_1
      INTEGER h3b_2
      INTEGER h4b_2
      INTEGER p13b_2
      INTEGER p14b_2
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
      INTEGER nsuperp(2)
      INTEGER isuperp
      INTEGER l_c
      INTEGER k_c
      DOUBLE PRECISION FACTORIAL
      EXTERNAL NXTASK
      EXTERNAL FACTORIAL
      nprocs = GA_NNODES()
      count = 0
      next = NXTASK(nprocs,1)
      DO h3b = 1,noab
      DO h4b = h3b,noab
      DO p1b = noab+1,noab+nvab
      DO p2b = p1b,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h3b-1)+int_mb(k_spin+h4b-1
     &)+int_mb(k_spin+p1b-1)+int_mb(k_spin+p2b-1).ne.8)) THEN
      IF (int_mb(k_spin+h3b-1)+int_mb(k_spin+h4b-1) .eq. int_mb(k_spin+p
     &1b-1)+int_mb(k_spin+p2b-1)) THEN
      IF (ieor(int_mb(k_sym+h3b-1),ieor(int_mb(k_sym+h4b-1),ieor(int_mb(
     &k_sym+p1b-1),int_mb(k_sym+p2b-1)))) .eq. ieor(irrep_y,ieor(irrep_t
     &,ieor(irrep_t,irrep_v)))) THEN
      dimc = int_mb(k_range+h3b-1) * int_mb(k_range+h4b-1) * int_mb(k_ra
     &nge+p1b-1) * int_mb(k_range+p2b-1)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('eomccsdtq_y2_28',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p13b = noab+1,noab+nvab
      DO p14b = p13b,noab+nvab
      IF (int_mb(k_spin+p13b-1)+int_mb(k_spin+p14b-1) .eq. int_mb(k_spin
     &+p1b-1)+int_mb(k_spin+p2b-1)) THEN
      IF (ieor(int_mb(k_sym+p13b-1),ieor(int_mb(k_sym+p14b-1),ieor(int_m
     &b(k_sym+p1b-1),int_mb(k_sym+p2b-1)))) .eq. ieor(irrep_y,ieor(irrep
     &_t,irrep_t))) THEN
      CALL TCE_RESTRICTED_4(p13b,p14b,p1b,p2b,p13b_1,p14b_1,p1b_1,p2b_1)
      CALL TCE_RESTRICTED_4(h3b,h4b,p13b,p14b,h3b_2,h4b_2,p13b_2,p14b_2)
      dim_common = int_mb(k_range+p13b-1) * int_mb(k_range+p14b-1)
      dima_sort = int_mb(k_range+p1b-1) * int_mb(k_range+p2b-1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range+h3b-1) * int_mb(k_range+h4b-1)
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('eomccsdtq_y2_28',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &eomccsdtq_y2_28',2,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(p2b_1
     & - noab - 1 + nvab * (p1b_1 - noab - 1 + nvab * (p14b_1 - noab - 1
     & + nvab * (p13b_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p13b-1
     &),int_mb(k_range+p14b-1),int_mb(k_range+p1b-1),int_mb(k_range+p2b-
     &1),4,3,2,1,1.0d0)
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('eomccsdtq_y2_28',3,MA_ER
     &R)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('eomccsdtq_y2_28',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &eomccsdtq_y2_28',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p14b_
     &2 - 1 + (noab+nvab) * (p13b_2 - 1 + (noab+nvab) * (h4b_2 - 1 + (no
     &ab+nvab) * (h3b_2 - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h3b-1)
     &,int_mb(k_range+h4b-1),int_mb(k_range+p13b-1),int_mb(k_range+p14b-
     &1),2,1,4,3,1.0d0)
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('eomccsdtq_y2_28',6,MA_ER
     &R)
      nsuperp(1) = 1
      nsuperp(2) = 1
      isuperp = 1
      IF (p13b .eq. p14b) THEN
      nsuperp(isuperp) = nsuperp(isuperp) + 1
      ELSE
      isuperp = isuperp + 1
      END IF
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,2.0d0/FACTORIAL(
     &nsuperp(1))/FACTORIAL(nsuperp(2)),dbl_mb(k_a_sort),dim_common,dbl_
     &mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('eomccsdtq_y2_28',7,
     &MA_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('eomccsdtq_y2_28',8,
     &MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &eomccsdtq_y2_28',9,MA_ERR)
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+h4b-1)
     &,int_mb(k_range+h3b-1),int_mb(k_range+p2b-1),int_mb(k_range+p1b-1)
     &,2,1,4,3,-1.0d0/2.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p2b -
     & noab - 1 + nvab * (p1b - noab - 1 + nvab * (h4b - 1 + noab * (h3b
     & - 1)))))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('eomccsdtq_y2_28',10,MA_E
     &RR)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('eomccsdtq_y2_28',11
     &,MA_ERR)
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
