//
// _dbgmin_h_
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#ifndef _SST_EXT_TESTS_DBGMIN_H_
#define _SST_EXT_TESTS_DBGMIN_H_

// -- Standard Headers

// -- SST Headers
#include "SST.h"

namespace SSTDEBUG::DbgMin {

// -------------------------------------------------------
// DbgMin
// -------------------------------------------------------
class DbgMin : public SST::Component
{
public:
    /// DbgMin: top-level SST component constructor
    DbgMin(SST::ComponentId_t id, const SST::Params& params);

    /// DbgMin: top-level SST component destructor
    ~DbgMin() {};

    /// DbgMin: standard SST component clock function
    bool clockTick(SST::Cycle_t currentCycle);

    // -------------------------------------------------------
    // DbgMin Component Registration Data
    // -------------------------------------------------------
    SST_ELI_REGISTER_COMPONENT(DbgMin,   // component class
                             "dbgsst15",   // component library
                             "DbgMin",   // component name
                             SST_ELI_ELEMENT_VERSION(1, 0, 0),
                             "CHKPNT SST COMPONENT",
                             COMPONENT_CATEGORY_UNCATEGORIZED)

    SST_ELI_DOCUMENT_PARAMS()

    // -------------------------------------------------------
    // DbgMin Component Port Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_PORTS()

    // -------------------------------------------------------
    // DbgMin SubComponent Parameter Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_SUBCOMPONENT_SLOTS()

    // -------------------------------------------------------
    // DbgMin Component Statistics Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_STATISTICS()

    // -------------------------------------------------------
    // DbgMin Component Checkpoint Methods
    // -------------------------------------------------------
    /// DbgMin: serialization constructor
    DbgMin() :
        SST::Component()
    {} // For serialization only

    /// DbgMin: serialization
    void serialize_order(SST::Core::Serialization::serializer& ser) override;

    /// DbgMin: serialization implementations
    ImplementSerializable(SSTDEBUG::DbgMin::DbgMin)

private:
    SST::Output              output;                    ///< SST output handler
    SST::TimeConverter       timeConverter = {};        ///< SST time conversion handler
    SST::Clock::HandlerBase* clockHandler = nullptr;    ///< Clock Handler
    uint64_t                 clocks = 2;                ///< number of clocks to execute
    uint64_t                 curCycle = 0;              ///< current cycle delay

}; // class DbgMin

} // namespace SSTDEBUG::DbgMin

#endif // _SST_EXT_TESTS_DBGMIN_H_

// EOF
