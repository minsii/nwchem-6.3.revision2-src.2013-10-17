      subroutine selci_pconls(ioconf)
*
* $Id: pconls.F 19708 2010-10-29 18:04:21Z d3y133 $
*
#include "implicit.fh"
#include "ciinfo.fh"
      dimension ioconf(nintpo,noconf)
c
      write(ifllog,1)
 1    format(/' List of orbital occupations in the CI '/)
      do 10 iconf = 1,noconf
         call selci_prtcon(ifllog,norbs,ioconf(1,iconf),nintpo,nbitpi)
 10   continue
c
      end
