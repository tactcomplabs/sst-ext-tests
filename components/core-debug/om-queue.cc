//
// om-queue.cc
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "om-queue.h"

namespace SST::ExtTest {

OMQueue::OMQueue(ComponentId_t id, Params& params) : OMSubComponentAPI(id,params) {
  sstout_.init(getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );
  v_queue_unsigned_.push(100);
  v_queue_unsigned_.push(200);
  v_queue_unsigned_.push(300);
}

void OMQueue::update(payload_t& p) {
  subcompapi_counter_++;
  assert(subcompapi_counter_<UINT32_MAX);
  assert(v_queue_unsigned_.size()==3);
  unsigned front = v_queue_unsigned_.front() + 1;
  v_queue_unsigned_.pop();
  v_queue_unsigned_.push(front);
  sstout_.verbose(CALL_INFO, 1, 0, "v_queue_unsigned_.front()=%d\n", v_queue_unsigned_.front());
}

void OMQueue::check()
{
  sstout_.verbose(CALL_INFO, 0, 0, "Checking internal state\n");
  uint32_t e = 100 + (uint32_t) subcompapi_counter_/3;
  uint32_t f = v_queue_unsigned_.front();
  if ( f != e )
    sstout_.fatal(CALL_INFO, -1, "v_queue_unsigned_.front(): Expected %" PRIu32 " but found %" PRIu32 "\n", e, f);
}

} //namespace SST::ExtTest

// EOF
