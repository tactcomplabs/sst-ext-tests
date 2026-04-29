//
// _sst-platform_cc_
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

#include <cstring>
#include <iostream>
#include <ostream>
#include <string>
#include "sst/core/sst_config.h"

const std::string getPackageStr(){
  std::string PkgStr = PACKAGE_VERSION;
  return PkgStr;
}

const std::string getArchStr(){
  std::string ArchStr = "";
#if defined(__x86_64__) || defined(_M_X64)
  ArchStr = "x86_64";
#elif defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
  ArchStr = "x86_32";
#elif defined(__ARM_ARCH_2__)
  ArchStr = "ARM2";
#elif defined(__ARM_ARCH_3__) || defined(__ARM_ARCH_3M__)
  ArchStr = "ARM3";
#elif defined(__ARM_ARCH_4T__) || defined(__TARGET_ARM_4T)
  ArchStr = "ARM4T";
#elif defined(__ARM_ARCH_5_) || defined(__ARM_ARCH_5E_)
  ArchStr = "ARM5"
#elif defined(__ARM_ARCH_6T2_) || defined(__ARM_ARCH_6T2_)
  ArchStr = "ARM6T2";
#elif defined(__ARM_ARCH_6__) || defined(__ARM_ARCH_6J__) || defined(__ARM_ARCH_6K__) || defined(__ARM_ARCH_6Z__) || \
    defined(__ARM_ARCH_6ZK__)
  ArchStr = "ARM6";
#elif defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || \
    defined(__ARM_ARCH_7S__)
  ArchStr = "ARM7";
#elif defined(__aarch64__) || defined(_M_ARM64)
  ArchStr = "ARM64";
#elif defined(mips) || defined(__mips__) || defined(__mips)
  ArchStr = "MIPS";
#elif defined(__sh__)
  ArchStr = "SUPERH";
#elif defined(__powerpc) || defined(__powerpc__) || defined(__powerpc64__) || defined(__POWERPC__) || \
    defined(__ppc__) || defined(__PPC__) || defined(_ARCH_PPC)
  ArchStr = "POWERPC";
#elif defined(__PPC64__) || defined(__ppc64__) || defined(_ARCH_PPC64)
  ArchStr = "POWERPC64";
#elif defined(__sparc__) || defined(__sparc)
  ArchStr = "SPARC";
#elif defined(__m68k__)
  ArchStr = "M68K";
#elif defined(__riscv__) || defined(_riscv) || defined(__riscv)
  ArchStr = "RISCV";
#else
  ArchStr = "UNKNOWN";
#endif
  return ArchStr;
}

const std::string getOSStr(){
  std::string OSStr = "";

#if defined(_WIN32) || defined(_WIN64)
  OSStr = "OS_WINDOWS";
#elif defined(__APPLE__) && defined(__MACH__)
  OSStr = "OS_MACOS";
#elif defined(__linux__)
  OSStr = "OS_LINUX";
#elif defined(__unix__) || defined(__unix)
  OSStr = "OS_UNIX";
#elif defined(__FreeBSD__)
  OSStr = "OS_FREEBSD";
#else
  OSStr = "OS_UNKNOWN";
#endif

  return OSStr;
}

int main( int argc, char **argv ){

  if( argc > 1 ){
    for( int i=1; i<argc; i++ ){
      if( std::strcmp(argv[i], "-p") == 0 ||
          std::strcmp(argv[i], "--package") == 0){
        std::cout << getPackageStr() << std::endl;
      }else if( std::strcmp(argv[i], "-a") == 0 ||
                std::strcmp(argv[i], "--arch") == 0){
        std::cout << getArchStr() << std::endl;
      }else if( std::strcmp(argv[i], "-o") == 0 ||
                std::strcmp(argv[i], "--os") == 0){
        std::cout << getOSStr() << std::endl;
      }else if( std::strcmp(argv[i], "-h") == 0 ||
                std::strcmp(argv[i], "--help") == 0){
        std::cout << "USAGE: sst-platform [options]" << std::endl;
        std::cout << " -p | --package : Print the SST-Core package version" << std::endl;
        std::cout << " -a | --arch    : Print the architecture" << std::endl;
        std::cout << " -o | --os      : Print the operating system" << std::endl;
        return 0;
      }
    }
  }

  return 0;
}
