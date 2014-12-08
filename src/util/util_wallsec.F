      double precision function util_wallsec()
      implicit none
c $Id: util_wallsec.F 19707 2010-10-29 17:59:36Z d3y133 $
*
* routine to give wall clock seconds since start of execution
*  delta times are handled by all applications
*
*
      double precision tcgtime
      external tcgtime
      util_wallsec = tcgtime()
*
      end


