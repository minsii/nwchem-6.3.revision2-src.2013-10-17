      subroutine selci_mxmb(a,mcola,mrowa,b,mcolb,mrowb,
     1     r,mcolr,mrowr, ncol,nlink,nrow)
*
* $Id: mxmb.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      implicit double precision (a-h,o-z)
      dimension a(1),b(1),r(1)
c
      ir=1
      ib=1
      do 50 j=1,nrow
         ibb=ib
         ia=1
         do 40 k=1,nlink
            fac=b(ibb)
            if(fac)10,30,10
 10         irr=ir
            iaa=ia
            do 20 i=1,ncol
               r(irr)=r(irr)+fac*a(iaa)
               irr=irr+mcolr
               iaa=iaa+mcola
 20         continue
 30         ibb=ibb+mcolb
            ia=ia+mrowa
 40      continue
         ir=ir+mrowr
         ib=ib+mrowb
 50   continue
c
      end
