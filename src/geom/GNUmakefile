#$Id: GNUmakefile 19708 2010-10-29 18:04:21Z d3y133 $

 LIBRARY = libnwcutil.a


  OBJ_OPTIMIZE = geom_hnd.o

     OBJ = geom.o geom_input.o geom_input2.o geom_3d.o geom_2d.o geom_1d.o geom_numcore.o \
           geom_checksum.o geom_print_ecce.o  geom_freeze.o geom_fragment.o geom_getsym.o

 HEADERS = geom.fh geomP.fh

 USES_BLAS = geom.F geom_input.F geom_print_ecce.F geom_hnd.F geom_3d.F geom_getsym.F
include ../config/makefile.h
include ../config/makelib.h


  ifeq ($(FC),pgf90)
            FDEBUG += -Mnorecursive
  endif
  ifeq ($(FC),pathf90)
            FDEBUG += -O1 -g -LANG:heap_allocation_threshold=0
  endif
  ifeq ($(_CPU),ia64)
    ifeq ($(FC),ifort)
            FOPTIONS += -save
            FOPTIMIZE += -O0
    endif
  endif
  ifeq ($(FC),ifort)
            FOPTIONS += -save
  endif
  ifeq ($(FC),xlf)
	    FOPTIONS += -qsave
  endif
   ifeq ($(TARGET),HPUX64)
             FOPTIMIZE += +O0
   endif
   ifeq ($(TARGET),HPUX)
             FOPTIMIZE += +O0
   endif
