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
#include <array>
#include <cinttypes>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <deque>
#include <forward_list>
#include <list>
#include <map>
#include <memory>
#include <optional>
#include <queue>
#include <set>
#include <stack>
#include <string>
#include <tuple>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

// -- SST Headers
#include "SST.h"

namespace SST::CaptCrunch {

// -------------------------------------------------------
// CaptCrunch
// -------------------------------------------------------
class CaptCrunch : public SST::Component
{
public:
    /// LargeStat: top-level SST component constructor
    CaptCrunch(SST::ComponentId_t id, const SST::Params& params);

    /// CaptCrunch: top-level SST component destructor
    ~CaptCrunch();

    /// CaptCrunch: standard SST component 'setup' function
    void setup() override;

    /// CaptCrunch: standard SST component 'finish' function
    void finish() override;

    /// CaptCrunch: standard SST component init function
    void init(unsigned int phase) override;

    /// CaptCrunch: standard SST component clock function
    bool clockTick(SST::Cycle_t currentCycle);

    // -------------------------------------------------------
    // CaptCrunch Component Registration Data
    // -------------------------------------------------------
    /// CaptCrunch: Register the component with the SST core
    SST_ELI_REGISTER_COMPONENT(CaptCrunch,   // component class
                             "captcrunch", // component library
                             "CaptCrunch", // component name
                             SST_ELI_ELEMENT_VERSION(1, 0, 0),
                             "Crunchatize me, Cap'n!",
                             COMPONENT_CATEGORY_UNCATEGORIZED)

    SST_ELI_DOCUMENT_PARAMS(
      {"verbose", "Sets the verbosity level of output", "0"},
      {"numStats", "Sets the number of stats to create", "1"},
      {"numClocks", "Sets the number of clock cycles to execute", "1"}, )

    // -------------------------------------------------------
    // CaptCrunch SubComponent Parameter Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_SUBCOMPONENT_SLOTS()

    // -------------------------------------------------------
    // CaptCrunch Component Statistics Data
    // -------------------------------------------------------
    SST_ELI_DOCUMENT_STATISTICS({"STAT_", "Basic stat handler", "count", 1}, )

    // -------------------------------------------------------
    // CaptCrunch Component Checkpoint Methods
    // -------------------------------------------------------
    /// Chkpnt: serialization constructor
    CaptCrunch() :
        SST::Component()
    {}

    /// CaptCrunch: serialization
    void serialize_order(SST::Core::Serialization::serializer& ser) override;

    /// CaptCrunch: serialization implementations
    ImplementSerializable(SST::CaptCrunch::CaptCrunch)

private:
    // -- internal handlers
    SST::Output              output;        ///< SST output handler
    TimeConverter*           timeConverter; ///< SST time conversion handler
    SST::Clock::HandlerBase* clockHandler;  ///< Clock Handler

    uint64_t numStats;  ///< Number of stats to create
    uint64_t numClocks; ///< Number of clock cycles to run

    std::vector<Statistic<uint64_t>*> VStat; ///< Statistics vector

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

    uint8_t  u8Value;
    uint16_t u16Value;
    uint32_t u32Value;
    uint64_t u64Value;
    int8_t   s8Value;
    int16_t  s16Value;
    int32_t  s32Value;
    int64_t  s64Value;
    char     cValue;

    unsigned           unsignedValue;
    signed             signedValue;
    unsigned long      uLongValue;
    unsigned long long uLongLongValue;
    signed long        sLongValue;
    signed long long   sLongLongValue;

    struct __fundamentalTypeStruct
    {
        uint8_t  u8Value;
        uint16_t u16Value;
        uint32_t u32Value;
        uint64_t u64Value;
        int8_t   s8Value;
        int16_t  s16Value;
        int32_t  s32Value;
        int64_t  s64Value;
        char     cValue;

        unsigned           unsignedValue;
        signed             signedValue;
        unsigned long      uLongValue;
        unsigned long long uLongLongValue;
        signed long        sLongValue;
        signed long long   sLongLongValue;

        bool operator<(const __fundamentalTypeStruct& rhs) const { return u64Value < rhs.u64Value; }

        bool operator>(const __fundamentalTypeStruct& rhs) const { return u64Value > rhs.u64Value; }

        bool operator==(const __fundamentalTypeStruct& rhs) const { return u64Value == rhs.u64Value; }

        bool operator!=(const __fundamentalTypeStruct& rhs) const { return u64Value != rhs.u64Value; }

        struct Hash
        {
            size_t operator()(const __fundamentalTypeStruct& s) const
            {
                // Use a simple hash combining technique
                size_t seed = 0;

                // Helper function to combine hash values
                auto hash_combine = [&seed](size_t hash) {
                    hash += 0x9e3779b9 + (seed << 6) + (seed >> 2);
                    seed ^= hash;
                };

                // Combine the hashes of all members
                hash_combine(std::hash<uint8_t>()(s.u8Value));
                hash_combine(std::hash<uint16_t>()(s.u16Value));
                hash_combine(std::hash<uint32_t>()(s.u32Value));
                hash_combine(std::hash<uint64_t>()(s.u64Value));
                hash_combine(std::hash<int8_t>()(s.s8Value));
                hash_combine(std::hash<int16_t>()(s.s16Value));
                hash_combine(std::hash<int32_t>()(s.s32Value));
                hash_combine(std::hash<int64_t>()(s.s64Value));
                hash_combine(std::hash<char>()(s.cValue));
                hash_combine(std::hash<unsigned>()(s.unsignedValue));
                hash_combine(std::hash<int>()(s.signedValue));
                hash_combine(std::hash<unsigned long>()(s.uLongValue));
                hash_combine(std::hash<unsigned long long>()(s.uLongLongValue));
                hash_combine(std::hash<long>()(s.sLongValue));
                hash_combine(std::hash<long long>()(s.sLongLongValue));

                return seed;
            }
        };

