      subroutine argos_space_finish()
c
      implicit none
c
#include "argos_space_common.fh"
#include "mafdecls.fh"
c
      if(.not.ma_pop_stack(l_xscr))
     + call md_abort('Failed to deallocate xscr',0)
      if(.not.ma_pop_stack(l_bb))
     + call md_abort('Failed to deallocate memory for bb',0)
c
      call argos_space_free()
c
      return
      end
c $Id: argos_space_finish.F 21176 2011-10-10 06:35:49Z d3y133 $
