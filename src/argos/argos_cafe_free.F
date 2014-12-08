      subroutine argos_cafe_free()
c
      implicit none
c
      call argos_cafe_lfree()
      call argos_cafe_sfree()
c
      return
      end
c $Id: argos_cafe_free.F 21176 2011-10-10 06:35:49Z d3y133 $
