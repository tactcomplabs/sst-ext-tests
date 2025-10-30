#!/usr/bin/env expect

spawn sst --interactive-console=sst.interactive.simpledebug --interactive-start=0 eCaptCrunchObjMap_6-DEV.py

expect "WARNING:*\r"
send -- "examine c0\r"
expect "c0/ (SST::CaptCrunchObjMap::CaptCrunchObjMap)\r*14\r*13\r*VStat/ (std::__1::vector<SST::Statistics::Statistic<unsigned long long>\*, std::__1::allocator<SST::Statistics::Statistic<unsigned long long>\*>>)\r*13\r*12\r*clockHandler/ (SST::SSTHandler2<bool, unsigned long long, SST::CaptCrunchObjMap::CaptCrunchObjMap, void, &SST::CaptCrunchObjMap::CaptCrunchObjMap::clockTick(unsigned long long)>)\r*12\r*11\r*component_state_ = 3 (SST::BaseComponent::ComponentState)\r*11\r*10\r*my_info_/ ()\r*10\r*9\r*my_info_/ (SST::ComponentInfo\*)\r*9\r*8\r*numClocks = 10000 (unsigned long long)\r*8\r*7\r*numStats = 100 (unsigned long long)\r*7\r*6\r*static_cast<S&>(v).c/ (std::__1::deque<unsigned int, std::__1::allocator<unsigned int>>)\r*6\r*5\r*static_cast<S&>(v).c/ (std::__1::deque<char, std::__1::allocator<char>>)\r*5\r*4\r*static_cast<S&>(v).c/ (std::__1::deque<SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct, std::__1::allocator<SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct>>)\r*4\r*3\r*static_cast<S&>(v).c/ (std::__1::vector<unsigned int, std::__1::allocator<unsigned int>>)\r*3\r*2\r*static_cast<S&>(v).c/ (std::__1::vector<char, std::__1::allocator<char>>)\r*2\r*1\r*static_cast<S&>(v).c/ (std::__1::vector<SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct, std::__1::allocator<SST::CaptCrunchObjMap::CaptCrunchObjMap::__fundamentalTypeStruct>>)\r*1\r*0\r"
send -- "exit\r"
expect "Exiting ObjectExplorer*"

