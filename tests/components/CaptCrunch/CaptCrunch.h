//
// _CaptCrunch_h_
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#ifndef _SST_CAPTCRUNCH_H_
#define _SST_CAPTCRUNCH_H_

// -- Standard Headers
#include <vector>
#include <queue>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <time.h>
#include <string>

// -- SST Headers
#include <sst/core/sst_config.h>
#include <sst/core/component.h>
#include <sst/core/event.h>
#include <sst/core/interfaces/simpleNetwork.h>
#include <sst/core/link.h>
#include <sst/core/output.h>
#include <sst/core/statapi/stataccumulator.h>
#include <sst/core/subcomponent.h>
#include <sst/core/timeConverter.h>
#include <sst/core/model/element_python.h>

namespace SST::CaptCrunch{

// -------------------------------------------------------
// CaptCrunch
// -------------------------------------------------------
class CaptCrunch : public SST::Component{
public:
  /// LargeStat: top-level SST component constructor
  CaptCrunch( SST::ComponentId_t id, const SST::Params& params );

  /// CaptCrunch: top-level SST component destructor
  ~CaptCrunch();

  /// CaptCrunch: standard SST component 'setup' function
  void setup() override;

  /// CaptCrunch: standard SST component 'finish' function
  void finish() override;

  /// CaptCrunch: standard SST component init function
  void init( unsigned int phase ) override;

  /// CaptCrunch: standard SST component clock function
  bool clockTick( SST::Cycle_t currentCycle );

  // -------------------------------------------------------
  // CaptCrunch Component Registration Data
  // -------------------------------------------------------
  /// CaptCrunch: Register the component with the SST core
  SST_ELI_REGISTER_COMPONENT( CaptCrunch,     // component class
                              "captcrunch",   // component library
                              "CaptCrunch",   // component name
                              SST_ELI_ELEMENT_VERSION( 1, 0, 0 ),
                              "Crunchatize me, Cap'n!",
                              COMPONENT_CATEGORY_UNCATEGORIZED )

  SST_ELI_DOCUMENT_PARAMS(
    {"verbose",         "Sets the verbosity level of output",           "0" },
    {"numStats",        "Sets the number of stats to create",           "1" },
    {"numClocks",       "Sets the number of clock cycles to execute",   "1" },
  )

  // -------------------------------------------------------
  // CaptCrunch SubComponent Parameter Data
  // -------------------------------------------------------
  SST_ELI_DOCUMENT_SUBCOMPONENT_SLOTS()

  // -------------------------------------------------------
  // CaptCrunch Component Statistics Data
  // -------------------------------------------------------
  SST_ELI_DOCUMENT_STATISTICS(
    {"STAT_", "Basic stat handler", "count", 1},
  )

  // -------------------------------------------------------
  // CaptCrunch Component Checkpoint Methods
  // -------------------------------------------------------
  /// Chkpnt: serialization constructor
  CaptCrunch() : SST::Component() {}

  /// CaptCrunch: serialization
  void serialize_order(SST::Core::Serialization::serializer& ser) override;

  /// CaptCrunch: serialization implementations
  ImplementSerializable(SST::CaptCrunch::CaptCrunch)

private:
  // -- internal handlers
  SST::Output    output;                          ///< SST output handler
  TimeConverter* timeConverter;                   ///< SST time conversion handler
  SST::Clock::HandlerBase* clockHandler;          ///< Clock Handler

  uint64_t numStats;                              ///< Number of stats to create
  uint64_t numClocks;                             ///< Number of clock cycles to run

  std::vector<Statistic<uint64_t>*> VStat;        ///< Statistics vector

  // -- internal functions
  /// CaptCrunch: initializes the internal data elements
  void initData();

  // ---------------------------------------
  // BEGIN SERIALIZED DATA STRUCTURES
  //
  // All data structures defined here must
  // be initialized in `initData` and
  // be serialized in `serialize_order`
  // ---------------------------------------

  uint8_t     u8Value;
  uint16_t    u16Value;
  uint32_t    u32Value;
  uint64_t    u64Value;
  int8_t      s8Value;
  int16_t     s16Value;
  int32_t     s32Value;
  int64_t     s64Value;
  char        cValue;

  unsigned            unsignedValue;
  signed              signedValue;
  unsigned long       uLongValue;
  unsigned long long  uLongLongValue;
  signed long         sLongValue;
  signed long long    sLongLongValue;

  struct __fundamentalTypeStruct{
    uint8_t     u8Value;
    uint16_t    u16Value;
    uint32_t    u32Value;
    uint64_t    u64Value;
    int8_t      s8Value;
    int16_t     s16Value;
    int32_t     s32Value;
    int64_t     s64Value;
    char        cValue;

    unsigned            unsignedValue;
    signed              signedValue;
    unsigned long       uLongValue;
    unsigned long long  uLongLongValue;
    signed long         sLongValue;
    signed long long    sLongLongValue;

    void serialize_order(SST::Core::Serialization::serializer& ser){
      SST_SER(u8Value);
      SST_SER(u16Value);
      SST_SER(u32Value);
      SST_SER(u64Value);
      SST_SER(s8Value);
      SST_SER(s16Value);
      SST_SER(s32Value);
      SST_SER(s64Value);
      SST_SER(cValue);
      SST_SER(unsignedValue);
      SST_SER(signedValue);
      SST_SER(uLongValue);
      SST_SER(uLongLongValue);
      SST_SER(sLongValue);
      SST_SER(sLongLongValue);
    }
  };
  struct __fundamentalTypeStruct fTypeStructValue;

  std::string         strValue;

  std::vector<unsigned> unsignedVect;
  std::vector<char>     charVect;

  std::list<unsigned>   unsignedList;
  std::list<char>       charList;

  std::array<unsigned,2>unsignedArray;
  std::array<char,2>    charArray;

  std::map<unsigned,unsigned> unsignedMap;
  std::map<char,unsigned>     charMap;

  std::vector<std::vector<unsigned>>        unsignedVectVect;
  std::vector<std::list<unsigned>>          unsignedListVect;
  std::vector<std::array<unsigned,2>>       unsignedArrayVect;
  std::vector<std::map<unsigned,unsigned>>  unsignedMapVect;

  std::list<std::list<unsigned>>            unsignedListList;
  std::list<std::vector<unsigned>>          unsignedVectList;
  std::list<std::array<unsigned,2>>         unsignedArrayList;
  std::list<std::map<unsigned,unsigned>>    unsignedMapList;

  // ---------------------------------------
  // END SERIALIZED DATA STRUCTURES
  // ---------------------------------------

};  // class CaptCrunch
}   // namespace SST::CaptCrunch

#endif  // _SST_LARGESTATCHKPNT_H_

// EOF
