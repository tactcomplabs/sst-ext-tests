//
// om-arrays.cc
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "om-arrays.h"

#include <cinttypes>
namespace SST::ExtTest {

OMArrays::OMArrays(ComponentId_t id, Params& params) : OMSubComponentAPI(id,params) {
  sstout_.init("[" + getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );
  for (uint16_t i=0; i<BUFFER_SIZE; i++) {
    v_ping_t[i] = i + 1;
    v_pong_t[i] = i;
  }

  double v = 1.0;
  for (size_t x=0; x<X_SIZE; x++) {
    for (size_t y=0; y<Y_SIZE; y++) {
      for (size_t z=0; z<Z_SIZE; z++) {
        v_xyz[x][y][z] = v;
        v = v + 1.0;
      }
    }
  }
}

OMArrays::~OMArrays() {}

void OMArrays::update(payload_t& p) {
  subcompapi_counter_++;
  assert(subcompapi_counter_ < UINT16_MAX);
  // copy old buffer
  memcpy(v_pong_t, v_ping_t, BUFFER_SIZE * sizeof(uint16_t));
  // new buffer
  for (size_t i=0; i<BUFFER_SIZE; i++)
    v_ping_t[i] += 1;
  // 3d array
  for (size_t x=0; x<X_SIZE; x++) {
    for (size_t y=0; y<Y_SIZE; y++) {
      for (size_t z=0; z<Z_SIZE; z++) {
        v_xyz[x][y][z] += 1.0;
      }
    }
  }
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

  double v = (double)subcompapi_counter_ + 1.0;
  for (size_t x=0; x<X_SIZE; x++) {
    for (size_t y=0; y<Y_SIZE; y++) {
      for (size_t z=0; z<Z_SIZE; z++) { 
        if (v_xyz[x][y][z] != v) {
          sstout_.fatal(CALL_INFO, -1, "v_xyz[%zu][%zu][%zu]: Expected %f but found %f\n", x,y,z, v, v_xyz[x][y][z]);
        }
        v += 1.0;
      }
    }
  }

}


}//namespace SST::ExtTest

// EOF
