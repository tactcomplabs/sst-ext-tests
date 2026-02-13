//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
// See LICENSE in the top level directory for licensing details
//

#ifndef _SST_EXT_TESTS_TCLDBG_H_
#define _SST_EXT_TESTS_TCLDBG_H_

#include <iostream>
#include <ostream>
#include <unistd.h>

namespace tcldbg {

static inline void
spin(const char* id = "")
{
    std::cout << id << " spinning" << std::endl;
    unsigned long spinner = 1;
    while ( spinner > 0 ) {
        spinner++;
        usleep(100000);
        if ( spinner % 10 == 0 ) // breakpoint here
            std::cout << "." << std::flush;
    }
    std::cout << std::endl;
}

static inline void
spinner(const char* id, bool cond = true)
{
    if ( !std::getenv(id) ) return;
    if ( !cond ) return;
    spin(id);
}

} // namespace tcldbg

#endif //_SST_EXT_TESTS_TCLDBG_H_
