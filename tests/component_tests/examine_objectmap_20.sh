#!/usr/bin/env expect

spawn sst --interactive-console=sst.interactive.simpledebug --interactive-start=0 eCaptCrunchObjMap_20-DEV.py

expect "WARNING:*\r"
send -- "examine c0\r"
expect "c0/ (SST::CaptCrunchObjMap::CaptCrunchObjMap)\r*12\r*11\r*VStat/ (std::__1::vector<SST::Statistics::Statistic<unsigned long long>\*, std::__1::allocator<SST::Statistics::Statistic<unsigned long long>\*>>)\r*11\r*10\r*clockHandler/ (SST::SSTHandler2<bool, unsigned long long, SST::CaptCrunchObjMap::CaptCrunchObjMap, void, &SST::CaptCrunchObjMap::CaptCrunchObjMap::clockTick(unsigned long long)>)\r*10\r*9\r*component_state_ = 3 (SST::BaseComponent::ComponentState)\r*9\r*8\r*my_info_/ ()\r*8\r*7\r*my_info_/ (SST::ComponentInfo\*)\r*7\r*6\r*numClocks = 10000 (unsigned long long)\r*6\r*5\r*numStats = 100 (unsigned long long)\r*5\r*4\r*unsignedArrayList/ (std::__1::list<std::__1::array<unsigned int, 2ul>, std::__1::allocator<std::__1::array<unsigned int, 2ul>>>)\r*4\r*3\r*unsignedListList/ (std::__1::list<std::__1::list<unsigned int, std::__1::allocator<unsigned int>>, std::__1::allocator<std::__1::list<unsigned int, std::__1::allocator<unsigned int>>>>)\r*3\r*2\r*unsignedMapList/ (std::__1::list<std::__1::map<unsigned int, unsigned int, std::__1::less<unsigned int>, std::__1::allocator<std::__1::pair<unsigned int const, unsigned int>>>, std::__1::allocator<std::__1::map<unsigned int, unsigned int, std::__1::less<unsigned int>, std::__1::allocator<std::__1::pair<unsigned int const, unsigned int>>>>>)\r*2\r*1\r*unsignedVectList/ (std::__1::list<std::__1::vector<unsigned int, std::__1::allocator<unsigned int>>, std::__1::allocator<std::__1::vector<unsigned int, std::__1::allocator<unsigned int>>>>)\r*1\r*0\r"
send -- "exit\r"
expect "Exiting ObjectExplorer*"


