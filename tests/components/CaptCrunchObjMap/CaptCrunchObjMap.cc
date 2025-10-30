//
// _CaptCrunchObjMap_cc_
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "CaptCrunchObjMap.h"

#include <functional>
#include <limits>

namespace SST::CaptCrunchObjMap{

static std::map<int, std::function<void(SST::CaptCrunchObjMap::CaptCrunchObjMap&, SST::Core::Serialization::serializer&)> > const testSuiteLookUpTable = {

   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::IntegralTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteIntegral(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::StringTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteString(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UserDefinedTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteUserDefinedType(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::CharTupleTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteCharTuple(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::VectorTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteVector(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::StackTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteStack(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::QueueTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteQueue(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::DQTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteDQ(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::FLTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteFL(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::ListTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteList(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::ArrayTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteArray(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::SetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteSet(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::MapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteMap(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::MSetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteMSet(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::MMapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteMMap(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnSetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteUnSet(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnMapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteUnMap(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnMSetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteUnMSet(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnMMapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteMMap(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::VectVectTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteVectVect(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::ListListTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteListList(ser); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::VectVectVectTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) { c.testSuiteVectVectVect(ser); } },
   { std::numeric_limits<std::uint64_t>::max(), [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c, SST::Core::Serialization::serializer& ser) {
      c.testSuiteIntegral(ser);
      c.testSuiteString(ser);
      c.testSuiteUserDefinedType(ser);
      c.testSuiteCharTuple(ser);
      c.testSuiteVector(ser);
      c.testSuiteStack(ser);
      c.testSuiteQueue(ser);
      c.testSuiteDQ(ser);
      c.testSuiteFL(ser);
      c.testSuiteList(ser);
      c.testSuiteArray(ser);
      c.testSuiteSet(ser);
      c.testSuiteMap(ser);
      c.testSuiteMSet(ser);
      c.testSuiteMMap(ser);
      c.testSuiteUnSet(ser);
      c.testSuiteUnMap(ser);
      c.testSuiteUnMSet(ser);
      c.testSuiteMMap(ser);
      c.testSuiteVectVect(ser);
      c.testSuiteListList(ser);
      c.testSuiteVectVectVect(ser);
   }}

};

static std::map<int, std::function<void(SST::CaptCrunchObjMap::CaptCrunchObjMap&)> > const testSuiteInitLookUpTable = {

   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::IntegralTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitIntegral(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::StringTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitString(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UserDefinedTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitUserDefinedType(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::CharTupleTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitCharTuple(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::VectorTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitVector(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::StackTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitStack(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::QueueTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitQueue(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::DQTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitDQ(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::FLTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitFL(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::ListTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitList(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::ArrayTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitArray(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::SetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitSet(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::MapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitMap(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::MSetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitMSet(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::MMapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitMMap(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnSetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitUnSet(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnMapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitUnMap(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnMSetTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitUnMSet(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::UnMMapTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitUnMMap(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::VectVectTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitVectVect(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::ListListTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitListList(); } },
   { SST::CaptCrunchObjMap::CaptCrunchTestSuite::VectVectVectTypes, [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) { c.testSuiteInitVectVectVect(); } },
   { std::numeric_limits<std::uint64_t>::max(), [](SST::CaptCrunchObjMap::CaptCrunchObjMap& c) {
      c.testSuiteInitIntegral();
      c.testSuiteInitString();
      c.testSuiteInitUserDefinedType();
      c.testSuiteInitCharTuple();
      c.testSuiteInitVector();
      c.testSuiteInitStack();
      c.testSuiteInitQueue();
      c.testSuiteInitDQ();
      c.testSuiteInitFL();
      c.testSuiteInitList();
      c.testSuiteInitArray();
      c.testSuiteInitSet();
      c.testSuiteInitMap();
      c.testSuiteInitMSet();
      c.testSuiteInitMMap();
      c.testSuiteInitUnSet();
      c.testSuiteInitUnMap();
      c.testSuiteInitUnMSet();
      c.testSuiteInitUnMMap();
      c.testSuiteInitVectVect();
      c.testSuiteInitListList();
      c.testSuiteInitVectVectVect();
   }}
};

  //------------------------------------------
  // CaptCrunchObjMap
  //------------------------------------------
  CaptCrunchObjMap::CaptCrunchObjMap(SST::ComponentId_t id, const SST::Params& params ) :
    SST::Component( id ), timeConverter(nullptr), clockHandler(nullptr),
    numStats(1), numClocks(1), testSuiteParam(0) {
    const int Verbosity = params.find< int >( "verbose", 0 );
    output.init(
      "CaptCrunchObjMap[" + getName() + ":@p:@t]: ",
      Verbosity, 0, SST::Output::STDOUT );
    output.verbose( CALL_INFO, 5, 0, "Init is complete\n" );
    clockHandler  = new SST::Clock::Handler2<CaptCrunchObjMap,
                  &CaptCrunchObjMap::clockTick>(this);
    timeConverter = registerClock("1GHz", clockHandler);
    registerAsPrimaryComponent();
    primaryComponentDoNotEndSim();

    // read the remainder of the parameters
    numStats = params.find<uint64_t>( "numStats", 1 );
    numClocks = params.find<uint64_t>( "numClocks", 1);
    testSuiteParam = params.find<uint64_t>( "testSuiteParam", std::numeric_limits<uint64_t>::max());

    output.verbose( CALL_INFO, 0, 0, "numStats=%" PRIu64 "\n", numStats );
    output.verbose( CALL_INFO, 0, 0, "numClocks=%" PRIu64 "\n", numClocks );
    output.verbose( CALL_INFO, 0, 0, "testSuiteParam=%" PRIu64 "\n", testSuiteParam );
    output.verbose( CALL_INFO, 0, 0, "testSuiteParamMAX=%" PRIu64 "\n", (uint64_t)(testSuiteParam == std::numeric_limits<uint64_t>::max()) );

    // initialize the statistics
    for( auto i = 0x00ull; i<numStats; i++ ){
      std::string sName = std::to_string(i);
      VStat.push_back(registerStatistic<uint64_t>("STAT_", sName));
    }

    // initialize all the internal data structures for serialization
    initData();
  }

  CaptCrunchObjMap::~CaptCrunchObjMap(){
  }

  void CaptCrunchObjMap::setup(){
  }

  void CaptCrunchObjMap::finish(){
  }

  void CaptCrunchObjMap::testSuiteIntegral(SST::Core::Serialization::serializer& ser) {
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
  }

  void CaptCrunchObjMap::testSuiteInitIntegral() {
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
  }

  void CaptCrunchObjMap::testSuiteString(SST::Core::Serialization::serializer& ser) {
       SST_SER(strValue);
  }

  void CaptCrunchObjMap::testSuiteInitString() {
    strValue = "Crunchatize me, Cap'n!";
  }

  void CaptCrunchObjMap::testSuiteUserDefinedType(SST::Core::Serialization::serializer& ser) {
       SST_SER(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteInitUserDefinedType() {
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
  }

  void CaptCrunchObjMap::testSuiteCharTuple(SST::Core::Serialization::serializer& ser) {
       SST_SER(unsignedCharTuple); //skk fails for obj map
  }


  void CaptCrunchObjMap::testSuiteInitCharTuple() {
      unsignedCharTuple = std::make_tuple(unsignedValue,cValue);
  }

  void CaptCrunchObjMap::testSuiteVector(SST::Core::Serialization::serializer& ser) {
       SST_SER(unsignedVect); 
       SST_SER(charVect);
       SST_SER(structVect);
  }

  void CaptCrunchObjMap::testSuiteInitVector() {
      unsignedVect.push_back(unsignedValue);
      unsignedVect.push_back(unsignedValue+1);

      charVect.push_back(cValue);
      charVect.push_back(cValue+1);

      structVect.push_back(fTypeStructValue);
      structVect.push_back(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteStack(SST::Core::Serialization::serializer& ser) {
       SST_SER(unsignedStack);
       SST_SER(charStack);
       SST_SER(structStack);
  }

  void CaptCrunchObjMap::testSuiteInitStack() {
      unsignedStack.push(unsignedValue);
      unsignedStack.push(unsignedValue+1);

      charStack.push(cValue);
      charStack.push(cValue+1);

      structStack.push(fTypeStructValue);
      structStack.push(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteQueue(SST::Core::Serialization::serializer& ser) {
       SST_SER(unsignedQueue);  //skk naming is difficult for queues
       SST_SER(charQueue);
       SST_SER(structQueue);

       SST_SER(unsignedPQueue);
       SST_SER(charPQueue);
       SST_SER(structPQueue);
  }

  void CaptCrunchObjMap::testSuiteInitQueue() {
      unsignedQueue.push(unsignedValue);
      unsignedQueue.push(unsignedValue+1);

      charQueue.push(cValue);
      charQueue.push(cValue+1);

      structQueue.push(fTypeStructValue);
      structQueue.push(fTypeStructValue);

      unsignedPQueue.push(unsignedValue);
      unsignedPQueue.push(unsignedValue+1);

      charPQueue.push(cValue);
      charPQueue.push(cValue+1);

      structQueue.push(fTypeStructValue);
      structQueue.push(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteDQ(SST::Core::Serialization::serializer& ser) {
     SST_SER(unsignedDQ);
     SST_SER(charDQ);
     SST_SER(structDQ);
  }

  void CaptCrunchObjMap::testSuiteInitDQ() {
     unsignedDQ.push_front(unsignedValue);
     unsignedDQ.push_front(unsignedValue+1);

     charDQ.push_front(cValue);
     charDQ.push_front(cValue+1);

     structDQ.push_front(fTypeStructValue);
     structDQ.push_front(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteFL(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedFL);
    SST_SER(charFL);
    SST_SER(structFL);
  }

  void CaptCrunchObjMap::testSuiteInitFL() {
     unsignedFL.push_front(unsignedValue);
     unsignedFL.push_front(unsignedValue+1);

     charFL.push_front(cValue);
     charFL.push_front(cValue+1);

     structFL.push_front(fTypeStructValue);
     structFL.push_front(fTypeStructValue);
  }
 
  void CaptCrunchObjMap::testSuiteList(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedList);
    SST_SER(charList);
    SST_SER(structList);
  }

  void CaptCrunchObjMap::testSuiteInitList() {
    unsignedList.push_back(unsignedValue);
    unsignedList.push_front(unsignedValue+1);

    charList.push_back(cValue);
    charList.push_front(cValue+1);

    structList.push_back(fTypeStructValue);
    structList.push_front(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteArray(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedArray); // TODO: broken
    SST_SER(charArray);     // TODO: broken
    SST_SER(structArray);   // TODO: broken
  }

  void CaptCrunchObjMap::testSuiteInitArray() {
    unsignedArray[0]  = unsignedValue;
    unsignedArray[1]  = unsignedValue+1;

    charArray[0]      = cValue;
    charArray[1]      = cValue+1;

    structArray[0]    = fTypeStructValue;
    structArray[1]    = fTypeStructValue;
  }

  void CaptCrunchObjMap::testSuiteSet(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedSet);
    SST_SER(charSet);
    SST_SER(structSet);
  }

  void CaptCrunchObjMap::testSuiteInitSet() {
    unsignedSet.insert(unsignedValue);
    unsignedSet.insert(unsignedValue+1);

    charSet.insert(cValue);
    charSet.insert(cValue+1);

    structSet.insert(fTypeStructValue);
    structSet.insert(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteMap(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedMap);
    SST_SER(charMap);
    SST_SER(structMap);
  }

  void CaptCrunchObjMap::testSuiteInitMap() {
    unsignedMap[0] = 0x1234;
    unsignedMap[1] = 0x5678;

    charMap['A'] = 0xdead;
    charMap['B'] = 0xbeef;

    structMap[0] = fTypeStructValue;
    structMap[1] = fTypeStructValue;
  }

  void CaptCrunchObjMap::testSuiteMSet(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedMSet);
    SST_SER(charMSet);
    SST_SER(structMSet);
  }

  void CaptCrunchObjMap::testSuiteInitMSet() {
    unsignedMSet.insert(unsignedValue);
    unsignedMSet.insert(unsignedValue+1);

    charMSet.insert(cValue);
    charMSet.insert(cValue+1);

    structMSet.insert(fTypeStructValue);
    structMSet.insert(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteMMap(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedMMap);  //skk Causes error in object map
    SST_SER(charMMap);
    SST_SER(structMMap);
  }

  void CaptCrunchObjMap::testSuiteInitMMap() {
    unsignedMMap.insert({unsignedValue,unsignedValue+1});
    unsignedMMap.insert({unsignedValue+2,unsignedValue+3});

    charMMap.insert({cValue,unsignedValue});
    charMMap.insert({cValue+1,unsignedValue+1});

    structMMap.insert({unsignedValue,fTypeStructValue});
    structMMap.insert({unsignedValue+1,fTypeStructValue});
  }

  void CaptCrunchObjMap::testSuiteUnSet(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedUnSet);
    SST_SER(charUnSet);
    SST_SER(structUnSet);
  }
    
  void CaptCrunchObjMap::testSuiteInitUnSet() {
    unsignedUnSet.insert(unsignedValue);
    unsignedUnSet.insert(unsignedValue+1);

    charUnSet.insert(cValue);
    charUnSet.insert(cValue+1);

    structUnSet.insert(fTypeStructValue);
    structUnSet.insert(fTypeStructValue);
  }

  void CaptCrunchObjMap::testSuiteUnMap(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedUnMap);
    SST_SER(charUnMap);
    SST_SER(structUnMap);
  }

  void CaptCrunchObjMap::testSuiteInitUnMap() {
    unsignedUnMap.insert({unsignedValue,unsignedValue+1});
    unsignedUnMap.insert({unsignedValue+2,unsignedValue+3});

    charUnMap.insert({cValue,unsignedValue});
    charUnMap.insert({cValue+1,unsignedValue+1});

    structUnMap.insert({unsignedValue,fTypeStructValue});
    structUnMap.insert({unsignedValue+1,fTypeStructValue});
  }
    
  void CaptCrunchObjMap::testSuiteUnMSet(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedUnMSet);
    SST_SER(charUnMSet);
    SST_SER(structUnMSet);
  }

  void CaptCrunchObjMap::testSuiteInitUnMSet() {
    unsignedUnMSet.insert(unsignedValue);
    unsignedUnMSet.insert(unsignedValue+1);

    charUnMSet.insert(cValue);
    charUnMSet.insert(cValue+1);

    structUnMSet.insert(fTypeStructValue);
    structUnMSet.insert(fTypeStructValue);
  }
    
  void CaptCrunchObjMap::testSuiteUnMMap(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedUnMMap); //skk cause objemap error
    SST_SER(charUnMMap);
    SST_SER(structUnMMap);
  }

  void CaptCrunchObjMap::testSuiteInitUnMMap() {
    unsignedUnMMap.insert({unsignedValue,unsignedValue+1});
    unsignedUnMMap.insert({unsignedValue+2,unsignedValue+3});

    charUnMMap.insert({cValue,unsignedValue});
    charUnMMap.insert({cValue+1,unsignedValue+1});

    structUnMMap.insert({unsignedValue,fTypeStructValue});
    structUnMMap.insert({unsignedValue+1,fTypeStructValue});
  }

  void CaptCrunchObjMap::testSuiteVectVect(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedVectVect);
    SST_SER(unsignedListVect);
    SST_SER(unsignedArrayVect); // TODO: broken
    SST_SER(unsignedMapVect);
  }

  void CaptCrunchObjMap::testSuiteInitVectVect() {
    unsignedVectVect.push_back(unsignedVect);
    unsignedVectVect.push_back(unsignedVect);
    unsignedListVect.push_back(unsignedList);
    unsignedArrayVect.push_back(unsignedArray);
    unsignedArrayVect.push_back(unsignedArray);
    unsignedMapVect.push_back(unsignedMap);
    unsignedMapVect.push_back(unsignedMap);
  }

  void CaptCrunchObjMap::testSuiteListList(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedListList);
    SST_SER(unsignedVectList);
    SST_SER(unsignedArrayList); // TODO: broken
    SST_SER(unsignedMapList);
  }

  void CaptCrunchObjMap::testSuiteInitListList() {
    unsignedArrayList.push_back(unsignedArray);
    unsignedVectList.push_back(unsignedVect);
    unsignedVectList.push_front(unsignedVect);
    unsignedArrayList.push_back(unsignedArray);
    unsignedArrayList.push_front(unsignedArray);
    unsignedMapList.push_front(unsignedMap);
    unsignedMapList.push_back(unsignedMap);
    unsignedMapList.push_front(unsignedMap);
  }

  void CaptCrunchObjMap::testSuiteVectVectVect(SST::Core::Serialization::serializer& ser) {
    SST_SER(unsignedVectVectVect);
  }

  void CaptCrunchObjMap::testSuiteInitVectVectVect() {
    unsignedVectVectVect.push_back(unsignedVectVect);
    unsignedVectVectVect.push_back(unsignedVectVect);
  }

  void CaptCrunchObjMap::init( unsigned int phase ){
  }

  void CaptCrunchObjMap::serialize_order(SST::Core::Serialization::serializer& ser){
    SST::Component::serialize_order(ser);
    // -- core data structure serialization
    SST_SER(clockHandler);
    SST_SER(numStats);
    SST_SER(numClocks);
    // -- statistics serialization
    SST_SER(VStat);

    // use the code to 
    auto testSuiteItr = testSuiteLookUpTable.find(testSuiteParam);
    auto testSuiteEndItr = testSuiteLookUpTable.end();

    if(testSuiteEndItr == testSuiteItr) {
        std::cerr << "Lookup Table error" << std::endl;
        return;
    }
 
    testSuiteItr->second(*this, ser);
  }

  void CaptCrunchObjMap::initData(){

    auto testSuiteItr = testSuiteInitLookUpTable.find(testSuiteParam);
    auto testSuiteEndItr = testSuiteInitLookUpTable.end();

    if(testSuiteEndItr == testSuiteItr) {
        std::cerr << "Lookup Table error" << std::endl;
        return;
    }
 
    testSuiteItr->second(*this);
  }

  bool CaptCrunchObjMap::clockTick( SST::Cycle_t currentCycle ){
    if( (uint64_t)(currentCycle) >= numClocks ){
      primaryComponentOKToEndSim();
      return true;
    }
    printf("Current cycle %llu\n", currentCycle);
    return false;
  }
}

// EOF
