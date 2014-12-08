c
c $Id: cm_bond.inc 19707 2010-10-29 17:59:36Z d3y133 $
c

      integer bonlist

      real*8  bonddist,bondfrce

      dimension bonlist(mxbond2,3),bonddist(mxbond),bondfrce(mxbond)

      common/cm_bond/bonlist,bonddist,bondfrce
