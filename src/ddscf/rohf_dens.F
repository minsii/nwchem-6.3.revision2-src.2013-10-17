      subroutine rohf_dens(g_vecs, nbf, nclosed, nopen,
     $     g_cdens, g_odens)
*
* $Id: rohf_dens.F 19707 2010-10-29 17:59:36Z d3y133 $
*
      implicit none
#include "global.fh"
      integer g_vecs
      integer nbf
      integer nclosed
      integer nopen
      integer g_cdens
      integer g_odens
c
      call ga_matmul_patch('n', 't', 2.0d0, 0.0d0,
     $     g_vecs, 1, nbf, 1, nclosed,
     $     g_vecs, 1, nclosed, 1, nbf,
     $     g_cdens, 1, nbf, 1, nbf)
      call ga_symmetrize(g_cdens)
c
      if (nopen .gt. 0) then
         call ga_matmul_patch('n', 't', 1.0d0, 0.0d0,
     $        g_vecs, 1, nbf, nclosed+1, nclosed+nopen,
     $        g_vecs, nclosed+1, nclosed+nopen, 1, nbf,
     $        g_odens, 1, nbf, 1, nbf)
         call ga_symmetrize(g_odens)
      endif
c
      end
