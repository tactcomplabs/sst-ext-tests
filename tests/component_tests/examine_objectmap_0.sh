#!/usr/bin/env expect

spawn sst --interactive-console=sst.interactive.simpledebug --interactive-start=0 eCaptCrunchObjMap_0-DEV.py

expect "WARNING:*\r"
send -- "examine c0\r"
expect "c0/ (SST::CaptCrunchObjMap::CaptCrunchObjMap)\r*23\r*22\r*VStat/ (std::__1::vector<SST::Statistics::Statistic<unsigned long long>\*, std::__1::allocator<SST::Statistics::Statistic<unsigned long long>\*>>)\r*22\r*21\r*cValue = 89 (char)\r*21\r*20\r*clockHandler/ (SST::SSTHandler2<bool, unsigned long long, SST::CaptCrunchObjMap::CaptCrunchObjMap, void, &SST::CaptCrunchObjMap::CaptCrunchObjMap::clockTick(unsigned long long)>)\r*20\r*19\r*component_state_ = 3 (SST::BaseComponent::ComponentState)\r*19\r*18\r*my_info_/ ()\r*18\r*17\r*my_info_/ (SST::ComponentInfo\*)\r*17\r*16\r*numClocks = 10000 (unsigned long long)\r*16\r*15\r*numStats = 100 (unsigned long long)\r*15\r*14\r*s16Value = -2 (short)\r*14\r*13\r*s32Value = -3 (int)\r*13\r*12\r*s64Value = -4 (long long)\r*12\r*11\r*s8Value = -1 (signed char)\r*11\r*10\r*sLongLongValue = -1234 (long long)\r*10\r*9\r*sLongValue = -1234 (long)\r*9\r*8\r*signedValue = -1234 (int)\r*8\r*7\r*u16Value = 2 (unsigned short)\r*7\r*6\r*u32Value = 3 (unsigned int)\r*6\r*5\r*u64Value = 4 (unsigned long long)\r*5\r*4\r*u8Value = 1 (unsigned char)\r*4\r*3\r*uLongLongValue = 1234 (unsigned long long)\r*3\r*2\r*uLongValue = 1234 (unsigned long)\r*2\r*1\r*unsignedValue = 1234 (unsigned int)\r*1\r*0\r"
send -- "exit\r"
expect "Exiting ObjectExplorer*"



