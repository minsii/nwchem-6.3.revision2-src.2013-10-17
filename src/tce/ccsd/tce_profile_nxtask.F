      INTEGER FUNCTION TPINXT(NPROC, ICHUNK)
      INTEGER NPROC, ICHUNK, OUTPUT
      call tpi_start_timer(14)
      TPINXT = NXTASK(NPROC, ICHUNK)
      call tpi_stop_timer(14)
      RETURN 
      END

      INTEGER FUNCTION TPISYNXT(NPROC, ICHUNK)
      INTEGER NPROC, ICHUNK, OUTPUT
      call tpi_start_timer(19)
      TPINXT = NXTASK(NPROC, ICHUNK)
      call tpi_stop_timer(19)
      RETURN
      END
