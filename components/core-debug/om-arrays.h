//
// om-arrays.h
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
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

#include <cstddef>
#include <cstdint>

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

  void init(unsigned int phase) final {
    sstout_.verbose(CALL_INFO, 0, 0, "%s", list_type_traits(v_ping_t).c_str());
  };
  
  virtual void update(payload_t& p) final;
  virtual void check() final;

public:
  static const size_t BUFFER_SIZE = 1000;
  static const size_t X_SIZE = 3;
  static const size_t Y_SIZE = 5;
  static const size_t Z_SIZE = 7;
  // serialization support
  OMArrays() : OMSubComponentAPI() {}; // required for serialization
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    OMSubComponentAPI::serialize_order(ser);
    SST_SER(sstout_);
    SST_SER(v_ping_t);
    SST_SER(v_pong_t);
    SST_SER(v_xyz);
  }
  ImplementSerializable(SST::ExtTest::OMArrays)
private:
  SST::Output sstout_;
  uint16_t v_ping_t[BUFFER_SIZE] = { };
  uint16_t v_pong_t[BUFFER_SIZE] = { };
  double v_xyz[X_SIZE][Y_SIZE][Z_SIZE] = { };

}; //class OMArrays

}//namespace SST::ExtTest

#endif  // _SST_EXT_TESTS_OM_ARRAYS_H_

// EOF
