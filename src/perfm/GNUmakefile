#
# $Id: GNUmakefile 21223 2011-10-20 16:01:48Z d3y133 $
#

  LIBRARY = libperfm.a
  
  OBJ = perfm_start.o perfm_end.o perfm_flop.o
  OBJ_OPTIMIZE = dist.o
  HEADERS = dist.fh

USES_BLAS = 

include ../config/makefile.h
include ../config/makelib.h
ifdef USE_FDIST
  ifdef USE_MPI
    LIB_DEFINES += -DMPI_TIME
    ifneq ($(MPI_INCLUDE),)
      LIB_INCLUDES += $(patsubst -I-I%,-I%,-I$(MPI_INCLUDE))
    endif
  else
  endif
endif
 

testdist:	testdist.o $(LIBRARY_PATH)
	$(FC) $(FFLAGS) $(LDFLAGS) -o $@ testdist.o $(LIBS)

