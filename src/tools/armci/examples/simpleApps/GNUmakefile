include ../examples_config.h

#default message-passing library for ARMCI is MPI
ifndef MSG_COMMS
  MSG_COMMS=MPI
endif
LIBRARY = libarmci.a
LIB_DISTRIB = ../../lib
ARMCI_SRC = ../../src
#defines communication libs and symbols
include ../../config/makemp.h
include ../../config/makecoms.h
EXTRA_LIBS += $(MP_LIBS) $(COMM_LIBS)
LIBS += $(EXTRA_LIBS)
#......................................................................
LIBRARY = libarmci.a
HARDCLEAN = yes
#......................................................................

.PHONY : all
all: transp1D-c.x

%.x:%.c $(FULL_LIBRARY_PATH)
	$(CC) -g -I$(ARMCI_SRC) $(COPT_REN) $(MP_INCLUDES) $(MP_DEFINES) -o $@ $^ $(LIB_DISTRIB)/$(TARGET)/$(LIBRARY) $(LIBS) -lm

.PHONY : clean
clean: 
	$(RM) *.x
