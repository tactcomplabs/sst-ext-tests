//
// _LIST_TRAITS_H
//
// Copyright (C) 2017-2026 Tactical Computing Laboratories, LLC
// All Rights Reserved
// contact@tactcomplabs.com
//
// See LICENSE in the top level directory for licensing details
//

//
// Informational list of type traits useful for test audits
// ref: https://en.cppreference.com/w/cpp/header/type_traits.html

#ifndef _SST_EXT_TESTS_LIST_TRAITS_H_
#define _SST_EXT_TESTS_LIST_TRAITS_H_

#include <cxxabi.h>
#include <iomanip>
#include <iostream>
#include <string>
#include <sstream>
#include <type_traits>

#define PRINT_TRAIT(o, trait, type) \
    o << std::setw(40) << #trait << ": " \
              << (trait<type>::value ? "true" : "false") << '\n';

template <typename T>
std::string demangled_type_string(const T& obj) {
  int status;
  char* s = abi::__cxa_demangle(typeid(obj).name(), nullptr, nullptr, &status);
  if (status == 0 ) {
    std::string ret(s);
    std::free(s);
    return ret;
  }
  return "";
};
// Template function to list traits for a given type
template <typename T>
std::string list_type_traits(const T& obj) {
    std::stringstream s;
    s << "type traits for: " << demangled_type_string(obj) << std::endl;
    s << "----------------------------------------\n";

    // Primary type categories
    PRINT_TRAIT(s, std::is_void, T);
    PRINT_TRAIT(s, std::is_null_pointer, T);
    PRINT_TRAIT(s, std::is_integral, T);
    PRINT_TRAIT(s, std::is_floating_point, T);
    PRINT_TRAIT(s, std::is_array, T);
    PRINT_TRAIT(s, std::is_enum, T);
    PRINT_TRAIT(s, std::is_union, T);
    PRINT_TRAIT(s, std::is_class, T);
    PRINT_TRAIT(s, std::is_function, T)
    PRINT_TRAIT(s, std::is_pointer, T);
    PRINT_TRAIT(s, std::is_lvalue_reference, T);
    PRINT_TRAIT(s, std::is_rvalue_reference, T);
    PRINT_TRAIT(s, std::is_member_object_pointer, T);
    PRINT_TRAIT(s, std::is_member_function_pointer, T)

    // Composite type categories
    PRINT_TRAIT(s, std::is_fundamental, T);
    PRINT_TRAIT(s, std::is_arithmetic, T);
    PRINT_TRAIT(s, std::is_scalar, T);
    PRINT_TRAIT(s, std::is_object, T);
    PRINT_TRAIT(s, std::is_compound, T);
    PRINT_TRAIT(s, std::is_reference, T);
    PRINT_TRAIT(s, std::is_member_pointer, T);

    // Type properties
    PRINT_TRAIT(s, std::is_const, T);
    PRINT_TRAIT(s, std::is_volatile, T);
    PRINT_TRAIT(s, std::is_trivial, T);         // deprecated in C++26
    PRINT_TRAIT(s, std::is_trivially_copyable, T);
    PRINT_TRAIT(s, std::is_standard_layout, T);
    PRINT_TRAIT(s, std::is_pod, T);             // deprecated in C++20
    // PRINT_TRAIT(s, std::is_literal_type, T); // deprecated in C++17
    PRINT_TRAIT(s, std::has_unique_object_representations, T); // C++17
    PRINT_TRAIT(s, std::is_empty, T);
    PRINT_TRAIT(s, std::is_polymorphic, T);
    PRINT_TRAIT(s, std::is_abstract, T);
    PRINT_TRAIT(s, std::is_final, T);           // C++14
    PRINT_TRAIT(s, std::is_aggregate, T);       // C++17
    // PRINT_TRAIT(s, std::is_implicit_lifetime, T); // c++23
    PRINT_TRAIT(s, std::is_signed, T);
    PRINT_TRAIT(s, std::is_unsigned, T);
    // PRINT_TRAIT(s, std::is_bounded_array, T);    // c++20
    // PRINT_TRAIT(s, std::is_unbounded_array, T);  // c++20
    // PRINT_TRAIT(s, std::is_scoped_enum, T);      // c++23   

    // Supported operations
    PRINT_TRAIT(s, std::is_constructible, T);
    PRINT_TRAIT(s, std::is_trivially_constructible, T);
    PRINT_TRAIT(s, std::is_nothrow_constructible, T);

    PRINT_TRAIT(s, std::is_default_constructible, T);
    PRINT_TRAIT(s, std::is_trivially_default_constructible, T);
    PRINT_TRAIT(s, std::is_nothrow_default_constructible, T);

    PRINT_TRAIT(s, std::is_copy_constructible, T);
    PRINT_TRAIT(s, std::is_trivially_copy_constructible, T);
    PRINT_TRAIT(s, std::is_nothrow_copy_constructible, T);

    PRINT_TRAIT(s, std::is_move_constructible, T);
    PRINT_TRAIT(s, std::is_trivially_move_constructible, T);
    PRINT_TRAIT(s, std::is_nothrow_move_constructible, T);

    // PRINT_TRAIT(s, std::is_assignable, T);           // Requires 2 parameters
    // PRINT_TRAIT(s, std::is_trivially_assignable, T);
    // PRINT_TRAIT(s, std::is_nothrow_assignable, T);

    PRINT_TRAIT(s, std::is_copy_assignable, T);
    PRINT_TRAIT(s, std::is_trivially_copy_assignable, T);
    PRINT_TRAIT(s, std::is_nothrow_copy_assignable, T);

    PRINT_TRAIT(s, std::is_move_assignable, T);
    PRINT_TRAIT(s, std::is_trivially_move_assignable, T);
    PRINT_TRAIT(s, std::is_nothrow_move_assignable, T);

    PRINT_TRAIT(s, std::is_destructible, T);
    PRINT_TRAIT(s, std::is_trivially_destructible, T);
    PRINT_TRAIT(s, std::is_nothrow_destructible, T);

    PRINT_TRAIT(s, std::has_virtual_destructor, T);

    // PRINT_TRAIT(s, std::is_swappable_with, T);       // c++17 Requires 2 parameters
    // PRINT_TRAIT(s, std::is_swappable, T);
    // PRINT_TRAIT(s, std::is_nothrow_swappable_with, T);
    // PRINT_TRAIT(s, std::is_nothrow_swappable, T);

    // PRINT_TRAIT(s, std::reference_converts_from_temporary, T);   // c++23
    // PRINT_TRAIT(s, std::reference_constructs_from_temporary, T); // c++23

    s << "----------------------------------------\n";
    return s.str();
}

#endif //_SST_EXT_TESTS_LIST_TRAITS_H_
