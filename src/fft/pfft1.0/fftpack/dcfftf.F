      subroutine dcfftf (n,c,wsave)
*
* $Id: dcfftf.F 19695 2010-10-29 16:51:02Z d3y133 $
*
      double precision c(1), wsave(1)
c
      if (n .eq. 1) return
c
      iw1 = n+n+1
      iw2 = iw1+n+n
      call dcftf1 (n,c,wsave,wsave(iw1),wsave(iw2))
c
      return
      end
