      logical function argos_prep_str_replace(string,charf,chart)
      implicit none
#include "inp.fh"
      character*(*) string
      character*1 charf,chart
      integer i
      do 1 i=1,inp_strlen(string)
      if(string(i:i).eq.charf) string(i:i)=chart
    1 continue
      argos_prep_str_replace=.true.
      return
      end
c $Id: argos_prep_str_replace.F 21176 2011-10-10 06:35:49Z d3y133 $
