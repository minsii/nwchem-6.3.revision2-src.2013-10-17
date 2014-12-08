#define TCGMSG
*
* $Id: second.F 19707 2010-10-29 17:59:36Z d3y133 $
*
#ifdef MPI
      SUBROUTINE current_second(T)
      implicit none
      real*8 T
      real*8 MPI_Wtime
      external MPI_Wtime

      T=MPI_Wtime()

      RETURN
      END
#endif

#ifdef TCGMSG
      SUBROUTINE current_second(T)
      implicit none
      real*8 T
#include "tcgmsg.fh"

      T=TCGTIME()

      RETURN
      END
#endif
