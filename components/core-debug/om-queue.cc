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
  OMSubComponentAPI::update(p);
  assert(v_queue_unsigned_.size()==3);
  unsigned front = v_queue_unsigned_.front() + 1;
  v_queue_unsigned_.pop();
  v_queue_unsigned_.push(front);
  sstout_.verbose(CALL_INFO, 0, 0, "v_queue_unsigned_.front()=%d\n", v_queue_unsigned_.front());
}

} //namespace SST::ExtTest

// EOF
