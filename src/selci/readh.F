      subroutine selci_readh(iflham,hh,nnci)
*
* $Id: readh.F 19708 2010-10-29 18:04:21Z d3y133 $
*
#include "implicit.fh"
      dimension hh(nnci)
c
      read (iflham) hh
c
      end
