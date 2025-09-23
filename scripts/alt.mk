#
# Makefile
# Alternative test run flow to check that we're not over-filtering tests.
#

# Copyright (C) 2017-2024 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#

# gtimeout requires coreutils
ifndef TIMEOUT_COMMAND
  ifneq (, $(shell which gtimeout))
    TIMEOUT_COMMAND = gtimeout
  else
    ifneq (, $(shell which timeout))
      TIMEOUT_COMMAND = timeout
    endif
  endif
endif
ifndef TIMEOUT_COMMAND
 $(error Could not locate a suitable timeout command)
endif

TIMEOUT ?= 60
ALLTESTS := $(wildcard *.sh)
SHLOGS = $(patsubst %.sh,%.shlog,$(ALLTESTS))
TARGS = $(SHLOGS)

all: $(TARGS)
	@ echo "Testing Done [$(CURDIR)]"

%.shlog: %.sh
	@($(TIMEOUT_COMMAND) $(TIMEOUT) $< >& $@ ) && echo "$@ ... Passed" || echo "$@ ... Failed"

.PHONY: clean

clean:
	@rm -f $(TARGS)

help:
	@echo "Run all .sh files in this directory to check against what ctest is running."
	@echo "The intent is to check whether tests are being excluded from running on"
	@echo "specific versions of SST and should be renamed ( or cmake flow fixed )"

#-- EOF
