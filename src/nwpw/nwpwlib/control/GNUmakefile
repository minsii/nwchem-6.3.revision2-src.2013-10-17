#
# $Id: GNUmakefile 19707 2010-10-29 17:59:36Z d3y133 $
#

 OBJ_OPTIMIZE = \
            control.o \
			psi_get_ne.o \
			psi_get_version.o \
			psi_get_header.o \
			cpsi_get_header.o \
			get_psp_type.o


	  OBJ = 

      LIBRARY = libnwpwlib.a

    USES_BLAS = control.F

  LIB_DEFINES = 

ifneq ($(USE_MPI),y)
  LIB_DEFINES += -DNOMPI
endif


include ../../../config/makefile.h
include ../../../config/makelib.h

