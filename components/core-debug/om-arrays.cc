//
// om-arrays.cc
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "om-arrays.h"

namespace SST::ExtTest {

OMArrays::OMArrays(ComponentId_t id, Params& params) : OMSubComponentAPI(id,params) {
  sstout_.init("[" + getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );
  for (uint16_t i=0; i<BUFFER_SIZE; i++) {
    v_ping_t[i] = i + 1;
    v_pong_t[i] = i;
  }
}

OMArrays::~OMArrays() {}

void OMArrays::update(payload_t& p) {
  OMSubComponentAPI::update(p);

    memcpy(v_pong_t, v_ping_t, BUFFER_SIZE * sizeof(uint16_t));
    for (size_t i=0; i<BUFFER_SIZE; i++)
      v_ping_t[i] +=1;
}

}//namespace SST::ExtTest

// EOF
