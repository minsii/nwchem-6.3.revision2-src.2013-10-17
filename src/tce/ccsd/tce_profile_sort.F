      subroutine tpi_sort_0(inp,out,fac)
      implicit none
      double precision out
      double precision inp
      double precision fac
      call tce_sort_0(inp,out,fac)
      return
      end


      subroutine tpi_sort_2(inp,out,a,b,i,j,fac)
      implicit none
      integer a,b
      integer i,j
      double precision out(a*b)
      double precision inp(a*b)
      double precision fac
      call tpi_start_timer(2)
      call tce_sort_2(inp,out,a,b,i,j,fac)
      call tpi_stop_timer(2)
      return
      end


      subroutine tpi_sort_4(inp,out,a,b,c,d,i,j,k,l,fac)
      implicit none
      integer a,b,c,d
      integer i,j,k,l
      double precision out(a*b*c*d)
      double precision inp(a*b*c*d)
      double precision fac
      call tpi_start_timer(4)
      call tce_sort_4(inp,out,a,b,c,d,i,j,k,l,fac)
      call tpi_stop_timer(4)
      return
      end


      subroutine tpi_sort_6(inp,out,a,b,c,d,e,f,i,j,k,l,m,n,fac)
      implicit none
      integer a,b,c,d,e,f
      integer i,j,k,l,m,n
      double precision out(a*b*c*d*e*f)
      double precision inp(a*b*c*d*e*f)
      double precision fac
      call tpi_start_timer(6)
      call tce_sort_6(inp,out,a,b,c,d,e,f,i,j,k,l,m,n,fac)
      call tpi_stop_timer(6)
      return
      end


      subroutine tpi_sort_8(inp,out,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,fac)
      implicit none
      integer a,b,c,d,e,f,g,h
      integer i,j,k,l,m,n,o,p
      double precision out(a*b*c*d*e*f*g*h)
      double precision inp(a*b*c*d*e*f*g*h)
      double precision fac
      call tpi_start_timer(8)
      call tce_sort_8(inp,out,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,fac)
      call tpi_start_timer(8)
      return
      end
