include ../../../examples_config.h

#default message-passing library for ARMCI is MPI
ifndef MSG_COMMS
  MSG_COMMS=MPI
endif
LIBRARY = libarmci.a
LIB_DISTRIB = $(ARMCI_HOME)/../../lib
#defines communication libs and symbols
include $(ARMCI_HOME)/../config/makemp.h
include $(ARMCI_HOME)/../config/makecoms.h
EXTRA_LIBS += $(MP_LIBS) $(COMM_LIBS)
LIBS += $(EXTRA_LIBS)
MP_DEFINES += -DARMCI_ENABLE_GPC_CALLS
#......................................................................
LIBRARY = libarmci.a
HARDCLEAN = yes
#......................................................................

.PHONY : all
all: gpctest.x

%.o:%.c $(FULL_LIBRARY_PATH)
	$(CC) -g -I$(ARMCI_HOME) $(COPT_REN) $(MP_INCLUDES) $(MP_DEFINES) -o $@ -c $^

%.x:%.o $(FULL_LIBRARY_PATH)
	$(FC) -g -I$(ARMCI_HOME) $(FOPT_REN) $(CLD_REN) $(MP_INCLUDES) $(MP_DEFINES) -o $@ $^ $(LIB_DISTRIB)/$(TARGET)/$(LIBRARY) $(LIBS) -lm

.PHONY : clean
clean: 
	$(RM) *.x
