      subroutine argos_partition_end
c
      implicit none
c
#include "argos.fh"
#include "global.fh"
      integer grp_handle
      logical status
c
      grp_handle = ga_pgroup_get_default()
      call ga_pgroup_set_default(ga_pgroup_get_world())
      status = ga_pgroup_destroy(grp_handle)
c
      call ga_sync()
c
      np = ga_nnodes()
      me = ga_nodeid()
      return
      end
c $Id: argos_partition_end.F 21176 2011-10-10 06:35:49Z d3y133 $
