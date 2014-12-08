      subroutine esp_getden(dns,ifr,ito,jfr,jto)
c
c $Id: esp_getden.F 19708 2010-10-29 18:04:21Z d3y133 $
c
      implicit none
c
#include "esp_params.fh"
#include "esp_common.fh"
#include "global.fh"
#include "util.fh"
c
      integer ifr,ito,jfr,jto
      real*8 dns(mbf,mbf)
c
      integer i,j
c
      call ga_get(lg_d,ifr,ito,jfr,jto,dns,mbf)
c
      if(me.eq.0.and.util_print('where',print_debug)) then
      write(lfnout,1000)
 1000 format(//,' Density matrix',/)
      do 1002 j=jfr,jto
      write(lfnout,1001) (i,dns(i,j),i=ifr,ito)
 1001 format(i5,f12.6,/,(5x,10f12.6))
 1002 continue
      endif
c
      return
      end