        void serialize_order(SST::Core::Serialization::serializer& ser)
        {
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

    std::string strValue;

    std::tuple<unsigned, char> unsignedCharTuple;

    std::vector<unsigned>                       unsignedVect;
    std::vector<char>                           charVect;
    std::vector<struct __fundamentalTypeStruct> structVect;

    std::stack<unsigned>                       unsignedStack;
    std::stack<char>                           charStack;
    std::stack<struct __fundamentalTypeStruct> structStack;

    std::queue<unsigned>                       unsignedQueue;
    std::queue<char>                           charQueue;
    std::queue<struct __fundamentalTypeStruct> structQueue;

    std::priority_queue<unsigned>                       unsignedPQueue;
    std::priority_queue<char>                           charPQueue;
    std::priority_queue<struct __fundamentalTypeStruct> structPQueue;

    std::deque<unsigned>                       unsignedDQ;
    std::deque<char>                           charDQ;
    std::deque<struct __fundamentalTypeStruct> structDQ;

    std::forward_list<unsigned>                       unsignedFL;
    std::forward_list<char>                           charFL;
    std::forward_list<struct __fundamentalTypeStruct> structFL;

    std::list<unsigned>                       unsignedList;
    std::list<char>                           charList;
    std::list<struct __fundamentalTypeStruct> structList;

    std::array<unsigned, 2>                       unsignedArray;
    std::array<char, 2>                           charArray;
    std::array<struct __fundamentalTypeStruct, 2> structArray;

    std::set<unsigned>                       unsignedSet;
    std::set<char>                           charSet;
    std::set<struct __fundamentalTypeStruct> structSet;

    std::map<unsigned, unsigned>                       unsignedMap;
    std::map<char, unsigned>                           charMap;
    std::map<unsigned, struct __fundamentalTypeStruct> structMap;

    std::multiset<unsigned>                       unsignedMSet;
    std::multiset<char>                           charMSet;
    std::multiset<struct __fundamentalTypeStruct> structMSet;

    std::multimap<unsigned, unsigned>                       unsignedMMap;
    std::multimap<char, unsigned>                           charMMap;
    std::multimap<unsigned, struct __fundamentalTypeStruct> structMMap;

    std::unordered_set<unsigned>                                                      unsignedUnSet;
    std::unordered_set<char>                                                          charUnSet;
    std::unordered_set<struct __fundamentalTypeStruct, __fundamentalTypeStruct::Hash> structUnSet;

    std::unordered_map<unsigned, unsigned>                       unsignedUnMap;
    std::unordered_map<char, unsigned>                           charUnMap;
    std::unordered_map<unsigned, struct __fundamentalTypeStruct> structUnMap;

    std::unordered_multiset<unsigned>                                                      unsignedUnMSet;
    std::unordered_multiset<char>                                                          charUnMSet;
    std::unordered_multiset<struct __fundamentalTypeStruct, __fundamentalTypeStruct::Hash> structUnMSet;

    std::unordered_multimap<unsigned, unsigned>                       unsignedUnMMap;
    std::unordered_multimap<char, unsigned>                           charUnMMap;
    std::unordered_multimap<unsigned, struct __fundamentalTypeStruct> structUnMMap;

    std::vector<std::vector<unsigned>>        unsignedVectVect;
    std::vector<std::list<unsigned>>          unsignedListVect;
    std::vector<std::array<unsigned, 2>>      unsignedArrayVect;
    std::vector<std::map<unsigned, unsigned>> unsignedMapVect;

    std::list<std::list<unsigned>>          unsignedListList;
    std::list<std::vector<unsigned>>        unsignedVectList;
    std::list<std::array<unsigned, 2>>      unsignedArrayList;
    std::list<std::map<unsigned, unsigned>> unsignedMapList;

    std::vector<std::vector<std::vector<unsigned>>> unsignedVectVectVect;

    std::unique_ptr<int> uniquePtrInt;
    std::unique_ptr<size_t[]> uniquePtrIntArray;
    size_t uniquePtrIntArraySize;
    std::unique_ptr<size_t[20]> uniquePtrIntFixedArray;

    std::optional<int> optionalInt;
    std::optional<std::vector<int>> optionalVectorInt;

    std::variant<int, std::vector<int>, std::tuple<bool, int>> variant;

    // ---------------------------------------
    // END SERIALIZED DATA STRUCTURES
    // ---------------------------------------

}; // class CaptCrunch
} // namespace SST::CaptCrunch

#endif // _SST_CAPTCRUNCH_H_

// EOF
