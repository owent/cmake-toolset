#.rst:
# FindLibsodium
# --------
#
# Find the native mbemtls includes and library.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
#   Libsodium_INCLUDE_DIRS      - where to find uv.h, etc.
#   Libsodium_LIBRARIES         - List of all libraries when using mbemtls.
#   Libsodium_FOUND             - True if mbemtls found.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
# sodium::sodium
#
# Hints
# ^^^^^
#
# A user may set ``LIBSODIUM_ROOT`` to a mbemtls installation root to tell this
# module where to look.

# =============================================================================
# Copyright 2021 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE for details.

unset(_LIBSODIUM_SEARCH_ROOT_INC)
unset(_LIBSODIUM_SEARCH_ROOT_LIB)

# Search LIBSODIUM_ROOT first if it is set.
if(Libsodium_ROOT)
  set(LIBSODIUM_ROOT ${Libsodium_ROOT})
endif()

if(LIBSODIUM_ROOT)
  set(_LIBSODIUM_SEARCH_ROOT_INC PATHS ${LIBSODIUM_ROOT} ${LIBSODIUM_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBSODIUM_SEARCH_ROOT_LIB PATHS ${LIBSODIUM_ROOT} ${LIBSODIUM_ROOT}/lib NO_DEFAULT_PATH)
endif()

# Normal search.
set(Libsodium_NAMES sodium libsodium)

# Try each search configuration.
find_path(Libsodium_INCLUDE_DIRS NAMES sodium.h ${_LIBSODIUM_SEARCH_ROOT_INC})
find_library(Libsodium_LIBRARIES NAMES ${Libsodium_NAMES} ${_LIBSODIUM_SEARCH_ROOT_LIB})

mark_as_advanced(Libsodium_INCLUDE_DIRS Libsodium_LIBRARIES)

# handle the QUIETLY and REQUIRED arguments and set Libsodium_FOUND to TRUE if all listed variables are TRUE
include("FindPackageHandleStandardArgs")
find_package_handle_standard_args(
  Libsodium
  REQUIRED_VARS Libsodium_INCLUDE_DIRS Libsodium_LIBRARIES
  FOUND_VAR Libsodium_FOUND)

if(Libsodium_FOUND)
  set(LIBSODIUM_FOUND ${Libsodium_FOUND})
  if(NOT TARGET libsodium::libsodium)
    add_library(libsodium::libsodium UNKNOWN IMPORTED)
    set_target_properties(libsodium::libsodium PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libsodium_INCLUDE_DIRS}")
    set_target_properties(libsodium::libsodium PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX;ASM"
                                                          IMPORTED_LOCATION "${Libsodium_LIBRARIES}")
    if(MSVC)
      target_link_libraries(libsodium::libsodium PUBLIC advapi32)
    else()
      find_package(Threads)
      if(CMAKE_USE_PTHREADS_INIT AND THREADS_PREFER_PTHREAD_FLAG)
        target_compile_options(libsodium::libsodium INTERFACE ${THREADS_PREFER_PTHREAD_FLAG})
      endif()
    endif()
  endif()
endif()
