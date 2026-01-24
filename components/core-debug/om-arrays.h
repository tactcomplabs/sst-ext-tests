//
// om-arrays.h
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

// Intent:  Verify debug console operations on simple arrays.
// 
#ifndef _SST_EXT_TESTS_OM_ARRAYS_H_
#define _SST_EXT_TESTS_OM_ARRAYS_H_

#include "omni.h"

#include <cassert>
#include <cstdint>
#include <queue>

namespace SST::ExtTest {

// -------------------------------------------------------
// OMArrays (not registered)
// -------------------------------------------------------
class OMArrays : public OMSubComponentAPI {
public:
  SST_ELI_REGISTER_SUBCOMPONENT(
        OMArrays,            // Class name
        "dbgsst15",          // Library name
        "OMArrays",          // Subcomponent name
        SST_ELI_ELEMENT_VERSION(1,0,0),  // A version number
        "Simple array test sub-component", 
        SST::ExtTest::OMSubComponentAPI) // Fully qualified API name
 
  OMArrays(ComponentId_t id, Params& params);
  ~OMArrays();
  virtual void update(payload_t& p) final;

public:
  static const size_t BUFFER_SIZE = 1000;
  // serialization support
  OMArrays() : OMSubComponentAPI() {}; // required for serialization
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    OMSubComponentAPI::serialize_order(ser);
    SST_SER(v_ping_t);
    SST_SER(v_pong_t);
  }
  ImplementSerializable(SST::ExtTest::OMArrays)
private:
  SST::Output sstout_;
  uint16_t v_ping_t[BUFFER_SIZE];
  uint16_t v_pong_t[BUFFER_SIZE];
}; //class OMArrays

}//namespace SST::ExtTest

#endif  // _SST_EXT_TESTS_OM_ARRAYS_H_

// EOF
