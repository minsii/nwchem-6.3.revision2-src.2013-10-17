      INTEGER FUNCTION TPINXT(NPROC, ICHUNK)
      INTEGER NPROC, ICHUNK, OUTPUT
      call tpi_start_timer(14)
      TPINXT = NXTASK(NPROC, ICHUNK)
      call tpi_stop_timer(14)
      RETURN 
      END
