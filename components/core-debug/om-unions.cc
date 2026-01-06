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
  sstout_.init(getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );
  v_union_struct_trivial.v  = 0x11111111;
  v_union_struct_method_1.v = 0x22222222;
  #ifdef UNION_METHOD_2
  v_union_struct_method_2.v = 0x33333333;
  #endif
  v_union_int_float_trivial.f  = 0x11111111;
  v_union_struct_method_1.v = 0x22222222;
  #ifdef UNION_METHOD_2
  v_union_struct_method_2.v = 0x33333333;
  #endif
}

OMUnions::~OMUnions() {}

void OMUnions::update(payload_t& p) {
  OMSubComponentAPI::update(p);

  v_union_struct_trivial.f.b5_0   += 1;   
  v_union_struct_trivial.f.b7_6   += 1;
  v_union_struct_trivial.f.b10_8  += 1;
  v_union_struct_trivial.f.b26_11 += 1;
  v_union_struct_trivial.f.b30_27 += 1;
  v_union_struct_trivial.f.b31    += 1;

  v_union_struct_method_1.f.b5_0   += 2;   
  v_union_struct_method_1.f.b7_6   += 2;
  v_union_struct_method_1.f.b10_8  += 2;
  v_union_struct_method_1.f.b26_11 += 2;
  v_union_struct_method_1.f.b30_27 += 2;
  v_union_struct_method_1.f.b31    += 2;

  #ifdef UNION_METHOD_2
  v_union_struct_method_2.f.b5_0   += 3;   
  v_union_struct_method_2.f.b7_6   += 3;
  v_union_struct_method_2.f.b10_8  += 3;
  v_union_struct_method_2.f.b26_11 += 3;
  v_union_struct_method_2.f.b30_27 += 3;
  v_union_struct_method_2.f.b31    += 3;
  #endif

  v_union_int_float_trivial.f += 1;
  v_union_int_float_method_1.f += 2;
  #ifdef UNION_METHOD_2
  v_union_int_float_method_2.f += 3;
  #endif
}

}//namespace SST::ExtTest

// EOF
