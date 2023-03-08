#.rst:
# FindLibuuid
# --------
#
# Find the native libuuid includes and library.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   libuuid
#
# ::
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
#   Libuuid_INCLUDE_DIRS   - where to find uv.h, etc.
#   Libuuid_LIBRARIES      - List of libraries when using libuuid.
#   Libuuid_FOUND          - True if libuuid found.
#
# ::
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
# libuuid
#
# Hints
# ^^^^^
#
# A user may set ``LIBUUID_ROOT`` to a libuuid installation root to tell this
# module where to look.
#
# =============================================================================
# Copyright 2021 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

unset(_LIBUUID_SEARCH_ROOT_INC)
unset(_LIBUUID_SEARCH_ROOT_LIB)

# Search LIBUUID_ROOT first if it is set.
if(Libuuid_ROOT)
  set(LIBUUID_ROOT ${Libuuid_ROOT})
endif()

if(LIBUUID_ROOT)
  set(_LIBUUID_SEARCH_ROOT_INC PATHS ${LIBUUID_ROOT} ${LIBUUID_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBUUID_SEARCH_ROOT_LIB PATHS ${LIBUUID_ROOT} ${LIBUUID_ROOT}/lib NO_DEFAULT_PATH)
endif()

# Normal search.
set(Libuuid_NAMES uuid libuuid)

# Try each search configuration.
if(APPLE OR IOS)
  set(_LIBUUID_SEARCH_BACKUP_CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK})
  set(CMAKE_FIND_FRAMEWORK NEVER)
endif()
find_path(Libuuid_INCLUDE_DIRS NAMES uuid/uuid.h ${_LIBUUID_SEARCH_ROOT_INC})

if(Libuuid_INCLUDE_DIRS)
  include(CheckCSourceCompiles)
  include(CMakePushCheckState)
  cmake_push_check_state()
  list(APPEND CMAKE_REQUIRED_INCLUDES ${Libuuid_INCLUDE_DIRS})
  check_c_source_compiles(
    "#include <stdio.h>
#include <uuid/uuid.h>

int main () {
  uuid_t uuid;
  uuid_generate(uuid);
  return 0;
}"
    Libuuid_CHECK_NO_LIBRARY)
  cmake_pop_check_state()
endif()

if(Libuuid_CHECK_NO_LIBRARY)
  mark_as_advanced(Libuuid_INCLUDE_DIRS)
else()
  find_library(Libuuid_LIBRARIES NAMES ${Libuuid_NAMES} ${_LIBUUID_SEARCH_ROOT_LIB})
  mark_as_advanced(Libuuid_INCLUDE_DIRS Libuuid_LIBRARIES)
endif()

if(_LIBUUID_SEARCH_BACKUP_CMAKE_FIND_FRAMEWORK)
  set(CMAKE_FIND_FRAMEWORK ${_LIBUUID_SEARCH_BACKUP_CMAKE_FIND_FRAMEWORK})
  unset(_LIBUUID_SEARCH_BACKUP_CMAKE_FIND_FRAMEWORK)
endif()

# handle the QUIETLY and REQUIRED arguments and set LIBUUID_FOUND to TRUE if all listed variables are TRUE
include("FindPackageHandleStandardArgs")
if(Libuuid_CHECK_NO_LIBRARY)
  find_package_handle_standard_args(
    Libuuid
    REQUIRED_VARS Libuuid_INCLUDE_DIRS
    FOUND_VAR Libuuid_FOUND)
else()
  find_package_handle_standard_args(
    Libuuid
    REQUIRED_VARS Libuuid_INCLUDE_DIRS Libuuid_LIBRARIES
    FOUND_VAR Libuuid_FOUND)
endif()

if(Libuuid_FOUND)
  set(LIBUUID_FOUND ${Libuuid_FOUND})

  if(NOT TARGET libuuid)
    if(Libuuid_LIBRARIES)
      add_library(libuuid UNKNOWN IMPORTED)
    else()
      add_library(libuuid INTERFACE IMPORTED)
    endif()
    set_target_properties(libuuid PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${Libuuid_INCLUDE_DIRS})

    if(Libuuid_LIBRARIES)
      set_target_properties(libuuid PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX;RC" IMPORTED_LOCATION
                                                                                            ${Libuuid_LIBRARIES})
    endif()

    if(WIN32)
      set_target_properties(libuuid PROPERTIES INTERFACE_LINK_LIBRARIES "psapi;iphlpapi;userenv;ws2_32")
    endif()
  endif()
else()
  unset(Libuuid_INCLUDE_DIRS CACHE)
  unset(Libuuid_LIBRARIES CACHE)
endif()
