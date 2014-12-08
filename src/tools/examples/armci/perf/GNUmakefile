ifeq ($(ARMCI_NETWORK),PORTALS)
  ARMCI_DIR_NAME = armci-portals
else
  ARMCI_DIR_NAME = armci
endif
ARMCI_HOME=../../../$(ARMCI_DIR_NAME)/src
#default message-passing library for ARMCI is MPI
ifndef MSG_COMMS
  MSG_COMMS=MPI
endif
LIBRARY = libarmci.a
LIB_DISTRIB = $(ARMCI_HOME)/../lib
#defines communication libs and symbols
include $(ARMCI_HOME)/../config/makemp.h
include $(ARMCI_HOME)/../config/makecoms.h
EXTRA_LIBS += $(MP_LIBS) $(COMM_LIBS)
LIBS += $(EXTRA_LIBS)
#......................................................................
LIBRARY = libarmci.a
HARDCLEAN = yes
#......................................................................

.PHONY : all
all: perf.x perf_aggr.x perf_nb.x

%.x:%.c $(FULL_LIBRARY_PATH)
	$(CC) -g -I$(ARMCI_HOME) $(COPT_REN) $(MP_INCLUDES) $(MP_DEFINES) -o $@ $^ $(LIB_DISTRIB)/$(TARGET)/$(LIBRARY) $(LIBS) -lm

.PHONY : clean
clean: 
	$(RM) *.x
