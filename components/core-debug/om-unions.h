//
// om-unions.h
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

// Intent:  Demonstrate support of object mapping for common
//          cases of unions.  Unions are fraught with peril
//          and should generally be discouraged. However,
//          when memory footprint is critical, they are quite
//          efficient.  Two cases are included here:
//          1) uint32_t and bitfields: This can be used to 
//             model hardware registers as an alternative to
//             std::bitset (which supports object mapping).
//          2) int and float: Handy for floating point hardware 
// 
//          A secondary goal is to provide an example for the 
//          SST online documentation for a `serialize_impl`
//          specialization.
// 
#ifndef _SST_EXT_TESTS_OM_UNIONS
#define _SST_EXT_TESTS_OM_UNIONS

#include "omni.h"

#include <cassert>
#include <cstdint>
#include <queue>

//TODO Verify method2 works. Currently does not compile
// #define UNION_METHOD_2

namespace SST::ExtTest {

// A trivially serializable union will not be automatically mapped.
// https://github.com/sstsimulator/sst-core/pull/1515
// To suport mapping these:
// Method 1. Define a serialize_impl<SST::ExtTest::OMUnions::v_union_struct_trivial_t> specialization.
// Method 2. Add a constructor taking a std::string and an operator std::string() const to SST::ExtTest::OMUnions::v_union_struct_trivial_t, to allow conversion from/to std::string.

union v_union_struct_trivial_t {
    uint32_t v = 0;
    struct {
        uint32_t b5_0   : 6;   // [5:0]
        uint32_t b7_6   : 2;   // [7:6] 
        uint32_t b10_8  : 3;   // [10:8]
        uint32_t b26_11 : 16;  // [26:11]
        uint32_t b30_27 : 4;   // [30:27]
        uint32_t b31    : 1;   // [31]
    } f;
};

static_assert(std::is_aggregate_v<v_union_struct_trivial_t>);

// Define a serialize_impl<SST::ExtTest::v_union_struct_method_1_t> specialization.
union v_union_struct_method_1_t {
    uint32_t v = 0;
    struct {
        uint32_t b5_0   : 6;   // [5:0]
        uint32_t b7_6   : 2;   // [7:6] 
        uint32_t b10_8  : 3;   // [10:8]
        uint32_t b26_11 : 16;  // [26:11]
        uint32_t b30_27 : 4;   // [30:27]
        uint32_t b31    : 1;   // [31]
    } f;
};

static_assert(std::is_aggregate_v<v_union_struct_method_1_t>);

#ifdef UNION_METHOD_2
// Add a constructor taking a std::string 
// and an operator std::string() const to SST::ExtTest::v_union_struct_trivial_t
// to allow conversion from/to std::string.
union v_union_struct_method_2_t {
    uint32_t v = 0;
    struct {
        uint32_t b5_0   : 6;   // [5:0]
        uint32_t b7_6   : 2;   // [7:6] 
        uint32_t b10_8  : 3;   // [10:8]
        uint32_t b26_11 : 16;  // [26:11]
        uint32_t b30_27 : 4;   // [30:27]
        uint32_t b31    : 1;   // [31]
    } f;
    v_union_struct_method_2_t() {};
    explicit v_union_struct_method_2_t(std::string str) {
      uint32_t value;
      auto [ptr, ec] = std::from_chars(str.data(), str.data() + str.size(), value);
      if (ec ==std::errc{}) { 
        this->v = value;
      } else if (ec == std::errc::invalid_argument) {
        std::cerr << "Conversion error: invalid argument" << std::endl;
      } else if ( ec == std::errc::result_out_of_range) {
        std::cerr << "Conversion error: Value out of range" << std::endl;
      }
    };
    std::string operator()(v_union_struct_method_2_t& t) const {
      std::stringstream ss;
      ss << "0x" << std::hex << std::uppercase << t.v;
      return ss.str();
    };
}; //union v_union_struct_method_2_t

static_assert(! std::is_aggregate_v<v_union_struct_method_2_t>);
#endif

// Repeat the exercise
union v_union_int_float_trivial_t{
  int i = 0;
  float f;
};

union v_union_int_float_method_1_t {
  int i = 0;
  float f;
};

#ifdef UNION_METHOD_2
//TODO
// union v_union_int_float_method_2_t {
  int i = 0;
  float f;
};
#endif

