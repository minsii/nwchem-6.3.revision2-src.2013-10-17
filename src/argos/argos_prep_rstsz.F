      logical function argos_prep_rstsz(lfnrst,filrst,nwm,nwa,nsa,nwmc)
c
c $Id: argos_prep_rstsz.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      implicit none
c
      integer lfnrst,nwm,nwa,nwmc
      character*255 filrst
c
      character*1 cdummy
      integer i,nsa,npbtyp,kinsep
c
      open(unit=lfnrst,file=filrst(1:index(filrst,' ')-1),
     + status='old',err=9999)
      rewind(lfnrst)
c
      do 1 i=1,4
      read(lfnrst,1000) cdummy
 1000 format(a1)
    1 continue
      read(lfnrst,1001) npbtyp
 1001 format(i5)
      read(lfnrst,1002) kinsep
 1002 format(40x,i5)
      read(lfnrst,1000) cdummy
      if(kinsep.eq.1) then
      do 2 i=1,3
      read(lfnrst,1000) cdummy
    2 continue
      endif
c
      read(lfnrst,1003) nwm,nwa,nsa,nwmc
 1003 format(2i10,10x,2i10)
c
      close(unit=lfnrst)
c
c      nwm=nwm-nwmc
c
      argos_prep_rstsz=.true.
      return
c
 9999 continue
      argos_prep_rstsz=.false.
      return
      end
