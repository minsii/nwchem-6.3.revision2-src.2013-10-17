      subroutine argos_space_pack_finish()
c
      implicit none
c
#include "argos_space_common.fh"
#include "mafdecls.fh"
c
      if(npackw.gt.0) then
      if(.not.ma_pop_stack(l_packw))
     + call md_abort('Failed to deallocate memory for packw',0)
      endif
      if(npack.gt.0) then
      if(.not.ma_pop_stack(l_pack))
     + call md_abort('Failed to deallocate memory for pack',0)
      endif
c
      return
      end
c $Id: argos_space_pack_finish.F 21176 2011-10-10 06:35:49Z d3y133 $