// -------------------------------------------------------
// OMUnions (not registered)
// -------------------------------------------------------
class OMUnions : public OMSubComponentAPI {
public:
  SST_ELI_REGISTER_SUBCOMPONENT(
        OMUnions,            // Class name
        "dbgsst15",          // Library name
        "OMUnions",          // Subcomponent name
        SST_ELI_ELEMENT_VERSION(1,0,0),  // A version number
        "Simple subcomponent for object map evaluation", 
        SST::ExtTest::OMSubComponentAPI) // Fully qualified API name
 
  OMUnions(ComponentId_t id, Params& params);
  ~OMUnions();
  virtual void update(payload_t& p) final;

public:
  // serialization support
  OMUnions() : OMSubComponentAPI() {}; // required for serialization
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    OMSubComponentAPI::serialize_order(ser);
    SST_SER(v_union_struct_trivial);  // trivially serializable type will not be mapped
    SST_SER(v_union_struct_method_1); // Define a serialize_impl
    #ifdef UNION_METHOD_2
    SST_SER(v_union_struct_method_2); // Add a constructor taking a std::string and an operator std::string() const
    #endif
    SST_SER(v_union_int_float_trivial);  // trivially serializable type will not be mapped
    SST_SER(v_union_int_float_method_1); // Define a serialize_impl
    #ifdef UNION_METHOD_2
    SST_SER(v_union_int_float_method_2); // Add a constructor taking a std::string and an operator std::string() const
    #endif
  }
  ImplementSerializable(SST::ExtTest::OMUnions)
private:
  SST::Output sstout_;

  v_union_struct_trivial_t  v_union_struct_trivial;
  v_union_struct_method_1_t v_union_struct_method_1;
  #ifdef UNION_METHOD_2
  v_union_struct_method_2_t v_union_struct_method_2;
  #endif

  v_union_int_float_trivial_t v_union_int_float_trivial;
  v_union_int_float_method_1_t v_union_int_float_method_1;
  #ifdef UNION_METHOD_2
  v_union_int_float_method_2_t v_union_struct_method_2;
  #endif

}; //class OMUnions
}//namespace SST::ExtTest

// SST::Core::Serialization::serialize_impl specializations.
// and unions are supposed to be simple, right?
namespace SST::Core::Serialization {

// Method 1. Define a serialize_impl<SST::ExtTest::v_union_struct_method_1_t> specialization.
template <>
class serialize_impl<SST::ExtTest::v_union_struct_method_1_t>
{
  void operator()(SST::ExtTest::v_union_struct_method_1_t& t, serializer& ser, ser_opt_t UNUSED(options)) {
    if ( ser.mode() != serializer::MAP ) {
      SST_SER(t);
      return;
    }
    // Object map specialization
    ser_opt_t opt = SerOption::is_set(options, SerOption::as_ptr_elem) ? SerOption::as_ptr : SerOption::none;
    ser.mapper().map_hierarchy_start(ser.getMapName(), new ObjectMapContainer<SST::ExtTest::v_union_struct_method_1_t>(&t));
    SST_SER_NAME(t.v, "v", opt);
    //struct f containing the bit fields will require a more complex proxy wrapper of some sort
    ser.mapper().map_hierarchy_end();
  };
  SST_FRIEND_SERIALIZE();
};

// Method 1. Define a serialize_impl<SST::ExtTest::v_union_int_float_method_1_t> specialization.
template <>
class serialize_impl<SST::ExtTest::v_union_int_float_method_1_t>
{
  void operator()(SST::ExtTest::v_union_int_float_method_1_t& t, serializer& ser, ser_opt_t UNUSED(options)) {
    if ( ser.mode() != serializer::MAP ) {
      SST_SER(t);
      return;
    }
    // Object map specialization
    ser_opt_t opt = SerOption::is_set(options, SerOption::as_ptr_elem) ? SerOption::as_ptr : SerOption::none;
    ser.mapper().map_hierarchy_start(ser.getMapName(), new ObjectMapContainer<SST::ExtTest::v_union_int_float_method_1_t>(&t));
    SST_SER_NAME(t.f, "f", opt);
    //struct f containing the bit fields would require a more complex proxy wrapper of some sort
    ser.mapper().map_hierarchy_end();
  };
  SST_FRIEND_SERIALIZE();
};// class serialize_impl<SST::ExtTest::v_union_int_float_method_1_t>
} //namespace SST::Core::Serialization

#endif  // _SST_EXT_TESTS_OM_UNIONS

// EOF
