//
// om-nested-containers.cc
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "om-nested-containers.h"
namespace SST::ExtTest {

OMNestedContainers::OMNestedContainers(ComponentId_t id, Params& params) : OMSubComponentAPI(id,params) {
  sstout_.init("[" + getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );

  MyType0 t0a = { "one", "two", "three" };
  MyType0 t0b = { "four", "five", "six" };
  MyType0 t0c = { "seven", "eight", "nine" };
  MyType1 t1 = std::make_tuple(t0a, t0b, t0c);
  MyType2 t2 = { { t0a, t1} };
  v_type3_ = { t2, t2, t2, t2, t2 };
}

OMNestedContainers::~OMNestedContainers() {}

void OMNestedContainers::update(payload_t& p) {
  subcompapi_counter_++;
}

void OMNestedContainers::check()
{
  sstout_.verbose(CALL_INFO, 0, 0, "Checking internal state\n");
}


}//namespace SST::ExtTest

// EOF
