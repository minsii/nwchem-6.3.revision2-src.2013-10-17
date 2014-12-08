      subroutine selci_prtcon(ifllog, norbs, ioconf, nintpo, nbitpi)
*
* $Id: prtcon.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      dimension ioconf(nintpo),iocc(255)
c
      call selci_upkcon(norbs, iocc, ioconf, nintpo, nbitpi)
      call selci_wrtcon(ifllog, iocc, norbs)
c
      end
