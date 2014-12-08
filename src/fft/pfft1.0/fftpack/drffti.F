      subroutine drffti (n,wsave)
*
* $Id: drffti.F 19695 2010-10-29 16:51:02Z d3y133 $
*
      double precision wsave(1)
c
      if (n .eq. 1) return
c
      call drfti1 (n,wsave(n+1),wsave(2*n+1))
c
      return
      end
