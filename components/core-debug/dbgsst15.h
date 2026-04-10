//
// _dbgsst15_h_
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#ifndef _SST_EXT_TESTS_DBGSST15_H_
#define _SST_EXT_TESTS_DBGSST15_H_

// -- Standard Headers
#include <bitset>
#include <cstddef>
#include <cstdint>
#include <inttypes.h>
#include <memory>
#include <ostream>
#include <queue>
#include <random>
#include <stack>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <time.h>
#include <tuple>
#include <type_traits>
#include <utility>
#include <vector>

// -- SST Headers
#include "SST.h"

// -- Debug Probe
#include "probe.h"

#define PROBE   1
#define SOCKET  0
#define TESTSER 0

// See tickleBits(). Do not user prime >= NEXT_PRIME
#define NEXT_PRIME 53

#if PROBE
using namespace SSTDEBUG::Probe;
#endif
namespace SSTDEBUG::DbgSST15 {
#if PROBE
class DbgSST15_Probe;
#endif

#if TESTSER // Testing out serialization of unique and shared
class PC
{ // represent ProbeControl
public:
    PC(int s) :
        start(s)
    {}
    // virtual ~PC();
    int start;

    // Support for  serialization
    void serialize_order(SST::Core::Serialization::serializer& ser) { /* override */ SST_SER(start); }
}; // class PC

class DP final : public PC
{ // Represent DebugSST15_Probe
public:
    DP(int s) :
        PC(s)
    {}

    void serialize_order(SST::Core::Serialization::serializer& ser) { /* override */ PC::serialize_order(ser); }
}; // class DP

class myPBC
{ // represent probe buffer control
public:
    myPBC(int s) :
        size(s)
    {}
    int size;

    void serialize_order(SST::Core::Serialization::serializer& ser) { /* override */ SST_SER(size); }

}; // class PBC

template <typename T>
class myPB final : public myPBC
{
public:
    myPB(int s) :
        myPBC(s)
    {}
    void set(T v) { val = v; }
    void serialize_order(SST::Core::Serialization::serializer& ser) { /* override */ SST_SER(val); }

private:
    T              val;
    std::vector<T> mybuf;
}; // class PB

#endif

// -------------------------------------------------------
// DbgSST15Event
// -------------------------------------------------------
class DbgSST15Event : public SST::Event
{
public:
    /// DbgSST15Event : standard constructor
    DbgSST15Event() :
        SST::Event()
    {}

    /// DbgSST15Event: constructor
    DbgSST15Event(std::vector<unsigned> d) :
        SST::Event(),
        data(d)
    {}

    /// DbgSST15Event: destructor
    ~DbgSST15Event() {}

    /// DbgSST15Event: retrieve the data
    std::vector<unsigned> const getData() { return data; }

private:
    std::vector<unsigned> data; ///< DbgSST15Event: data payload

    /// DbgSST15Event: serialization method
    void serialize_order(SST::Core::Serialization::serializer& ser) override
    {
        Event::serialize_order(ser);
        SST_SER(data);
    }

    /// DbgSST15Event: serialization implementor
    ImplementSerializable(SSTDEBUG::DbgSST15::DbgSST15Event);

}; // class DbgSST15Event

// Aggregate types
// class, struct, or union
// No user-declared or inherited constructors.
// No private or protected non-static data members.
// No virtual functions (e.g., no polymorphism).
// No private, protected, or virtual base classes.
// Arrays are always considered aggregates, even if they contain non-aggregate elements

class ag_class_t {
public:
    int v_int;
    std::string v_string;
};
static_assert(std::is_aggregate_v<ag_class_t>);

struct ag_struct_t {
    int v_int;
    std::string v_string;
};
static_assert(std::is_aggregate_v<ag_struct_t>);

// These unions are trivially serializable and will not be automatically mapped.
// https://github.com/sstsimulator/sst-core/pull/1515
union ag_union_t {
    std::int32_t n;     // occupies 4 bytes
    std::uint16_t s[2]; // occupies 4 bytes
    std::uint8_t c;     // occupies 1 byte
}; 
static_assert(std::is_aggregate_v<ag_union_t>);

union ag_union_struct_t {
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
static_assert(std::is_aggregate_v<ag_union_struct_t>);

// -------------------------------------------------------
// DbgSST15
// -------------------------------------------------------
class DbgSST15 : public SST::Component
{
public:
    /// DbgSST15: top-level SST component constructor
    DbgSST15(SST::ComponentId_t id, const SST::Params& params);

    /// DbgSST15: top-level SST component destructor
    ~DbgSST15();

    /// DbgSST15: standard SST component 'setup' function
    void setup() override;

    /// DbgSST15: standard SST component 'finish' function
    void finish() override;

    /// DbgSST15: standard SST component init function
    void init(unsigned int phase) override;

    /// DbgSST15: standard SST component printStatus
    void printStatus(SST::Output& out) override;

    /// DbgSST15: standard SST component clock function
    bool clockTick(SST::Cycle_t currentCycle);

