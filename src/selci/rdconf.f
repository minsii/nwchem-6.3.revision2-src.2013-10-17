      subroutine selci_rdconf(iflcon,ioconf,indxci,nintpo,noconf)
*
* $Id: rdconf.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      integer ioconf(nintpo*noconf),indxci(noconf+1)
c
c     read occupations and index vector from ciconf file
c
      read (iflcon) ioconf
      read (iflcon) indxci
c
      end
