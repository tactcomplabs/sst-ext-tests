#!/usr/bin/env expect

spawn sst --interactive-console=sst.interactive.simpledebug --interactive-start=0 eCaptCrunchObjMap_3-DEV.py

expect "WARNING:*\r"
send -- "examine c0\r"
expect "c0/ (SST::CaptCrunchObjMap::CaptCrunchObjMap)\r*9\r*8\r*VStat/ (std::__1::vector<SST::Statistics::Statistic<unsigned long long>\*, std::__1::allocator<SST::Statistics::Statistic<unsigned long long>\*>>)\r*8\r*7\r*clockHandler/ (SST::SSTHandler2<bool, unsigned long long, SST::CaptCrunchObjMap::CaptCrunchObjMap, void, &SST::CaptCrunchObjMap::CaptCrunchObjMap::clockTick(unsigned long long)>)\r*7\r*6\r*component_state_ = 3 (SST::BaseComponent::ComponentState)\r*6\r*5\r*fTypeStructValue/ (SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct)\r*5\r*4\r*my_info_/ ()\r*4\r*3\r*my_info_/ (SST::ComponentInfo\*)\r*3\r*2\r*numClocks = 10000 (unsigned long long)\r*2\r*1\r*numStats = 100 (unsigned long long)\r*1\r*0\r"
send -- "exit\r"
expect "Exiting ObjectExplorer*"