    const int DEFAULT_PROBE_BUFFER_SIZE = 1024;

    // -------------------------------------------------------
    // DbgSST15 Component Registration Data
    // -------------------------------------------------------
    /// DbgSST15: Register the component with the SST core
    SST_ELI_REGISTER_COMPONENT(DbgSST15,   // component class
                             "dbgsst15", // component library
                             "DbgSST15", // component name
                             SST_ELI_ELEMENT_VERSION(1, 0, 0),
                             "CHKPNT SST COMPONENT",
                             COMPONENT_CATEGORY_UNCATEGORIZED)

    SST_ELI_DOCUMENT_PARAMS(
      {"verbose", "Sets the verbosity level of output", "0"},
      {"numPorts", "Number of external ports", "1"},
      {"minData", "Minimum number of unsigned values", "1"},
      {"maxData", "Maximum number of unsigned values", "2"},
      {"clockDelay", "Clock delay between sends", "1"},
      {"clocks", "Clock cycles to execute", "1000"},
      {"rngSeed", "Mersenne RNG Seed", "1223"},
      {"clockFreq", "Clock frequency", "1GHz"},
      // Lazy synchronization help for bash signaling
      {"sleep", "Time (s) for comp0 to sleep on 1st clock", "0"},
      // component specific probe controls
      {"traceMode", "0-none, 1-send, 2-recv", "0"},
      {"selfCheck", "Set to 1 to enable self-checking at end of simulation", "0"},
    // TODO Should get rest into base class. Component extends Probe instead of
    // instantiating it
#if PROBE
      {"probeMode", "0-Disabled,1-Checkpoint based, >1-rsv", "0"},
      {"probeStartCycle", "Use with checkpoint-sim-period", "0"},
      {"probeEndCycle", "Cycle probing disable. 0 is no limit", "0"},
      {"probeBufferSize", "Records in circular trace buffer",
       "1024"}, // DEFAULT_PROBE_BUFFER_SIZE
      {"probePostDelay",
       "post-trigger delay cycles. -1 to sample until checkpoint", "0"},
      {"probePort", "Socket assignment for debug port", "0"},
      {"cliControl",
       "0x40 every chkpt, 0x20 chkpts when probe active, 0x10 sync state "
       "change,\n"
       "0x04 every probe sample, 0x02 probe samples from trigger onward, 0x01 "
       "probe state change",
       "0"},
#endif
  )

    // -------------------------------------------------------
    // DbgSST15 Component Port Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_PORTS({"port%(num_ports)d",
                          "Ports which connect to endpoints.",
                          {"dbgcli.DbgSST15Event", ""}})

    // -------------------------------------------------------
    // DbgSST15 SubComponent Parameter Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_SUBCOMPONENT_SLOTS()

    // -------------------------------------------------------
    // DbgSST15 Component Statistics Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_STATISTICS()

    // -------------------------------------------------------
    // DbgSST15 Component Checkpoint Methods
    // -------------------------------------------------------
    /// DbgSST15: serialization constructor
    DbgSST15() :
        SST::Component()
    {}

    /// DbgSST15: serialization
    void serialize_order(SST::Core::Serialization::serializer& ser) override;
#if 1
    /// DbgSST15: Update debug control state object on checkpoint
    void handle_chkpt_probe_action();
#endif
    /// DbgSST15: serialization implementations
    ImplementSerializable(SSTDEBUG::DbgSST15::DbgSST15)

private:
    // -- internal handlers
    SST::Output              output;        ///< SST output handler
    SST::TimeConverter       timeConverter; ///< SST time conversion handler
    SST::Clock::HandlerBase* clockHandler;  ///< Clock Handler

    // -- parameters
    unsigned           numPorts;   ///< number of ports to configure
    uint64_t           minData;    ///< minimum number of data elements
    uint64_t           maxData;    ///< maxmium number of data elements
    uint64_t           clockDelay; ///< clock delay between sends
    uint64_t           clocks;     ///< number of clocks to execute
    uint64_t           curCycle;   ///< current cycle delay
    uint64_t           sleep = 0;  ///< sleep time (s) for 1st clock
    // -- probing
    unsigned           traceMode; ///< 0-none, 1-send, 2-recv, 3-both
    unsigned           selfCheck; ///< 0-disabled, 1-enabled
    unsigned           cliType;   ///< 0-serializer-entry, 1-initiateInteractive
    int64_t            rCheck;    /// < skk used for watchpoint trigger of msg size
    size_t             size;      ///< skk used for watchpoint trigger of msg size > 100
    // -- testing interactive console
    bool               v_bool    = true;
    char               v_char    = 1;
    signed char        v_schar   = -1;
    short              v_short   = -2;
    unsigned short     v_ushort  = 2;
    int                v_int     = -3;
    unsigned           v_uint    = 3;
    long               v_long    = -4;
    unsigned           v_ulong   = 4;
    long long          v_ll      = -5;
    unsigned long long v_ull     = 5;
    float              v_float   = 1.0;
    double             v_double  = 2.0;
    long double        v_ldouble = 3.0L;

