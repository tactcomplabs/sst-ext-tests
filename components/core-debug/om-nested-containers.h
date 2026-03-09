//
// om-nested-containers.h
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

// Intent:  Verify debug console operations on simple arrays.
// 
#ifndef _SST_EXT_TESTS_OM_NESTED_CONTAINERS_H_
#define _SST_EXT_TESTS_OM_NESTED_CONTAINERS_H_

#include "omni.h"
#include <map>

namespace SST::ExtTest {

using MyType0 = std::vector<std::string>;
using MyType1 = std::tuple<MyType0, MyType0, MyType0>;
using MyType2 = std::map<MyType0, MyType1>;
using MyType3 = std::vector<MyType2>;

// -------------------------------------------------------
// OMNestedContainers (not registered)
// -------------------------------------------------------
class OMNestedContainers : public OMSubComponentAPI {
public:
  SST_ELI_REGISTER_SUBCOMPONENT(
        OMNestedContainers,            // Class name
        "dbgsst15",          // Library name
        "OMNestedContainers",          // Subcomponent name
        SST_ELI_ELEMENT_VERSION(1,0,0),  // A version number
        "Nested containers to generated very long type strings", 
        SST::ExtTest::OMSubComponentAPI) // Fully qualified API name
 
  OMNestedContainers(ComponentId_t id, Params& params);
  ~OMNestedContainers();

  void init(unsigned int phase) final {
    sstout_.verbose(CALL_INFO, 0, 0, "%s", list_type_traits(v_type3_).c_str());
  };
  
  virtual void update(payload_t& p) final;
  virtual void check() final;

public:
  // serialization support
  OMNestedContainers() : OMSubComponentAPI() {}; // required for serialization
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    OMSubComponentAPI::serialize_order(ser);
    SST_SER(sstout_);
    SST_SER(v_type3_);
  }
  ImplementSerializable(SST::ExtTest::OMNestedContainers)
private:
  SST::Output sstout_;
  MyType3 v_type3_;

}; //class OMNestedContainers

}//namespace SST::ExtTest

#endif  // _SST_EXT_TESTS_OM_NESTED_CONTAINERS_H_

// EOF
