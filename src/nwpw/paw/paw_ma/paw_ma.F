*
* $Id: paw_ma.F 19707 2010-10-29 17:59:36Z d3y133 $
*

!  **************************************************
!  
!       name:
!  
!       purpose
!  
!       created:        7/7/2002
!  **************************************************
      logical function my_alloc (v_type, v_size, v_name, v)
 
 
#include "mafdecls.fh"
 
      character v_name*(*)
      integer v_type, v_size
      integer v(4)
 
!    *** local variables ***
 
      v(4) = v_type
      v(3) = v_size
      my_alloc = ma_alloc_get(v(4),v(3),v_name,v(2),v(1))
 
      end 
 
!  **************************************************
!  
!       name:
!  
!       purpose
!  
!       created:        7/7/2002
!  **************************************************
      logical function my_dealloc (v)
 
#include "mafdecls.fh" 

      integer v(4)
 
      my_dealloc = MA_free_heap(v(2))
 
 
      end 
 
      subroutine paw_ma_print(v)

      implicit none
      
      integer v(4)


      return
      end
