#FC=ifc -w -132
.SUFFIXES:

.SUFFIXES: .o .f90

.f90.o :
	$(FC) $(F90FLAGS) $(LIB_INCLUDES)  -I$(TOPDIR)/src/include -c $<

# $Id: makefile.h 21176 2011-10-10 06:35:49Z d3y133 $
