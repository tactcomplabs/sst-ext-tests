#!/usr/bin/env expect

spawn sst --interactive-console=sst.interactive.simpledebug --interactive-start=0 eCaptCrunchObjMap_4-DEV.py

expect "WARNING:*\r"
send -- "examine c0\r"
expect "c0/ (SST::CaptCrunchObjMap::CaptCrunchObjMap)\r*11\r*10\r*VStat/ (std::__1::vector<SST::Statistics::Statistic<unsigned long long>\*, std::__1::allocator<SST::Statistics::Statistic<unsigned long long>\*>>)\r*10\r*9\r*charVect/ (std::__1::vector<char, std::__1::allocator<char>>)\r*9\r*8\r*clockHandler/ (SST::SSTHandler2<bool, unsigned long long, SST::CaptCrunchObjMap::CaptCrunchObjMap, void, &SST::CaptCrunchObjMap::CaptCrunchObjMap::clockTick(unsigned long long)>)\r*8\r*7\r*component_state_ = 3 (SST::BaseComponent::ComponentState)\r*7\r*6\r*my_info_/ ()\r*6\r*5\r*my_info_/ (SST::ComponentInfo\*)\r*5\r*4\r*numClocks = 10000 (unsigned long long)\r*4\r*3\r*numStats = 100 (unsigned long long)\r*3\r*2\r*structVect/ (std::__1::vector<SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct, std::__1::allocator<SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct>>)\r*2\r*1\r*unsignedVect/ (std::__1::vector<unsigned int, std::__1::allocator<unsigned int>>)\r*1\r*0\r"
send -- "exit\r"
expect "Exiting ObjectExplorer*"
