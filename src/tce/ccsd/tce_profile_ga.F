      subroutine tpi_ga_sync()
      implicit none
      call tpi_start_timer(16)
      call ga_sync()
      call tpi_stop_timer(16)
      return
      end

      subroutine tpi_ga_get(g_a,ilo,ihi,jlo,jhi,buf,ld)
      implicit none
      integer g_a, ilo,ihi,jlo,jhi
      integer ld
      double precision buf(*)
      call tpi_start_timer(11)
      call ga_get(g_a,ilo,ihi,jlo,jhi,buf,ld)
      call tpi_stop_timer(11)
      return
      end

      subroutine tpi_nga_get(g_a,lo,hi,buf,ld)
      implicit none
      integer g_a,lo,hi
      integer ld
      double precision buf(*)
      call tpi_start_timer(11)
      call nga_get(g_a,lo,hi,buf,ld)
      call tpi_stop_timer(11)
      return
      end

      subroutine tpi_ga_put(g_a,ilo,ihi,jlo,jhi,buf,ld)
      implicit none
      integer g_a, ilo,ihi,jlo,jhi
      integer ld
      double precision buf(*)
      call tpi_start_timer(12)
      call ga_put(g_a,ilo,ihi,jlo,jhi,buf,ld)
      call tpi_stop_timer(12)
      return
      end

      subroutine tpi_nga_put(g_a,lo,hi,buf,ld)
      implicit none
      integer g_a,lo,hi
      integer ld
      double precision buf(*)
      call tpi_start_timer(12)
      call nga_put(g_a,lo,hi,buf,ld)
      call tpi_stop_timer(12)
      return
      end

      subroutine tpi_ga_acc(g_a,ilo,ihi,jlo,jhi,buf,ld,alpha)
      implicit none
      integer g_a, ilo,ihi,jlo,jhi
      integer ld
      double precision buf(*)
      double precision alpha
      call tpi_start_timer(13)
      call ga_acc(g_a,ilo,ihi,jlo,jhi,buf,ld,alpha)
      call tpi_stop_timer(13)
      return
      end
