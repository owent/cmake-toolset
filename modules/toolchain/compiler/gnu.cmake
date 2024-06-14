include_guard(GLOBAL)

# Patch for GCC 14.1
if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "14.0.0" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "14.1.0")
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-Wno-error=incompatible-pointer-types")
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-Wno-error=implicit-int")
  add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS "-Wno-error=incompatible-pointer-types")
  add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS "-Wno-error=implicit-int")
endif()
