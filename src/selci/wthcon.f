      subroutine selci_wthcon(iflcon, title, multi, nelec, issss,
     $     norbs, 
     &     nnsmax, nci, noconf, nintpo, nbitpi, nbpsy, isym, nsym,
     &     inttyp,nsneed)
*
* $Id: wthcon.f 19708 2010-10-29 18:04:21Z d3y133 $
*
      character*80 title
      dimension nbpsy(8), isym(255), nsneed(3)
c
c     write header of the ciconf file
c
      write(iflcon) title, multi, nelec, issss, norbs, nnsmax, 
     &     nci, noconf, nintpo, nbitpi, nbpsy, isym, nsym, inttyp,
     &     nsneed
c      write(6,*) ' in rdhcon '
c      write(6,*) ' title, multi, nelec, issss, norbs, nnsmax, nci,',
c     &     'noconf, nintpo, nbitpi '
c      write(6,*) title
c      write(6,*) multi, nelec, issss, norbs, nnsmax, nci, noconf,
c     &     nintpo, nbitpi, nbpsy, isym, inttyp, nsneed
      end
