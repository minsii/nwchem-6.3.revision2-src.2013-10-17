# Makefile for Global Array library test programs
#
#      "make test.x"      to create a test program for GA 
#      "make patch.x"     to create a test program for GA patch operations
#      "make ndim.x"      to create a Fortran test program for n-dim GA
#      "make testsolve.x" to create a test program for linear equation solver 
#                         based on LU factorization
#      "make testeig.x"   to create a test program for GA eigensolver,
#                         matrix multiply, and symmetrization 
#      "make perf.x"      to create a program testing performance of GA
#                         primitives: get, put & accumulate,
#      "make testc.x"     to create a C test program for GA
#      "make ntestc.x"    to create a C test program for n-dim GA
#      "make ga-mpi.x"    to create a C test program for GA that demonstrates
#                         the interface to MPI
#      "make clean"       clean
#      "make realclean"   even cleaner   
#
#........................................................................

ifndef ARMCI_DIR_NAME
   ARMCI_DIR_NAME=armci
endif

ifndef TARGET
error:
	@echo "TARGET machine not defined "
	@echo "-- one of [SUN,SGI,SGITFP,IBM,DECOSF,SP1,SP,IPSC,DELTA,PARAGON,KSR,CRAY-T3D,CONVEX-SPP,HPUX]"
	exit
endif

ifeq ($(DIAG), PAR)
     LIB_DEFINES += -DPAR_DIAG
endif
ifdef USE_SCALAPACK
     LIB_DEFINES += -DSCALAPACK
endif
ifdef USE_SCALAPACK_I8
     LIB_DEFINES += -DSCALAPACK
endif

LIB_DISTRIB  = ../../lib
LIB_TARGETS = *.x *.p
      INCDIR = ../../include
LIB_INCLUDES = -I$(INCDIR) $(COMM_INCLUDES) $(MP_INCLUDES)

ifeq ($(ARMCI_NETWORK),PORTALS)
  ARMCI_DIR_NAME = armci-portals
else
  ARMCI_DIR_NAME = armci
endif

include ../../$(ARMCI_DIR_NAME)/config/makecoms.h
include ../../$(ARMCI_DIR_NAME)/config/makemp.h
include ../../config/makefile.h

ifndef LIBDIR
   LIBDIR = $(LIB_DISTRIB)/$(TARGET)
endif

#
# main program in C requires extra effort to provide Fortran libs
# Highly system dependent !!!


#on Fujitsu or Linux with Portran Group fortran we need to rename C  main 
# to avoid conflict with Fortran libs
ifdef CMAIN 
  CFLAGS += $(CMAIN) 
endif

ifeq ($(MSG_COMMS), MPI)
  P_FILE = no
endif
ifdef USE_MPI
  P_FILE = no
endif

TESTUTILC = util.o
TESTUTIL= $(TESTUTILC) ffflush.o

NOPT=-O2

FOPT= $(NOPT)
COPT= $(NOPT)

#
# build test programs and .p files if needed
#
#.PRECIOUS: %.o

all: test.x patch.x ndim.x perf.x testc.x ntestc.x ga-mpi.x

ifeq ($(P_FILE),YES)
%.x : %.o $(TESTUTIL) $(LIBDIR)/libglobal.a $(LIBDIR)/libarmci.a  $(EXTRA)
	echo "`whoami` `hostname` 4 `pwd`/$@ /tmp" > $@.p
	if [ -f $(basename $@).c ]; then\
		$(LINK.c) $(COPT) $(CLDOPT) -o $@ $< $(TESTUTILC) $(LIBS) $(CLIBS);\
	else\
		$(LINK.f) $(FOPT) $(FLDOPT) -o $@ $< $(TESTUTIL) $(LIBS) $(FLIBS);\
        fi
else
%.x : %.o $(TESTUTIL) $(LIBDIR)/libglobal.a  $(LIBDIR)/libarmci.a $(EXTRA)
	if [ -f $(basename $@).c ]; then\
		$(LINK.c) $(COPT) $(CLDOPT) -o $@ $< $(TESTUTILC) $(LIBS) $(CLIBS);\
	else\
		$(LINK.f) $(FOPT) $(FLDOPT) -o $@ $< $(TESTUTIL) $(LIBS) $(FLIBS);\
        fi
endif

%.o : %.c
	$(CC) $(COPT) $(COPT_REN) $(INCLUDES) $(DEFINES) $(CDEFS) -c $<

%.p:
	echo "`whoami` `hostname` 4 `pwd`/$(basename $@) /tmp" > $@

ifndef SCALAPACK
testspd.x:
	@echo testspd.x requires SCALAPACK installed: see global/README
endif

.PHONY: clean
clean:
	-$(RM) -f *.o *.p *.exe *.obj *core *stamp mputil.* *trace *.x *events*
	-$(RM) -f ngatest.F nga-*.F
	-$(RM) -rf ./obj

.PHONY: realclean
realclean:      clean
	-$(RM) -rf *~ \#*\#

.PHONY: cleanstamp
cleanstamp:
	-$(RM) -rf *.stamp

