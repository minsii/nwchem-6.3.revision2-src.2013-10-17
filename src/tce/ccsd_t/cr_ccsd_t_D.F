      SUBROUTINE cr_ccsd_t_D(d_c1,d_c2,d_i0,d_t1,d_t2,k_c1_offset,k_c2_o
     &ffset,k_i0_offset,k_t1_offset,k_t2_offset)
C     $Id: cr_ccsd_t_D.F 19699 2010-10-29 17:07:13Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i0 ( )_tc + = 1 * Sum ( p5 h6 ) * t ( p5 h6 )_t * i1 ( h6 p5 )_c
C         i1 ( h6 p5 )_c + = 1 * c+ ( h6 p5 )_c
C         i1 ( h6 p5 )_ct + = 1/2 * Sum ( h4 p3 ) * c+ ( h4 h6 p3 p5 )_c * t ( p3 h4 )_t
C     i0 ( )_tc + = 1/4 * Sum ( p3 p4 h1 h2 ) * c+ ( h1 h2 p3 p4 )_c * t ( p3 p4 h1 h2 )_t
      IMPLICIT NONE
#include "global.fh"
#include "mafdecls.fh"
#include "util.fh"
#include "errquit.fh"
#include "tce.fh"
      INTEGER d_i0
      INTEGER k_i0_offset
      INTEGER d_t1
      INTEGER k_t1_offset
      INTEGER d_i1
      INTEGER k_i1_offset
      INTEGER d_c2
      INTEGER k_c2_offset
      INTEGER d_t2
      INTEGER k_t2_offset
      INTEGER l_i1_offset
      INTEGER d_c1
      INTEGER k_c1_offset
      INTEGER size_i1
      CHARACTER*255 filename
      CALL OFFSET_cr_ccsd_t_D_1_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('cr_ccsd_t_D_1_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL cr_ccsd_t_D_1_1(d_c1,k_c1_offset,d_i1,k_i1_offset)
      CALL cr_ccsd_t_D_1_2(d_c2,k_c2_offset,d_t1,k_t1_offset,d_i1,k_i1_o
     &ffset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL cr_ccsd_t_D_1(d_t1,k_t1_offset,d_i1,k_i1_offset,d_i0,k_i0_off
     &set)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) CALL ERRQUIT('cr_ccsd_t_D',-1,
     &MA_ERR)
      CALL cr_ccsd_t_D_2(d_c2,k_c2_offset,d_t2,k_t2_offset,d_i0,k_i0_off
     &set)
      RETURN
      END
      SUBROUTINE cr_ccsd_t_D_1(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_off
     &set)
C     $Id: cr_ccsd_t_D.F 19699 2010-10-29 17:07:13Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i0 ( )_tc + = 1 * Sum ( p5 h6 ) * t ( p5 h6 )_t * i1 ( h6 p5 )_c
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
      INTEGER TPINXT
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER p5b
      INTEGER h6b
      INTEGER p5b_1
      INTEGER h6b_1
      INTEGER h6b_2
      INTEGER p5b_2
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
      EXTERNAL TPINXT
      nprocs = GA_NNODES()
      count = 0
      next = TPINXT(nprocs,1)
      IF (next.eq.count) THEN
      IF (0 .eq. ieor(irrep_t,irrep_c)) THEN
      dimc = 1
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p5b = noab+1,noab+nvab
      DO h6b = 1,noab
      IF (int_mb(k_spin+p5b-1) .eq. int_mb(k_spin+h6b-1)) THEN
      IF (ieor(int_mb(k_sym+p5b-1),int_mb(k_sym+h6b-1)) .eq. irrep_t) TH
     &EN
      CALL TCE_RESTRICTED_2(p5b,h6b,p5b_1,h6b_1)
      CALL TCE_RESTRICTED_2(h6b,p5b,h6b_2,p5b_2)
      dim_common = int_mb(k_range+p5b-1) * int_mb(k_range+h6b-1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = 1
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &cr_ccsd_t_D_1',2,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h6b_1
     & - 1 + noab * (p5b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p5b-1)
     &,int_mb(k_range+h6b-1),2,1,1.0d0)
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('cr_ccsd_t_D_1',3,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &cr_ccsd_t_D_1',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p5b_2
     & - noab - 1 + nvab * (h6b_2 - 1)))
      CALL TCE_SORT_2(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h6b-1)
     &,int_mb(k_range+p5b-1),1,2,1.0d0)
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('cr_ccsd_t_D_1',6,MA_ERR)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a
     &_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sor
     &t),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('cr_ccsd_t_D_1',7,MA
     &_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('cr_ccsd_t_D_1',8,MA
     &_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &cr_ccsd_t_D_1',9,MA_ERR)
      CALL TCE_SORT_0(dbl_mb(k_c_sort),dbl_mb(k_c),1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),0)
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('cr_ccsd_t_D_1',10,MA_ERR
     &)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('cr_ccsd_t_D_1',11,M
     &A_ERR)
      END IF
      next = TPINXT(nprocs,1)
      END IF
      count = count + 1
      next = TPINXT(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
      SUBROUTINE cr_ccsd_t_D_1_1(d_a,k_a_offset,d_c,k_c_offset)
C     $Id: cr_ccsd_t_D.F 19699 2010-10-29 17:07:13Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i1 ( h6 p5 )_c + = 1 * c+ ( h6 p5 )_c
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
      INTEGER TPINXT
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER h6b
      INTEGER p5b
      INTEGER dimc
      INTEGER h6b_1
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
      EXTERNAL TPINXT
      nprocs = GA_NNODES()
      count = 0
      next = TPINXT(nprocs,1)
      DO h6b = 1,noab
      DO p5b = noab+1,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h6b-1)+int_mb(k_spin+p5b-1
     &).ne.4)) THEN
      IF (int_mb(k_spin+h6b-1) .eq. int_mb(k_spin+p5b-1)) THEN
      IF (ieor(int_mb(k_sym+h6b-1),int_mb(k_sym+p5b-1)) .eq. irrep_c) TH
     &EN
      dimc = int_mb(k_range+h6b-1) * int_mb(k_range+p5b-1)
      CALL TCE_RESTRICTED_2(h6b,p5b,h6b_1,p5b_1)
      dim_common = 1
      dima_sort = int_mb(k_range+h6b-1) * int_mb(k_range+p5b-1)
      dima = dim_common * dima_sort
      IF (dima .gt. 0) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1_1',0,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &cr_ccsd_t_D_1_1',1,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h6b_1
     & - 1 + noab * (p5b_1 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p5b-1)
     &,int_mb(k_range+h6b-1),1,2,1.0d0)
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('cr_ccsd_t_D_1_1',2,MA_ER
     &R)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &cr_ccsd_t_D_1_1',3,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_a_sort),dbl_mb(k_c),int_mb(k_range+p5b-1)
     &,int_mb(k_range+h6b-1),2,1,1.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p5b -
     & noab - 1 + nvab * (h6b - 1)))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('cr_ccsd_t_D_1_1',4,MA_ER
     &R)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('cr_ccsd_t_D_1_1',5,
     &MA_ERR)
      END IF
      END IF
      END IF
      END IF
      next = TPINXT(nprocs,1)
      END IF
      count = count + 1
      END DO
      END DO
      next = TPINXT(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
      SUBROUTINE OFFSET_cr_ccsd_t_D_1_1(l_a_offset,k_a_offset,size)
C     $Id: cr_ccsd_t_D.F 19699 2010-10-29 17:07:13Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i1 ( h6 p5 )_c
      IMPLICIT NONE
#include "global.fh"
#include "mafdecls.fh"
#include "sym.fh"
#include "errquit.fh"
#include "tce.fh"
      INTEGER l_a_offset
      INTEGER k_a_offset
      INTEGER size
      INTEGER length
      INTEGER addr
      INTEGER h6b
      INTEGER p5b
      length = 0
      DO h6b = 1,noab
      DO p5b = noab+1,noab+nvab
      IF (int_mb(k_spin+h6b-1) .eq. int_mb(k_spin+p5b-1)) THEN
      IF (ieor(int_mb(k_sym+h6b-1),int_mb(k_sym+p5b-1)) .eq. irrep_c) TH
     &EN
      IF ((.not.restricted).or.(int_mb(k_spin+h6b-1)+int_mb(k_spin+p5b-1
     &).ne.4)) THEN
      length = length + 1
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_int,2*length+1,'noname',l_a_offset,k_a_off
     &set)) CALL ERRQUIT('cr_ccsd_t_D_1_1',0,MA_ERR)
      int_mb(k_a_offset) = length
      addr = 0
      size = 0
      DO h6b = 1,noab
      DO p5b = noab+1,noab+nvab
      IF (int_mb(k_spin+h6b-1) .eq. int_mb(k_spin+p5b-1)) THEN
      IF (ieor(int_mb(k_sym+h6b-1),int_mb(k_sym+p5b-1)) .eq. irrep_c) TH
     &EN
      IF ((.not.restricted).or.(int_mb(k_spin+h6b-1)+int_mb(k_spin+p5b-1
     &).ne.4)) THEN
      addr = addr + 1
      int_mb(k_a_offset+addr) = p5b - noab - 1 + nvab * (h6b - 1)
      int_mb(k_a_offset+length+addr) = size
      size = size + int_mb(k_range+h6b-1) * int_mb(k_range+p5b-1)
      END IF
      END IF
      END IF
      END DO
      END DO
      RETURN
      END
      SUBROUTINE cr_ccsd_t_D_1_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_o
     &ffset)
