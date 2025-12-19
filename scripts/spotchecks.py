#!/usr/bin/env python3

#
# Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
# All Rights Reserved
# contact@tactcomplabs.com
#
# See LICENSE in the top level directory for licensing details
#
# spotchecks.py
#

import re
import sys
from enum import Enum

class State(Enum):
    SCANNING = 0
    BUFFERING = 1
    CHECKING = 2

if (len(sys.argv) != 3):
    print("Usage: spotchecks.py number-of-checks log-file")
    sys.exit(1)

# return code decrements with each successful check
rc=int(sys.argv[1])
state = State.SCANNING

# re_check = re.compile('^# CHECK ([0-9]+) (.+)')
re_check = re.compile(".+# CHECK ([0-9]+) (.+)")
try:
    with open(sys.argv[2], 'r') as log:
        for line in log:
            if state==State.SCANNING:
                m = re_check.match(line)
                if m:
                    test_id = m.group(1)
                    test_re = re.compile(m.group(2))
                    test_counter = 200
                    print(id, test_re)
                    state=State.CHECKING
                next
            if state==state.CHECKING:
                if test_counter-- <= 0:

    

            

except FileNotFoundError:
    print(f"Error: could not find {sys.argv[2]}")
except Exception as e:
    print(f"An error occured: {e}")

sys.exit(rc)