    // bitset and vector<bool> (sst-simulator/sst-core PR#1483)
    std::bitset<42>                           v_bitset42; // default 0
    std::vector<bool>                         v_vecbool      = { true, false, true, true, false, false, true, true };
    // pair and tuple (sst-simulator/sst-core PR#1487)
    std::pair<uint64_t, std::string>          v_pair_u64_str = { 42, "forty-two" };
    std::tuple<uint32_t, double, std::string> v_tuple_u32_dbl_str = { 8, 1.0 / 8.0, "eight" };

    // std::stack, std::queue, std::priority_queue (sst-simulator/sst-core PR#1488)
    std::stack<unsigned> v_stack_unsigned;
    std::queue<unsigned> v_queue_unsigned;
    std::priority_queue<unsigned> v_priority_queue_unsigned;

    // aggregate types
    ag_class_t v_ag_class;
    ag_struct_t v_ag_struct;
    ag_union_t v_ag_union;
    ag_union_struct_t v_ag_union_struct;
    size_t tickle_counter = 0; // used for changing values it tickleBits()

#if PROBE
    // -- Component probe state object
    std::unique_ptr<DbgSST15_Probe> probe_;
#endif
#if TESTSER
    // SKK Test serializing unique pointer
    std::unique_ptr<int> test_uptr;
    std::unique_ptr<DP>  DP_uptr;
    std::unique_ptr<PC>  PC_uptr;
    std::unique_ptr<PC>  PCser_uptr;
    std::unique_ptr<DP>  DPser_uptr;

    std::shared_ptr<int> test_sptr;
    std::shared_ptr<DP>  DP_sptr;
    std::shared_ptr<PC>  PC_sptr;
    std::shared_ptr<PC>  PCser_sptr;
    std::shared_ptr<DP>  DPser_sptr;

    DP*                        test_DP;
    myPB<int>*                 test_myPB;
    std::shared_ptr<myPB<int>> test_smyPB;

    ProbeControl*     test_ProbeControl;
    // ProbeBufCtl* test_ProbeBufCtl;
    ProbeBuffer<int>* test_ProbeBuffer;
// DbgSST15_Probe test_probe;
#endif
    // -- rng objects
    SST::RNG::Random* mersenne; ///< mersenne twister object
    SST::RNG::Random* mersenne2;

    std::vector<SST::Link*> linkHandlers; ///< LinkHandler objects

    // -- private methods
    /// event handler
    void handleEvent(SST::Event* ev);

    /// sends data to adjacent links
    void sendData();

    /// watchpoint facilitation
    void tickleBits();
    bool checkValues();

}; // class DbgSST15
#if PROBE
// -------------------------------------------------------
// Debug Control State
// -------------------------------------------------------
class DbgSST15_Probe final : public ProbeControl
{

public:
    DbgSST15_Probe(SST::Component* comp, SST::Output* out, int mode, SST::SimTime_t startCycle, SST::SimTime_t endCycle,
        int bufferSize, int port, int postDelay, uint64_t cliControl);
    // User custom sampling functions
    void capture_event_atts(uint64_t cycle, uint64_t sz, DbgSST15Event* ev);
    // Custom data type for samples
    struct event_atts_t
    {
        uint64_t cycle_        = 0;
        uint64_t sz_           = 0;
        uint64_t deliveryTime_ = 0;
        int      priority_     = 0;
        uint64_t orderTag_     = 0;
        uint64_t queueOrder_   = 0;
        event_atts_t() {};
        event_atts_t(uint64_t c, uint64_t sz, DbgSST15Event* ev) :
            cycle_(c),
            sz_(sz)
        {
            deliveryTime_ = ev->getDeliveryTime();
            priority_     = ev->getPriority();
            orderTag_     = ev->getOrderTag();
            queueOrder_   = ev->getQueueOrder();
        };
        friend std::ostream& operator<<(std::ostream& os, const event_atts_t& e)
        {
            os << std::dec << "cycle=" << e.cycle_ << " sz=" << e.sz_ << " deliveryTime=" << e.deliveryTime_
               << " priority=" << e.priority_ << " orderTag=" << e.orderTag_ << " queueOrder=" << e.queueOrder_;
            return os;
        }
        // Serialize function to support object map access to buffer
        void serialize_order(SST::Core::Serialization::serializer& ser)
        {
            SST_SER(cycle_);
            SST_SER(sz_);
            SST_SER(deliveryTime_);
            SST_SER(priority_);
            SST_SER(orderTag_);
            SST_SER(queueOrder_);
        }
    }; // strcut event_atts_t

    // trace buffer
    std::shared_ptr<ProbeBuffer<event_atts_t>> probeBuffer;
    // -------------------------------------------------------
    // DbgSST15_Probe Component Serialization Method
    // -------------------------------------------------------
    void                                       serialize_order(SST::Core::Serialization::serializer& ser);

}; // class DbgSST15_Probe
#endif // PROBE
} // namespace SSTDEBUG::DbgSST15

#endif // _SST_EXT_TESTS_DBGSST15_H_

// EOF
