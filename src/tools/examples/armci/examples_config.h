ARMCI_HOME = ../../../../../$(ARMCI_DIR_NAME)/src
ifndef TARGET
error:
	@echo "TARGET machine not defined"
	exit
endif
