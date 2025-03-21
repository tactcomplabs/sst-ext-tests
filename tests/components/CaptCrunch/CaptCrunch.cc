//
// _CaptCrunch_cc_
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "CaptCrunch.h"

namespace SST::CaptCrunch{

  //------------------------------------------
  // CaptCrunch
  //------------------------------------------
  CaptCrunch::CaptCrunch(SST::ComponentId_t id, const SST::Params& params ) :
    SST::Component( id ), timeConverter(nullptr), clockHandler(nullptr),
    numStats(1), numClocks(1) {
    const int Verbosity = params.find< int >( "verbose", 0 );
    output.init(
      "CaptCrunch[" + getName() + ":@p:@t]: ",
      Verbosity, 0, SST::Output::STDOUT );
    output.verbose( CALL_INFO, 5, 0, "Init is complete\n" );
    clockHandler  = new SST::Clock::Handler2<CaptCrunch,
                  &CaptCrunch::clockTick>(this);
    timeConverter = registerClock("1GHz", clockHandler);
    registerAsPrimaryComponent();
    primaryComponentDoNotEndSim();

    // read the remainder of the parameters
    numStats = params.find<uint64_t>( "numStats", 1 );
    numClocks = params.find<uint64_t>( "numClocks", 1);

    output.verbose( CALL_INFO, 0, 0, "numStats=%" PRIu64 "\n", numStats );
    output.verbose( CALL_INFO, 0, 0, "numClocks=%" PRIu64 "\n", numClocks );

    // initialize the statistics
    for( auto i = 0x00ull; i<numStats; i++ ){
      std::string sName = std::to_string(i);
      VStat.push_back(registerStatistic<uint64_t>("STAT_", sName));
    }

    // initialize all the internal data structures for serialization
    initData();
  }

  CaptCrunch::~CaptCrunch(){
  }

  void CaptCrunch::setup(){
  }

  void CaptCrunch::finish(){
  }

  void CaptCrunch::init( unsigned int phase ){
  }

  void CaptCrunch::serialize_order(SST::Core::Serialization::serializer& ser){
    SST::Component::serialize_order(ser);
    // -- core data structure serialization
    SST_SER(clockHandler)
    SST_SER(numStats)
    SST_SER(numClocks)

    // -- statistics serialization
    SST_SER(VStat)

    // -- serialize everything else
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

    SST_SER(fTypeStructValue);

    SST_SER(strValue);

    SST_SER(unsignedVect);
    SST_SER(charVect);
    SST_SER(unsignedList);
    SST_SER(charList);
    //SST_SER(unsignedArray); // TODO: broken
    //SST_SER(charArray);     // TODO: broken
    SST_SER(unsignedMap);
    SST_SER(charMap);
    SST_SER(unsignedVectVect);
    SST_SER(unsignedListVect);
    //SST_SER(unsignedArrayVect); // TODO: broken
    SST_SER(unsignedMapVect);
    SST_SER(unsignedListList);
    SST_SER(unsignedVectList);
    //SST_SER(unsignedArrayList); // TODO: broken
    SST_SER(unsignedMapList);
  }

  void CaptCrunch::initData(){
    u8Value     = 0x01;
    u16Value    = 0x02;
    u32Value    = 0x03;
    u64Value    = 0x04;
    s8Value     = -0x01;
    s16Value    = -0x02;
    s32Value    = -0x03;
    s64Value    = -0x04;
    cValue      = 'Y';  // because, "Y" are we doing this?

    unsignedValue   = 1234;
    signedValue     = -1234;
    uLongValue      = 1234ul;
    uLongLongValue  = 1234ull;
    sLongValue      = -1234ul;
    sLongLongValue  = -1234ull;

    fTypeStructValue.u8Value        = 0x01;
    fTypeStructValue.u16Value       = 0x02;
    fTypeStructValue.u32Value       = 0x03;
    fTypeStructValue.u64Value       = 0x04;
    fTypeStructValue.s8Value        = -0x01;
    fTypeStructValue.s16Value       = -0x02;
    fTypeStructValue.s32Value       = -0x03;
    fTypeStructValue.s64Value       = -0x04;
    fTypeStructValue.cValue         = 'X';
    fTypeStructValue.unsignedValue  = 0x12;
    fTypeStructValue.signedValue    = -0x12;
    fTypeStructValue.uLongValue     = 0x13ul;
    fTypeStructValue.uLongLongValue = 0x13ull;
    fTypeStructValue.sLongValue     = -0x13ul;
    fTypeStructValue.sLongLongValue = -0x13ull;

    strValue = "Crunchatize me, Cap'n!";

    unsignedVect.push_back(unsignedValue);
    unsignedVect.push_back(unsignedValue+1);

    charVect.push_back(cValue);
    charVect.push_back(cValue+1);

    unsignedList.push_back(unsignedValue);
    unsignedList.push_front(unsignedValue+1);

    charList.push_back(cValue);
    charList.push_front(cValue+1);

    unsignedArray[0]  = unsignedValue;
    unsignedArray[1]  = unsignedValue+1;

    charArray[0]      = cValue;
    charArray[1]      = cValue+1;

    unsignedMap[0] = 0x1234;
    unsignedMap[1] = 0x5678;

    charMap['A'] = 0xdead;
    charMap['B'] = 0xbeef;

    unsignedVectVect.push_back(unsignedVect);
    unsignedVectVect.push_back(unsignedVect);
    unsignedArrayVect.push_back(unsignedArray);
    unsignedArrayVect.push_back(unsignedArray);
    unsignedMapVect.push_back(unsignedMap);
    unsignedMapVect.push_back(unsignedMap);

    unsignedListVect.push_back(unsignedList);
    unsignedListVect.push_back(unsignedList);

    unsignedListList.push_back(unsignedList);
    unsignedListList.push_front(unsignedList);

    unsignedVectList.push_back(unsignedVect);
    unsignedVectList.push_front(unsignedVect);

    unsignedArrayList.push_back(unsignedArray);
    unsignedArrayList.push_front(unsignedArray);

    unsignedMapList.push_back(unsignedMap);
    unsignedMapList.push_front(unsignedMap);
  }

  bool CaptCrunch::clockTick( SST::Cycle_t currentCycle ){
    if( (uint64_t)(currentCycle) >= numClocks ){
      primaryComponentOKToEndSim();
      return true;
    }
    return false;
  }
}

// EOF
