include_guard(GLOBAL)

# Patch for GCC 10.0
if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10.0.0" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.1.0")
  #[[
    Patch for well-known BUGs of GCC: internal compiler error during RTL pass: expand
    @see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=93642
    @see https://github.com/iains/gcc-cxx-coroutines/issues/1
  ]]
  if(COMPILER_OPTIONS_TEST_STD_COROUTINE OR COMPILER_OPTIONS_TEST_STD_COROUTINE_TS)
    string(REPLACE "-O0" "-O1" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    string(REPLACE "-O0" "-O1" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  endif()
endif()

# Patch for GCC 14.1
if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "14.0.0" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "14.1.0")
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-Wno-error=incompatible-pointer-types")
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-Wno-error=implicit-int")
  add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS "-Wno-error=incompatible-pointer-types")
  add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS "-Wno-error=implicit-int")
endif()

# Patch for GCC 14.1
if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "14.0.0" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "14.1.0")
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-Wno-error=uninitialized")
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-Wno-error=maybe-uninitialized")
  #[[
    Patch for well-known BUGs of GCC: internal compiler error during RTL pass: expand
    @see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=93642
    @see https://github.com/iains/gcc-cxx-coroutines/issues/1
  ]]
  if(COMPILER_OPTIONS_TEST_STD_COROUTINE OR COMPILER_OPTIONS_TEST_STD_COROUTINE_TS)
    string(REPLACE "-O0" "-O1" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    string(REPLACE "-O0" "-O1" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  endif()
endif()
