      logical function argos_prep_wrtnam(lfnout,lfntmp,
     + filtmp,catm,matm,natm)
c
c $Id: argos_prep_wrtnam.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      implicit none
c
#include "util.fh"
c
      integer lfnout,lfntmp,matm,natm
      character*255 filtmp
      character*6 catm(3,matm)
c
      integer i
c
      open(unit=lfntmp,file=filtmp(1:index(filtmp,' ')-1),
     + form='formatted',status='unknown',err=9999)
c
      do 1 i=1,natm
      write(lfntmp,1000) catm(1,i),catm(2,i)
 1000 format(2a6)
    1 continue
c
      close(unit=lfntmp)
c
      if(util_print('connectivity',print_debug)) then
      write(lfnout,1001) filtmp(1:index(filtmp,' ')-1)
 1001 format(' Atom names written to ',a)
      endif
c
      argos_prep_wrtnam=.true.
      return
c
 9999 continue
      argos_prep_wrtnam=.false.
      return
      end
