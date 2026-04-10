//
// _dbgsst15_cc_
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include "dbgsst15.h"

#include <chrono>
#include <sstream>
#include <thread>
#include <type_traits>

namespace SSTDEBUG::DbgSST15 {

//------------------------------------------
// DbgSST15
//------------------------------------------
DbgSST15::DbgSST15(SST::ComponentId_t id, const SST::Params& params) :
    SST::Component(id),
    clockHandler(nullptr),
    numPorts(1),
    minData(1),
    maxData(2),
    clockDelay(1),
    clocks(1000),
    curCycle(0),
    rCheck(0),
    size(0)
{

    const uint32_t Verbosity = params.find<uint32_t>("verbose", 0);
    output.init("DbgSST15[" + getName() + ":@p:@t]: ", Verbosity, 0, SST::Output::STDOUT);
    const std::string cpuClock = params.find<std::string>("clockFreq", "1GHz");
    clockHandler               = new SST::Clock::Handler2<DbgSST15, &DbgSST15::clockTick>(this);
    timeConverter              = registerClock(cpuClock, clockHandler);
    registerAsPrimaryComponent();
    primaryComponentDoNotEndSim();

    // read the rest of the parameters
    numPorts   = params.find<unsigned>("numPorts", 1);
    minData    = params.find<uint64_t>("minData", 1);
    maxData    = params.find<uint64_t>("maxData", 2);
    clockDelay = params.find<uint64_t>("clockDelay", 1);
    clocks     = params.find<uint64_t>("clocks", 1000);
    sleep      = params.find<uint64_t>("sleep", 0);
    traceMode  = params.find<unsigned>("traceMode", 0);
    selfCheck  = params.find<unsigned>("selfCheck", 0);
    cliType    = params.find<unsigned>("cliType", 0);

    output.verbose(CALL_INFO, 1, 0, "numPorts=%u\n", numPorts);
    output.verbose(CALL_INFO, 1, 0, "minData=%" PRIu64 "\n", minData);
    output.verbose(CALL_INFO, 1, 0, "maxData=%" PRIu64 "\n", maxData);
    output.verbose(CALL_INFO, 1, 0, "clockDelay=%" PRIu64 "\n", clockDelay);
    output.verbose(CALL_INFO, 1, 0, "clocks=%" PRIu64 "\n", clocks);
    output.verbose(CALL_INFO, 1, 0, "sleep=%" PRIu64 "\n", sleep);

    output.verbose(CALL_INFO, 1, 0, "traceMode=%" PRIu32 "\n", traceMode);
    if ( traceMode & 1 ) output.verbose(CALL_INFO, 1, 0, "tracing SEND events\n");
    if ( traceMode & 2 ) output.verbose(CALL_INFO, 1, 0, "tracing RECV events\n");
    if ( traceMode > 2 ) output.fatal(CALL_INFO, -1, "traceMode>2 not yet supported\n");

    // sanity check the params
    if ( maxData < minData ) {
        output.fatal(CALL_INFO, -1, "%s : maxData < minData\n", getName().c_str());
    }

    // setup the rng
    mersenne  = new SST::RNG::MersenneRNG(params.find<unsigned int>("rngSeed", 1223));
    mersenne2 = new SST::RNG::MersenneRNG(params.find<unsigned int>("rngSeed", 1224));

    // setup the links
    for ( unsigned i = 0; i < numPorts; i++ ) {
        linkHandlers.push_back(configureLink(
            "port" + std::to_string(i), new SST::Event::Handler2<DbgSST15, &DbgSST15::handleEvent>(this)));
    }
#if PROBE
    // Debug Probe Parameters
    int      probeMode       = params.find<int>("probeMode", 0);
    int      probeStartCycle = params.find<int>("probeStartCycle", 0);
    int      probeEndCycle   = params.find<int>("probeEndCycle", 0);
    int      probeBufferSize = params.find<int>("probeBufferSize", DEFAULT_PROBE_BUFFER_SIZE);
    int      probePort       = params.find<int>("probePort", 0);
    int      probePostDelay  = params.find<int>("probePostDelay", 0);
    uint64_t cliControl      = params.find<uint64_t>("cliControl", 0);
    // Create Probe
    probe_ = std::make_unique<DbgSST15_Probe>(this, &output, probeMode, probeStartCycle, probeEndCycle, probeBufferSize,
        probePort, probePostDelay, cliControl);
#endif
#if TESTSER
    test_uptr  = std::make_unique<int>(5);
    DP_uptr    = std::make_unique<DP>(7);
    PC_uptr    = std::make_unique<PC>(8);
    PCser_uptr = std::make_unique<PC>(9);
    DPser_uptr = std::make_unique<DP>(10);

    test_sptr  = std::make_shared<int>(15);
    DP_sptr    = std::make_shared<DP>(17);
    PC_sptr    = std::make_shared<PC>(18);
    PCser_sptr = std::make_shared<PC>(19);
    DPser_sptr = std::make_shared<DP>(20);

    test_DP   = new DP(21);
    test_myPB = new myPB<int>(22);
    test_myPB->set(122);
    test_smyPB = std::make_shared<myPB<int>>(23);
    test_smyPB->set(123);

    test_ProbeControl = new ProbeControl(this, &output, 1, 1, 1, 34, 1, 1, 1);
    test_ProbeBuffer  = new ProbeBuffer<int>(24);

    std::cout << "Runtime type test_myPB: " << typeid(test_myPB).name() << std::endl;
    std::cout << "Runtime type *test_myPB: " << typeid(*test_myPB).name() << std::endl;
    std::cout << "Runtime type test_ProbeBuffer: " << typeid(test_ProbeBuffer).name() << std::endl;
    std::cout << "Runtime type *test_ProbeBuffer: " << typeid(*test_ProbeBuffer).name() << std::endl;

#endif
    // constructor completeå
    output.verbose(CALL_INFO, 5, 0, "Constructor complete\n");
}

DbgSST15::~DbgSST15() {}

void
DbgSST15::setup()
{}

void
DbgSST15::finish()
{
    // See https://github.com/tactcomplabs/sst-core/issues/55
    if (selfCheck==0) return;

    bool success = checkValues();
    if (!success) {
        output.fatal(CALL_INFO, -1, "error: final consistency checks failed\n");
    } else {
        output.verbose(CALL_INFO,0,0,"final consistency check passed\n");
    }
}

void
DbgSST15::init(unsigned int phase)
{
    for ( size_t i = 0; i < v_bitset42.size(); i++ ) {
        v_bitset42[i] = (i & 3) == 3; // 1000 1000 1000 ... 1000 lsb
    }

    for ( unsigned i =0; i<3; i++) {
        v_stack_unsigned.push((i+1)*10);
        v_queue_unsigned.push((i+1)*100);
        v_priority_queue_unsigned.push((3-i));
    }

    v_ag_class = { 42, "ag_class_t" };
    v_ag_struct = { 42, "ag_struct_t" };
    v_ag_union = { 42 };
    v_ag_union_struct = { 0xa5a5a5a5 };
}

void
DbgSST15::printStatus(SST::Output& out)
{}

void
DbgSST15::serialize_order(SST::Core::Serialization::serializer& ser)
{
    SST::Component::serialize_order(ser);
    SST_SER(output);
    SST_SER(timeConverter);
    SST_SER(clockHandler);
    SST_SER(numPorts);
    SST_SER(minData);
    SST_SER(maxData);
    SST_SER(clockDelay);
    SST_SER(clocks);
    SST_SER(curCycle);
    SST_SER(sleep);

    SST_SER(traceMode);
    SST_SER(selfCheck);
    SST_SER(cliType);
    SST_SER(rCheck);
    SST_SER(size);

    SST_SER(v_bool);
    SST_SER(v_char);
    SST_SER(v_schar);
    SST_SER(v_short);
    SST_SER(v_ushort);
    SST_SER(v_int);
    SST_SER(v_uint);
    SST_SER(v_long);
    SST_SER(v_ulong);
    SST_SER(v_ll);
    SST_SER(v_ull);
    SST_SER(v_float);
    SST_SER(v_double);
    SST_SER(v_ldouble);
    // tickled variables
    SST_SER(v_bitset42);
    SST_SER(v_vecbool);
    SST_SER(v_pair_u64_str);
    SST_SER(v_tuple_u32_dbl_str);
    SST_SER(v_stack_unsigned);
    SST_SER(v_queue_unsigned);
    SST_SER(v_priority_queue_unsigned);
    SST_SER(v_ag_class);
    SST_SER(v_ag_struct);
    SST_SER(v_ag_union);
    SST_SER(v_ag_union_struct);
    SST_SER(tickle_counter);

    // Misc Objects
    SST_SER(mersenne);
    SST_SER(mersenne2);
    SST_SER(linkHandlers);

    // SST_SER(*probe_);


#if TESTSER
    SST_SER(*test_uptr);
    SST_SER(PC_uptr->start);
    SST_SER(DP_uptr->start);
    SST_SER(*PCser_uptr);
    SST_SER(*DPser_uptr);

    SST_SER(*test_sptr);
    SST_SER(PC_sptr->start);
    SST_SER(DP_sptr->start);
    SST_SER(*PCser_sptr);
    SST_SER(*DPser_sptr);

    SST_SER(*test_DP);

    SST_SER(*test_myPB);
    SST_SER(*test_smyPB);
    SST_SER(*test_ProbeBuffer); // SKK ERROR caused here
#endif

#if 0
  if ( (cliType==0) && (ser.mode() == SST::Core::Serialization::serializer::PACK) ) {
    handle_chkpt_probe_action();
  }
#endif
}

#if 0
void DbgSST15::handle_chkpt_probe_action()
{
  auto c = getCurrentSimCycle();
  printf("handle chkpt probe action @ cycle %ld\n", c);

  probe_->updateSyncState(c); 
  probe_->updateProbeState(c); // ensure states update before next sim clock
}
#endif

void
DbgSST15::handleEvent(SST::Event* ev)
{
    DbgSST15Event* cev = static_cast<DbgSST15Event*>(ev);
    output.verbose(CALL_INFO, 5, 0, "%s: received %zu unsigned values\n", getName().c_str(), cev->getData().size());
#if 0
  /// debug probe 
  if ((traceMode & 2) == 2) {
      uint64_t range = maxData - minData + 1;
      size_t r = cev->getData().size();
      if (probe_->triggering()) {
        probe_->trigger(r > (range-1));
      }
      if (probe_->sampling())
        probe_->capture_event_atts(getCurrentSimCycle(), r, cev);
  }
#else
    // Used to trigger watchpoint for rCheck > 0
    uint64_t range = maxData - minData + 1;
    size_t   r     = cev->getData().size();
    rCheck         = (int64_t)r - (int64_t)(range - 1);
    size           = r;
    output.verbose(CALL_INFO, 2, 0, "size = %ld\n", size); // skk debug

#endif
    delete ev;
}

void
DbgSST15::sendData()
{
    for ( unsigned i = 0; i < numPorts; i++ ) {
        // generate a new payload
        std::vector<unsigned> data;
        uint64_t              range = maxData - minData + 1;
        // so as to not conflict with checking use different rng here
        uint64_t              r     = mersenne2->generateNextUInt32() % range + minData;
#if 0
    /// debug probe trigger (advance to post-trigger state)
    bool trace = (traceMode & 1) == 1;
    if (trace && probe_->triggering()) probe_->trigger(r > (range-1));
    ///
#else
        // Used to trigger watchpoint for rCheck > 0
        rCheck = (int64_t)r - (int64_t)(range - 1);
        size   = r;
#endif
        for ( size_t i = 0; i < (unsigned)r; i++ ) {
            data.push_back((unsigned)(mersenne->generateNextUInt32()));
        }
        output.verbose(
            CALL_INFO, 5, 0, "%s: sending %zu unsigned values on link %d\n", getName().c_str(), data.size(), i);
        output.verbose(CALL_INFO, 2, 0, "data.size = %ld\n",
            data.size()); // skk debug
        DbgSST15Event* ev = new DbgSST15Event(data);
        linkHandlers[i]->send(ev);
#if 0
    /// debug probe data capture
    if (trace && probe_->sampling()) 
      probe_->capture_event_atts(getCurrentSimCycle(), r, ev);
    ///
#endif
    }
}

void
DbgSST15::tickleBits()
{
    tickle_counter++;
    if ( tickle_counter % 2 == 0 ) v_bitset42.flip();
    if ( tickle_counter % 3 == 0 ) v_vecbool.flip();
    std::stringstream s;
    s << "S" << tickle_counter;
    if ( tickle_counter % 5 == 0 ) {
        // output.verbose(CALL_INFO, 0, 0, "%s.v_pair_u64_str.first <- %zu\n", getName().c_str(), tickle_counter);
        v_pair_u64_str = { tickle_counter, s.str() };
    }
    if ( tickle_counter % 7 == 0 ) v_tuple_u32_dbl_str = { tickle_counter, 1.0 / (double)tickle_counter, s.str() };
    if ( tickle_counter % 11 == 0 ) {
        // replace the top element
        unsigned top = v_stack_unsigned.top() + 1;
        v_stack_unsigned.pop();
        v_stack_unsigned.push(top);
        //TODO watch point on size change
    }
    if (tickle_counter % 13 == 0 ) {
        // perturb one element but keep the size the same
        unsigned front = v_queue_unsigned.front() + 1;
        v_queue_unsigned.pop();
        v_queue_unsigned.push(front);
        #if 0
        if (this->getName()=="cp0") {
            output.verbose(CALL_INFO, 0, 0, "v_queue_unsigned.front()=%d\n", v_queue_unsigned.front());
        }
        #endif
    }
    if (tickle_counter % 17 == 0 ) {
        // replace the front element
        unsigned front = v_priority_queue_unsigned.top() + 1;
        v_priority_queue_unsigned.pop();
        v_priority_queue_unsigned.push(front);
    }

    if (tickle_counter % 19 == 0 ) {
        v_ag_class.v_int += 1;
        v_ag_class.v_string = std::to_string(tickle_counter);
    }

    if (tickle_counter % 23 == 0 ) {
        v_ag_struct.v_int += 1;
        v_ag_struct.v_string = std::to_string(tickle_counter);
    }

    if (tickle_counter % 29 == 0 ) {
        v_ag_union.n += 0x01010100;
    }

    if (tickle_counter % 31 == 0 ) {
        v_ag_union.s[0]++;
    }

    if (tickle_counter % 37 == 0 ) {
        v_ag_union.s[1]++;
    }

    if (tickle_counter % 41 == 0 ) {
        v_ag_union.c++;
    }

    if (tickle_counter % 43 == 0 ) {
        v_ag_union_struct.v += 0x100;
    }

    if (tickle_counter % 47 == 0 ) {
        // TODO code to avoid
        // conversion from 'uint32_t' {aka 'unsigned int'} to
	// 'unsigned char:4' may change value [-Werror=conversion]
        #pragma GCC diagnostic push
        #pragma GCC diagnostic ignored "-Wconversion"
        v_ag_union_struct.f.b30_27 += uint32_t{1};
	#pragma GCC diagnostic pop
    }
}

bool DbgSST15::checkValues() {
    bool OK = true;
    // output.verbose(CALL_INFO, 0,0, "tickle_counter=%zu\n", tickle_counter);

    std::bitset<42> v_bitset42_expected;
    int u_predicted = tickle_counter % 2 ? 1 : 0;
    for ( size_t i = 0; i < v_bitset42.size(); i++ )
        v_bitset42_expected[i] = (i&3)==3 ? u_predicted : 1-u_predicted;
    if (v_bitset42 != v_bitset42_expected) {
        output.verbose(CALL_INFO, 0, 0, 
            "error: mismatch on v_bitset42. Expected 0x%" PRIx64 ", Actual 0x%" PRIx64 "\n",
	    (uint64_t) v_bitset42_expected.to_ulong(), (uint64_t) v_bitset42.to_ulong());
        OK = false;
    }

    std::stack<unsigned> v_stack_unsigned_expected;
    std::queue<unsigned> v_queue_unsigned_expected;
    std::priority_queue<unsigned> v_priority_queue_unsigned_expected;
    for ( unsigned i=0; i<3; i++) {
        v_stack_unsigned_expected.push((i+1)*10);
        v_queue_unsigned_expected.push((i+1)*100);
        v_priority_queue_unsigned_expected.push((3-i));
    }
    for (size_t retickle=0; retickle<=tickle_counter - 17; retickle++) {
        if ( retickle % 11 == 0 ) {
            unsigned top = v_stack_unsigned_expected.top() + 1;
            v_stack_unsigned_expected.pop();
            v_stack_unsigned_expected.push(top);
        }
        if (retickle % 13 == 0 ) {
            unsigned front = v_queue_unsigned_expected.front() + 1;
            v_queue_unsigned_expected.pop();
            v_queue_unsigned_expected.push(front);
        }
        if (retickle % 17 == 0 ) {
            unsigned front = v_priority_queue_unsigned_expected.top() + 1;
            v_priority_queue_unsigned_expected.pop();
            v_priority_queue_unsigned_expected.push(front);
        }
    }
    for ( size_t i=0; i<3; i++) {
        // Check v_stack_unsigned
        unsigned top_expected = v_stack_unsigned_expected.top();
        unsigned top = v_stack_unsigned.top();
        v_stack_unsigned_expected.pop();
        v_stack_unsigned.pop();
        if (top_expected != top) {
            output.verbose(CALL_INFO, 0, 0, 
                "error: mismatch on v_stack_unsigned i=%zu. Expected 0x%" PRIu32 ", Actual 0x%" PRIu32 "\n",
                i, top_expected, top);
            OK = false;
        }
        // Check v_queue_unsigned_expected
        unsigned front_expected = v_queue_unsigned_expected.front();
        unsigned front = v_queue_unsigned.front();
        v_queue_unsigned_expected.pop();
        v_queue_unsigned.pop();
        if (front_expected != front) {
            output.verbose(CALL_INFO, 0, 0, 
                "error: mismatch on v_queue_unsigned u=%zu. Expected 0x%" PRIu32 ", Actual 0x%" PRIu32 "\n",
                i, front_expected, front);
            OK = false;
        }
        // Check v_priority_queue_unsigned
        top_expected = v_priority_queue_unsigned_expected.top();
        top = v_priority_queue_unsigned.top();
        v_priority_queue_unsigned_expected.pop();
        v_priority_queue_unsigned.pop();
        if (top_expected != top) {
            output.verbose(CALL_INFO, 0, 0, 
                "error: mismatch on v_priority_queue_unsigned i=%zu. Expected 0x%" PRIu32 ", Actual 0x%" PRIu32 "\n",
                i, top_expected, top);
            OK = false;
        }

    }

    //TODO add checks for rest of the tickled members

    return OK;
}

bool
DbgSST15::clockTick(SST::Cycle_t currentCycle)
{

    if ( currentCycle == 1 && sleep > 0 ) {
        output.verbose(CALL_INFO, 0, 0, "Sleeping for %" PRIu64 " seconds\n", sleep);
        std::this_thread::sleep_for(std::chrono::seconds(sleep));
        output.verbose(CALL_INFO, 0, 0, "I'm awake I'm awake ...\n");
    }

    // check to see whether we need to send data over the links
    curCycle++;
    if ( curCycle >= clockDelay ) {
        sendData();
        curCycle = 0;
        tickleBits();
    }

    // check to see if we've reached the completion state
    bool rc = false;
    if ( (uint64_t)(currentCycle) >= clocks ) {
        // For checking convenience, make sure we land on a multiple of the next largest 
        // prime number used in the tickling routines.
        if ( tickle_counter % NEXT_PRIME != 0 )
            return false;

        output.verbose(CALL_INFO, 1, 0, "%s ready to end simulation\n", getName().c_str());
        primaryComponentOKToEndSim();
        rc = true;
    }
#if 0
  /// Debug Probe sequencing
  if (probe_->active()) probe_->updateProbeState(currentCycle);
  ///
#endif

    return rc;
}

//------------------------------------------
// DbgSST15_Probe
//------------------------------------------

#if PROBE
DbgSST15_Probe::DbgSST15_Probe(SST::Component* comp, SST::Output* out, int mode, SST::SimTime_t startCycle,
    SST::SimTime_t endCycle, int bufferSize, int port, int postDelay, uint64_t cliControl) :
    ProbeControl(comp, out, mode, startCycle, endCycle, bufferSize, port, postDelay, cliControl)
{
    probeBuffer = std::make_shared<ProbeBuffer<event_atts_t>>(bufferSize);
    setBufferControls(probeBuffer);
}

void
DbgSST15_Probe::capture_event_atts(uint64_t cycle, uint64_t sz, DbgSST15Event* ev)
{
    if ( !sampling() ) return;
    // copy the sample into the circular buffer
    event_atts_t e(cycle, sz, ev);
    probeBuffer->capture(e);
    // Finally call base class to update counters
    ProbeControl::sample();
}

void
DbgSST15_Probe::serialize_order(SST::Core::Serialization::serializer& ser)
{
    ProbeControl::serialize_order(ser);
    SST_SER(*probeBuffer);
}

#endif

} // namespace SSTDEBUG::DbgSST15

// EOF
