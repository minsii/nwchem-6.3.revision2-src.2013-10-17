      subroutine selci_mkdele(numf, nroot, deltae, vc, roots,
     $     diag, nfmax, dnorm)
*
* $Id: mkdele.F 19708 2010-10-29 18:04:21Z d3y133 $
*
#include "implicit.fh"
c
c     deltae(root) =  - <root|H|*><*|H|root> / (<*|H|*> - Eroot)
c     dnorm = ( <*|H|root>/(<*|H|*>-E) ) **2
c
      dimension deltae(nroot), vc(nfmax, nroot), roots(nroot),
     $     diag(numf, numf), dnorm(nroot)
c
      call dfill(nroot, 0.0d0, deltae, 1)
      call dfill(nroot, 0.0d0, dnorm, 1)
c
      do 10 ir = 1,nroot
         do 20 i = 1,numf
            coeff = vc(i,ir)/(diag(i,i) - roots(ir))
            deltae(ir) = deltae(ir) - vc(i,ir)*coeff
            dnorm(ir) = dnorm(ir) + coeff*coeff
 20      continue
 10   continue
c
      end
