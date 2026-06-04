//
// _dbgmin_cc_
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "dbgmin.h"

// #include <cinttypes>
// #include <sstream>

namespace SSTDEBUG::DbgMin {

//------------------------------------------
// DbgMin
//------------------------------------------
DbgMin::DbgMin(SST::ComponentId_t id, const SST::Params& params) :
    SST::Component(id),
    clocks(2),
    curCycle(0)
{
    output.init("DbgMin[" + getName() + ":@p:@t]: ", 1, 0, SST::Output::STDOUT);
    clockHandler               = new SST::Clock::Handler2<DbgMin, &DbgMin::clockTick>(this);
    timeConverter              = registerClock("1GHz", clockHandler);
    registerAsPrimaryComponent();
    primaryComponentDoNotEndSim();
}

void
DbgMin::serialize_order(SST::Core::Serialization::serializer& ser)
{
    SST::Component::serialize_order(ser);
    // debug console issue: output object serialization causing asan error
    #if 1
    SST_SER(output);
    #endif
    SST_SER(clocks);
}

bool
DbgMin::clockTick(SST::Cycle_t currentCycle)
{
    if ( currentCycle >= clocks ) {
        primaryComponentOKToEndSim();
        return true;
    }
    curCycle++;
    return false;
}

} // namespace SSTDEBUG::DbgMin

// EOF
