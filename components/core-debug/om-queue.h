//
// om-queue.h
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#ifndef _SST_EXT_TESTS_OM_QUEUE_H_
#define _SST_EXT_TESTS_OM_QUEUE_H_

#include "omni.h"

namespace SST::ExtTest {

// -------------------------------------------------------
// OmSubComponentAPI subcomponent
// OMQueue (not registered)
// Testing: std::queue
// -------------------------------------------------------
class OMQueue : public OMSubComponentAPI {
public:
  SST_ELI_REGISTER_SUBCOMPONENT(
        OMQueue,            // Class name
        "dbgsst15",         // Library name
        "OMQueue",          // Subcomponent name
        SST_ELI_ELEMENT_VERSION(1,0,0),  // A version number
        "std::queue test sub-component", 
        SST::ExtTest::OMSubComponentAPI) // Fully qualified API name
 
  OMQueue(ComponentId_t id, Params& params);
  ~OMQueue() {}
  virtual void update(payload_t& p) final;
public:
  // serialization support
  OMQueue() : OMSubComponentAPI() {}; // required for serialization
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    OMSubComponentAPI::serialize_order(ser);
    SST_SER(v_queue_unsigned_);
  }
  ImplementSerializable(SST::ExtTest::OMQueue)
private:
  SST::Output sstout_;
  std::queue<uint32_t> v_queue_unsigned_;
}; //class OMQueue


} //namespace SST::ExtTest

#endif  // _SST_EXT_TESTS_OM_QUEUE_H_

// EOF
