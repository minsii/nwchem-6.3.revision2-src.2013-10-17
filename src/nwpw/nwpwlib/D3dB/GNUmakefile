#
# $Id: GNUmakefile 21430 2011-11-07 21:59:54Z d3p852 $
#

 OBJ_OPTIMIZE = D3dB-new.o generate_map_indexes.o hilbert.o hcurve.o olist.o trans.o D3dB_pfft.o
 OBJ = 

ifeq ($(USE_MPIF),y)
  OBJ_OPTIMIZE += D3dB-mpi.o
else
  OBJ_OPTIMIZE += D3dB-tcgmsg.o
endif

      LIBRARY = libnwpwlib.a

    USES_BLAS = D3dB-new.F D3dB_pfft.F D3dB-mpi.F
  LIB_DEFINES = 


include ../../../config/makefile.h
include ../../../config/makelib.h


ifeq ($(USE_MLIB),y)
  LIB_DEFINES += -DMLIB
endif

ifeq ($(USE_MPIF),y)
  LIB_DEFINES += -DMPI
  ifneq ($(MPI_INCLUDE),)
    LIB_INCLUDES += $(patsubst -I-I%,-I%,-I$(MPI_INCLUDE))
  endif
else
  USES_BLAS += D3dB-tcgmsg.F
  LIB_DEFINES += -DTCGMSG
endif

ifeq ($(USE_MPIF4),y)
LIB_DEFINES += -DMPI4
endif

ifeq ($(USE_FFTW3),y)
  LIB_DEFINES += -DFFTW3
  LIB_INCLUDES += -I$(FFTW3_INCLUDE)
endif
