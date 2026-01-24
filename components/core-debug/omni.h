//
// omni.h
// Object Map Noir Inspector
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

// Intent: Minimalist low level object map testing. 
// Subcomponents are used to differentiate behaviors
// so we can focus on a single type or provide more
// complex behaviors by simply providing the subcomponent
// at runtime.

#ifndef _SST_EXT_TESTS_OMNI_
#define _SST_EXT_TESTS_OMNI_

// -- Standard Headers
#include "SST.h"

namespace SST::ExtTest {

//TODO utilize events. placeholder for now

// ---------------------------------------------
// payload_t
// ---------------------------------------------
struct payload_t {
  uint64_t data = 0;
}; //struct payload_t

// ---------------------------------------------
// OMEvent
// ---------------------------------------------
class OMEvent : public SST::Event {
public:
  OMEvent(const payload_t& p) : SST::Event(), payload_(p) {}
  virtual ~OMEvent() {}
  const payload_t& payload(){ return payload_; }
private:
  payload_t payload_;
public:
  // Serialization
  OMEvent() : Event() {}
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    SST::Event::serialize_order(ser);
    // SST_SER(payload_); //TODO can I see in-flight events in debugger?
  }
  ImplementSerializable(SST::ExtTest::OMEvent);
}; // class OMEvent

// -------------------------------------------------------
// OMSubComponentAPI (not registered)
// -------------------------------------------------------
class OMSubComponentAPI : public SST::SubComponent {
public:
  SST_ELI_REGISTER_SUBCOMPONENT_API(SST::ExtTest::OMSubComponentAPI);
  SST_ELI_DOCUMENT_PARAMS(
    {"verbose", "Sets the verbosity level of output",   "0" }
  )
  OMSubComponentAPI(ComponentId_t id, Params& params) : SubComponent(id) {};
  virtual ~OMSubComponentAPI() {}
  
  virtual void update(payload_t& p) {
    subcompapi_counter_++;
    p.data += 1;
  };
private:
  uint64_t subcompapi_counter_ = 0;

public:
  // minimum serialization for testing object map
  OMSubComponentAPI() : SubComponent() {}
  void serialize_order(SST::Core::Serialization::serializer& ser) override {
    SubComponent::serialize_order(ser);
    SST_SER(subcompapi_counter_);
  }
  ImplementVirtualSerializable(SST::ExtTest::OMSubComponentAPI)
}; //class OMSubComponentAPI

// ---------------------------------------------
// OMSimpleComponent
// ---------------------------------------------
class OMSimpleComponent : public SST::Component{

public:
  SST_ELI_REGISTER_COMPONENT( OMSimpleComponent,   // component class
             "dbgsst15",       // component library
                            "OMSimpleComponent",   // component name
                            SST_ELI_ELEMENT_VERSION( 1, 0, 0 ),
                            "Simple Object Map Evalulation Component",
                            COMPONENT_CATEGORY_UNCATEGORIZED )
  SST_ELI_DOCUMENT_PARAMS(
    {"verbose", "Sets the verbosity level of output",   "1" },
    {"primary", "Sets component as primary controller", "0" },
  )
  SST_ELI_DOCUMENT_PORTS(
    { "port0",  "generic port 0",   {"omap.OMEvent"} },
  )
  SST_ELI_DOCUMENT_SUBCOMPONENT_SLOTS(
    { "function0", 
      "generic function 0",
      "SST::ExtTest::OMSubComponentAPI" },
  )

  explicit OMSimpleComponent(ComponentId_t id, const SST::Params& params);
  ~OMSimpleComponent() {}

  // Component Lifecycle
  void init( unsigned int phase ) override {};     // post-construction, polled events
  void setup() override {};                        // pre-simulation, called once per component
  void complete( unsigned int phase ) override {}; // post-simulation, polled events
  void finish() override {};                       // pre-destruction, called once per component
  void emergencyShutdown() override {};            // SIGINT, SIGTERM
  void printStatus(Output& out) override {};       // SIGUSR2

  // Clocking
  bool clockTick( SST::Cycle_t currentCycle );  // return true if clock should be disabled

private:
  // Subcomponent pointers
  OMSubComponentAPI* p_omsimplecomp_function0_ = nullptr;

  // SST Handlers
  SST::Output sstout_;
  SST::TimeConverter* timeConverter_;
  SST::Clock::HandlerBase* clockHandler_;

  // Links
  SST::Link* port0link_;

  // Link handlers
  void port0rcv(SST::Event *ev);
  
  // Internals
  bool primary = false;
  payload_t payload_port0;

public:
  // -------------------------------------------------------
  // Serialization support
  // -------------------------------------------------------
  // Default constructor required for serialization
  OMSimpleComponent() : SST::Component() {}
  // Serialization function 
  void serialize_order(SST::Core::Serialization::serializer& ser) override;
  // Serialization implementation
  ImplementSerializable(SST::ExtTest::OMSimpleComponent)

}; //class OMSimpleComponent

// -------------------------------------------------------
// OmSubComponentAPI Specialization Example
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
 
  OMQueue(ComponentId_t id, Params& params) : OMSubComponentAPI(id,params) {
    sstout_.init(getName() + ":@p:@t]: ", 0, 0, SST::Output::STDOUT );
    v_queue_unsigned_.push(100);
    v_queue_unsigned_.push(200);
    v_queue_unsigned_.push(300);
  }
  ~OMQueue() {}
  virtual void update(payload_t& p) final {
    OMSubComponentAPI::update(p);
    assert(v_queue_unsigned_.size()==3);
    unsigned front = v_queue_unsigned_.front() + 1;
    v_queue_unsigned_.pop();
    v_queue_unsigned_.push(front);
    sstout_.verbose(CALL_INFO, 0, 0, "v_queue_unsigned_.front()=%d\n", v_queue_unsigned_.front());
  }
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

#endif  // _SST_EXT_TESTS_OMNI_

// EOF
