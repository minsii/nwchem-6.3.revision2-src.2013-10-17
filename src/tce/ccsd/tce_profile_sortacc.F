      subroutine tpi_sortacc_0(inp,out,fac)
      implicit none
      double precision out
      double precision inp
      double precision fac
      call tce_sortacc_0(inp,out,fac)
      return
      end


      subroutine tpi_sortacc_2(inp,out,a,b,i,j,fac)
      implicit none
      integer a,b
      integer i,j
      double precision out(a*b)
      double precision inp(a*b)
      double precision fac
      call tpi_start_timer(3)
      call tce_sortacc_2(inp,out,a,b,i,j,fac)
      call tpi_stop_timer(3)
      return
      end


      subroutine tpi_sortacc_4(inp,out,a,b,c,d,i,j,k,l,fac)
      implicit none
      integer a,b,c,d
      integer i,j,k,l
      double precision out(a*b*c*d)
      double precision inp(a*b*c*d)
      double precision fac
      call tpi_start_timer(5)
      call tce_sortacc_4(inp,out,a,b,c,d,i,j,k,l,fac)
      call tpi_stop_timer(5)
      return
      end


      subroutine tpi_sortacc_6(inp,out,a,b,c,d,e,f,i,j,k,l,m,n,fac)
      implicit none
      integer a,b,c,d,e,f
      integer i,j,k,l,m,n
      double precision out(a*b*c*d*e*f)
      double precision inp(a*b*c*d*e*f)
      double precision fac
      call tpi_start_timer(7)
      call tce_sortacc_6(inp,out,a,b,c,d,e,f,i,j,k,l,m,n,fac)
      call tpi_stop_timer(7)
      return
      end


      subroutine tpi_sortacc_8(inp,out,a,b,c,d,e,f,g,h,
     1                                 i,j,k,l,m,n,o,p,fac)
      implicit none
      integer a,b,c,d,e,f,g,h
      integer i,j,k,l,m,n,o,p
      double precision out(a*b*c*d*e*f*g*h)
      double precision inp(a*b*c*d*e*f*g*h)
      double precision fac
      call tpi_start_timer(9)
      call tce_sortacc_8(inp,out,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,fac)
      call tpi_start_timer(9)
      return
      end
