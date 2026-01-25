//
// om-unions.cc
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "om-unions.h"

namespace SST::ExtTest {

OMUnions::OMUnions(ComponentId_t id, Params& params) : OMSubComponentAPI(id,params) {
  sstout_.init("[" + getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );
  v_union_struct_trivial.v  = 0x11111111;
  v_union_struct_method_1.v = 0;
  #ifdef UNION_METHOD_2
  v_union_struct_method_2.v = 0x33333333;
  #endif
  v_union_int_float_trivial.f  = 0.0;
  v_union_int_float_method_1.f = 0.0;
  #ifdef UNION_METHOD_2
  v_union_int_float_method_2.v = 0.0;
  #endif
}

OMUnions::~OMUnions() {}

void OMUnions::update(payload_t& p) {
  subcompapi_counter_++;
  assert(subcompapi_counter_ < UINT32_MAX);
  v_union_struct_trivial.v  += 0x01010101;   
  v_union_struct_method_1.v += 0x02020202;   
  #ifdef UNION_METHOD_2
  v_union_struct_method_2.v += 0x03030303;   
  #endif

  v_union_int_float_trivial.f += 1.0f;
  v_union_int_float_method_1.f += 2.0f;
  #ifdef UNION_METHOD_2
  v_union_int_float_method_2.f += 3.0f;
  #endif
}

void OMUnions::check()
{

  sstout_.verbose(CALL_INFO, 0, 0, "Checking internal state\n");
  uint32_t v0 = 0x11111111;
  uint32_t v1 = 0;
  float f0 = 0.0f;
  float f1 = 0.0f;

  for (size_t i=0; i<subcompapi_counter_; i++) {
    v0 += 0x01010101;
    v1 += 0x02020202;
    f0 += 1.0f;
    f1 += 2.0f;
  }

  uint32_t e = v0;
  uint32_t f = v_union_struct_trivial.v;
  if ( e != f )
    sstout_.fatal(CALL_INFO, -1, "v_union_struct_trivial.v: Expected %" PRIx32 " but found %" PRIx32 "\n", e, f);

  e = v1;
  f = v_union_struct_method_1.v;
  if ( e != f )
    sstout_.fatal(CALL_INFO, -1, "v_union_struct_method_1.v: Expected %" PRIx32 " but found %" PRIx32 "\n", e, f);

  e = (uint32_t) f0;
  f = (uint32_t) v_union_int_float_trivial.f;
  if ( e != f )
    sstout_.fatal(CALL_INFO, -1, "v_union_int_float_trivial.f: Expected %" PRIx32 " but found %" PRIx32 "\n", e, f);

  e = (uint32_t) f1;
  f = (uint32_t) v_union_int_float_method_1.f;
  if ( e != f )
    sstout_.fatal(CALL_INFO, -1, "v_union_int_float_method_1.f: Expected %" PRIx32 " but found %" PRIx32 "\n", e, f);

}

}//namespace SST::ExtTest

// EOF
