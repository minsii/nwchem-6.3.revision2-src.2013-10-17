      logical function argos_prepare_slvnum(islv,boxs,nwms,box,nwm)
c
c $Id: argos_prepare_slvnum.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      implicit none
c
      integer islv,nwms,nwm
      real*8 boxs(3),box(3)
c
      nwm=0
      if(islv.eq.1) then
      nwm=2*int(dble(nwms)*(box(1)*box(2)*box(3))/
     + (boxs(1)*boxs(2)*boxs(3)))
      elseif(islv.eq.2) then
      nwm=int(dble(nwms)*0.5d0*(box(1)*box(2)*box(3))/
     + (boxs(1)*boxs(2)*boxs(3)))
      elseif(islv.eq.3) then
      nwm=2*int(dble(nwms)*(box(1)*box(2)*box(3))/
     + (boxs(1)*boxs(2)*boxs(3)))
      endif
c
      argos_prepare_slvnum=.true.
      return
      end
