//
// _LIST_TRAITS_H
//
// Copyright (C) 2017-2025 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

//
// Informational list of type traits useful for test audits
//

#include <iostream>
#include <type_traits>
#include <string>
#include <iomanip>

#define PRINT_TRAIT(trait, type) \
    std::cout << std::setw(30) << #trait << ": " \
              << (trait<type>::value ? "true" : "false") << '\n'

              