C     $Id: cr_ccsd_t_D.F 19699 2010-10-29 17:07:13Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i1 ( h6 p5 )_ct + = 1/2 * Sum ( h4 p3 ) * c+ ( h4 h6 p3 p5 )_c * t ( p3 h4 )_t
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
      INTEGER TPINXT
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER h6b
      INTEGER p5b
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER h4b
      INTEGER p3b
      INTEGER h6b_1
      INTEGER h4b_1
      INTEGER p5b_1
      INTEGER p3b_1
      INTEGER p3b_2
      INTEGER h4b_2
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
      EXTERNAL TPINXT
      nprocs = GA_NNODES()
      count = 0
      next = TPINXT(nprocs,1)
      DO h6b = 1,noab
      DO p5b = noab+1,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h6b-1)+int_mb(k_spin+p5b-1
     &).ne.4)) THEN
      IF (int_mb(k_spin+h6b-1) .eq. int_mb(k_spin+p5b-1)) THEN
      IF (ieor(int_mb(k_sym+h6b-1),int_mb(k_sym+p5b-1)) .eq. ieor(irrep_
     &c,irrep_t)) THEN
      dimc = int_mb(k_range+h6b-1) * int_mb(k_range+p5b-1)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO h4b = 1,noab
      DO p3b = noab+1,noab+nvab
      IF (int_mb(k_spin+h6b-1)+int_mb(k_spin+h4b-1) .eq. int_mb(k_spin+p
     &5b-1)+int_mb(k_spin+p3b-1)) THEN
      IF (ieor(int_mb(k_sym+h6b-1),ieor(int_mb(k_sym+h4b-1),ieor(int_mb(
     &k_sym+p5b-1),int_mb(k_sym+p3b-1)))) .eq. irrep_c) THEN
      CALL TCE_RESTRICTED_4(h6b,h4b,p5b,p3b,h6b_1,h4b_1,p5b_1,p3b_1)
      CALL TCE_RESTRICTED_2(p3b,h4b,p3b_2,h4b_2)
      dim_common = int_mb(k_range+h4b-1) * int_mb(k_range+p3b-1)
      dima_sort = int_mb(k_range+h6b-1) * int_mb(k_range+p5b-1)
      dima = dim_common * dima_sort
      dimb_sort = 1
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1_2',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &cr_ccsd_t_D_1_2',2,MA_ERR)
      IF ((h4b .le. h6b) .and. (p3b .le. p5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h6b_1
     & - 1 + noab * (h4b_1 - 1 + noab * (p5b_1 - noab - 1 + nvab * (p3b_
     &1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+p5b-1),int_mb(k_range+h4b-1),int_mb(k_range+h6b-1)
     &,2,4,1,3,1.0d0)
      END IF
      IF ((h4b .le. h6b) .and. (p5b .lt. p3b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h6b_1
     & - 1 + noab * (h4b_1 - 1 + noab * (p3b_1 - noab - 1 + nvab * (p5b_
     &1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p5b-1)
     &,int_mb(k_range+p3b-1),int_mb(k_range+h4b-1),int_mb(k_range+h6b-1)
     &,1,4,2,3,-1.0d0)
      END IF
      IF ((h6b .lt. h4b) .and. (p3b .le. p5b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h4b_1
     & - 1 + noab * (h6b_1 - 1 + noab * (p5b_1 - noab - 1 + nvab * (p3b_
     &1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+p5b-1),int_mb(k_range+h6b-1),int_mb(k_range+h4b-1)
     &,2,3,1,4,-1.0d0)
      END IF
      IF ((h6b .lt. h4b) .and. (p5b .lt. p3b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h4b_1
     & - 1 + noab * (h6b_1 - 1 + noab * (p3b_1 - noab - 1 + nvab * (p5b_
     &1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p5b-1)
     &,int_mb(k_range+p3b-1),int_mb(k_range+h6b-1),int_mb(k_range+h4b-1)
     &,1,3,2,4,1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('cr_ccsd_t_D_1_2',3,MA_ER
     &R)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_1_2',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &cr_ccsd_t_D_1_2',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(h4b_2
     & - 1 + noab * (p3b_2 - noab - 1)))
      CALL TCE_SORT_2(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+h4b-1),1,2,1.0d0)
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('cr_ccsd_t_D_1_2',6,MA_ER
     &R)
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,1.0d0,dbl_mb(k_a
     &_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sor
     &t),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('cr_ccsd_t_D_1_2',7,
     &MA_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('cr_ccsd_t_D_1_2',8,
     &MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &cr_ccsd_t_D_1_2',9,MA_ERR)
      CALL TCE_SORT_2(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+p5b-1)
     &,int_mb(k_range+h6b-1),2,1,1.0d0/2.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p5b -
     & noab - 1 + nvab * (h6b - 1)))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('cr_ccsd_t_D_1_2',10,MA_E
     &RR)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('cr_ccsd_t_D_1_2',11
     &,MA_ERR)
      END IF
      END IF
      END IF
      next = TPINXT(nprocs,1)
      END IF
      count = count + 1
      END DO
      END DO
      next = TPINXT(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
      SUBROUTINE cr_ccsd_t_D_2(d_a,k_a_offset,d_b,k_b_offset,d_c,k_c_off
     &set)
C     $Id: cr_ccsd_t_D.F 19699 2010-10-29 17:07:13Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i0 ( )_tc + = 1/4 * Sum ( p3 p4 h1 h2 ) * c+ ( h1 h2 p3 p4 )_c * t ( p3 p4 h1 h2 )_t
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
      INTEGER TPINXT
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER h1b
      INTEGER h2b
      INTEGER p3b
      INTEGER p4b
      INTEGER h1b_1
      INTEGER h2b_1
      INTEGER p3b_1
      INTEGER p4b_1
      INTEGER p3b_2
      INTEGER p4b_2
      INTEGER h1b_2
      INTEGER h2b_2
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
      INTEGER nsuperh(2)
      INTEGER isuperh
      INTEGER nsubp(2)
      INTEGER isubp
      INTEGER l_c
      INTEGER k_c
      DOUBLE PRECISION FACTORIAL
      EXTERNAL TPINXT
      EXTERNAL FACTORIAL
      nprocs = GA_NNODES()
      count = 0
      next = TPINXT(nprocs,1)
      IF (next.eq.count) THEN
      IF (0 .eq. ieor(irrep_t,irrep_c)) THEN
      dimc = 1
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO h1b = 1,noab
      DO h2b = h1b,noab
      DO p3b = noab+1,noab+nvab
      DO p4b = p3b,noab+nvab
      IF (int_mb(k_spin+h1b-1)+int_mb(k_spin+h2b-1) .eq. int_mb(k_spin+p
     &3b-1)+int_mb(k_spin+p4b-1)) THEN
      IF (ieor(int_mb(k_sym+h1b-1),ieor(int_mb(k_sym+h2b-1),ieor(int_mb(
     &k_sym+p3b-1),int_mb(k_sym+p4b-1)))) .eq. irrep_c) THEN
      CALL TCE_RESTRICTED_4(h1b,h2b,p3b,p4b,h1b_1,h2b_1,p3b_1,p4b_1)
      CALL TCE_RESTRICTED_4(p3b,p4b,h1b,h2b,p3b_2,p4b_2,h1b_2,h2b_2)
      dim_common = int_mb(k_range+h1b-1) * int_mb(k_range+h2b-1) * int_m
     &b(k_range+p3b-1) * int_mb(k_range+p4b-1)
      dima_sort = 1
      dima = dim_common * dima_sort
      dimb_sort = 1
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_2',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &cr_ccsd_t_D_2',2,MA_ERR)
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h2b_1
     & - 1 + noab * (h1b_1 - 1 + noab * (p4b_1 - noab - 1 + nvab * (p3b_
     &1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+p4b-1),int_mb(k_range+h1b-1),int_mb(k_range+h2b-1)
     &,2,1,4,3,1.0d0)
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('cr_ccsd_t_D_2',3,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('cr_ccsd_t_D_2',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &cr_ccsd_t_D_2',5,MA_ERR)
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(h2b_2
     & - 1 + noab * (h1b_2 - 1 + noab * (p4b_2 - noab - 1 + nvab * (p3b_
     &2 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+p3b-1)
     &,int_mb(k_range+p4b-1),int_mb(k_range+h1b-1),int_mb(k_range+h2b-1)
     &,2,1,4,3,1.0d0)
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('cr_ccsd_t_D_2',6,MA_ERR)
      nsuperh(1) = 1
      nsuperh(2) = 1
      isuperh = 1
      IF (h1b .eq. h2b) THEN
      nsuperh(isuperh) = nsuperh(isuperh) + 1
      ELSE
      isuperh = isuperh + 1
      END IF
      nsubp(1) = 1
      nsubp(2) = 1
      isubp = 1
      IF (p3b .eq. p4b) THEN
      nsubp(isubp) = nsubp(isubp) + 1
      ELSE
      isubp = isubp + 1
      END IF
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,4.0d0/FACTORIAL(
     &nsuperh(1))/FACTORIAL(nsuperh(2))/FACTORIAL(nsubp(1))/FACTORIAL(ns
     &ubp(2)),dbl_mb(k_a_sort),dim_common,dbl_mb(k_b_sort),dim_common,1.
     &0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('cr_ccsd_t_D_2',7,MA
     &_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('cr_ccsd_t_D_2',8,MA
     &_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &cr_ccsd_t_D_2',9,MA_ERR)
      CALL TCE_SORT_0(dbl_mb(k_c_sort),dbl_mb(k_c),1.0d0/4.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),0)
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('cr_ccsd_t_D_2',10,MA_ERR
     &)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('cr_ccsd_t_D_2',11,M
     &A_ERR)
      END IF
      next = TPINXT(nprocs,1)
      END IF
      count = count + 1
      next = TPINXT(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
