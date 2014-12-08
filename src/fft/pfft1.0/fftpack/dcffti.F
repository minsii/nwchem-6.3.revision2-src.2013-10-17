      subroutine dcffti (n,wsave)
*
* $Id: dcffti.F 19695 2010-10-29 16:51:02Z d3y133 $
*
      double precision wsave(1)
c
      if (n .eq. 1) return
c
      iw1 = n+n+1
      iw2 = iw1+n+n
      call dcfti1 (n,wsave(iw1),wsave(iw2))
c
      return
      end
