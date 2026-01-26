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
  subcompapi_counter_++;
  assert(subcompapi_counter_ < UINT16_MAX);
  memcpy(v_pong_t, v_ping_t, BUFFER_SIZE * sizeof(uint16_t));
  for (size_t i=0; i<BUFFER_SIZE; i++)
    v_ping_t[i] += 1;
}

void OMArrays::check()
{
  sstout_.verbose(CALL_INFO, 0, 0, "Checking internal state\n");
  for (uint16_t i=0; i<BUFFER_SIZE; i++) {
    uint16_t e = (uint16_t)subcompapi_counter_ + i;
    if (v_pong_t[i] != e) 
      sstout_.fatal(CALL_INFO, -1, "v_pong[%" PRIu16 "]: Expected %" PRIu16 " but found %" PRIu16 "\n", i, e, v_pong_t[i]);
    if (v_ping_t[i] != e + 1) 
      sstout_.fatal(CALL_INFO, -1, "v_ping[%" PRIu16 "]: Expected %" PRIu16 " but found %" PRIu16 "\n", i, e, v_ping_t[i]);
  }
}


}//namespace SST::ExtTest

// EOF
