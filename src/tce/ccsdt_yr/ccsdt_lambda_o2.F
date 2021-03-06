      SUBROUTINE ccsdt_lambda_o2(d_i0,d_o1,d_t1,d_t2,d_y1,d_y2,d_y3,k_i0
     &_offset,k_o1_offset,k_t1_offset,k_t2_offset,k_y1_offset,k_y2_offse
     &t,k_y3_offset)
C     $Id: ccsdt_lambda_o2.F 19701 2010-10-29 17:16:57Z d3y133 $
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i0 ( h3 h4 p1 p2 )_yo + = 1 * P( 4 ) * o ( h3 p1 )_o * y ( h4 p2 )_y
C     i0 ( h3 h4 p1 p2 )_yo + = -1 * P( 2 ) * Sum ( h7 ) * y ( h3 h7 p1 p2 )_y * i1 ( h4 h7 )_o
C         i1 ( h3 h7 )_o + = 1 * o ( h3 h7 )_o
C         i1 ( h3 h7 )_ot + = 1 * Sum ( p5 ) * o ( h3 p5 )_o * t ( p5 h7 )_t
C     i0 ( h3 h4 p1 p2 )_yo + = -1 * P( 2 ) * Sum ( p5 ) * o ( p5 p1 )_o * y ( h3 h4 p2 p5 )_y
C     i0 ( h3 h4 p1 p2 )_yto + = -1 * P( 2 ) * Sum ( h5 ) * o ( h5 p1 )_o * i1 ( h3 h4 h5 p2 )_yt
C         i1 ( h3 h4 h5 p1 )_yt + = -1 * Sum ( p6 ) * t ( p6 h5 )_t * y ( h3 h4 p1 p6 )_y
C         i1 ( h3 h4 h5 p1 )_yt + = -1/2 * Sum ( h8 p7 p6 ) * t ( p6 p7 h5 h8 )_t * y ( h3 h4 h8 p1 p6 p7 )_y
C     i0 ( h3 h4 p1 p2 )_oty + = 1/2 * P( 2 ) * Sum ( p6 h7 h8 ) * y ( h3 h7 h8 p1 p2 p6 )_y * i1 ( h4 p6 h7 h8 )_ot
C         i1 ( h3 p6 h7 h8 )_ot + = -1 * Sum ( p5 ) * o ( h3 p5 )_o * t ( p5 p6 h7 h8 )_t
      IMPLICIT NONE
#include "global.fh"
#include "mafdecls.fh"
#include "util.fh"
#include "errquit.fh"
#include "tce.fh"
      INTEGER d_i0
      INTEGER k_i0_offset
      INTEGER d_o1
      INTEGER k_o1_offset
      INTEGER d_y1
      INTEGER k_y1_offset
      INTEGER d_y2
      INTEGER k_y2_offset
      INTEGER d_i1
      INTEGER k_i1_offset
      INTEGER d_y3
      INTEGER k_y3_offset
      INTEGER l_i1_offset
      INTEGER size_i1
      INTEGER d_t1
      INTEGER k_t1_offset
      INTEGER d_t2
      INTEGER k_t2_offset
      CHARACTER*255 filename
#if !defined(CCSDTLR)
      CALL ERRQUIT('CCSDTLR not compiled (ccsdt_lambda_o2.F)',
     &              0,CAPMIS_ERR)
      RETURN
      END
#else
      CALL ccsdt_lambda_o2_1(d_o1,k_o1_offset,d_y1,k_y1_offset,d_i0,k_i0
     &_offset)
      CALL OFFSET_ccsdt_lambda_o2_2_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsdt_lambda_o2_2_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsdt_lambda_o2_2_1(d_o1,k_o1_offset,d_i1,k_i1_offset)
      CALL ccsdt_lambda_o2_2_2(d_o1,k_o1_offset,d_t1,k_t1_offset,d_i1,k_
     &i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL ccsdt_lambda_o2_2(d_y2,k_y2_offset,d_i1,k_i1_offset,d_i0,k_i0
     &_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) CALL ERRQUIT('ccsdt_lambda_o2'
     &,-1,MA_ERR)
      CALL ccsdt_lambda_o2_3(d_o1,k_o1_offset,d_y2,k_y2_offset,d_i0,k_i0
     &_offset)
      CALL OFFSET_ccsdt_lambda_o2_4_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsdt_lambda_o2_4_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsdt_lambda_o2_4_1(d_t1,k_t1_offset,d_y2,k_y2_offset,d_i1,k_
     &i1_offset)
      CALL ccsdt_lambda_o2_4_2(d_t2,k_t2_offset,d_y3,k_y3_offset,d_i1,k_
     &i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL ccsdt_lambda_o2_4(d_o1,k_o1_offset,d_i1,k_i1_offset,d_i0,k_i0
     &_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) CALL ERRQUIT('ccsdt_lambda_o2'
     &,-1,MA_ERR)
      CALL OFFSET_ccsdt_lambda_o2_5_1(l_i1_offset,k_i1_offset,size_i1)
      CALL TCE_FILENAME('ccsdt_lambda_o2_5_1_i1',filename)
      CALL CREATEFILE(filename,d_i1,size_i1)
      CALL ccsdt_lambda_o2_5_1(d_o1,k_o1_offset,d_t2,k_t2_offset,d_i1,k_
     &i1_offset)
      CALL RECONCILEFILE(d_i1,size_i1)
      CALL ccsdt_lambda_o2_5(d_y3,k_y3_offset,d_i1,k_i1_offset,d_i0,k_i0
     &_offset)
      CALL DELETEFILE(d_i1)
      IF (.not.MA_POP_STACK(l_i1_offset)) CALL ERRQUIT('ccsdt_lambda_o2'
     &,-1,MA_ERR)
      RETURN
      END
#endif
