# .rst: FindRapidjson
# --------
#
# Find the native rapidjson includes and library.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
# Rapidjson_INCLUDE_DIRS   - where to find rapidjson/document.h, etc. Rapidjson_LIBRARIES      - List of libraries when using rapidjson.
# Rapidjson_FOUND          - True if rapidjson found.
#
# ::
#
# Hints ^^^^^
#
# A user may set ``RAPIDJSON_ROOT`` to a rapidjson installation root to tell this module where to look.
#
# =============================================================================
# Copyright 2021 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

unset(_RAPIDJSON_SEARCH_ROOT_INC)
unset(_RAPIDJSON_SEARCH_ROOT_LIB)

# Search RAPIDJSON_ROOT first if it is set.
if(Rapidjson_ROOT)
  set(RAPIDJSON_ROOT ${Rapidjson_ROOT})
endif()

if(RAPIDJSON_ROOT)
  set(_RAPIDJSON_SEARCH_ROOT_INC PATHS ${RAPIDJSON_ROOT} ${RAPIDJSON_ROOT}/include NO_DEFAULT_PATH)
endif()

# Try each search configuration.
find_path(Rapidjson_INCLUDE_DIRS NAMES rapidjson/document.h ${_RAPIDJSON_SEARCH_ROOT_INC})

mark_as_advanced(Rapidjson_INCLUDE_DIRS)

# handle the QUIETLY and REQUIRED arguments and set RAPIDJSON_FOUND to TRUE if all listed variables are TRUE
include("FindPackageHandleStandardArgs")
find_package_handle_standard_args(
  Rapidjson
  REQUIRED_VARS Rapidjson_INCLUDE_DIRS
  FOUND_VAR Rapidjson_FOUND)

if(Rapidjson_FOUND)
  set(RAPIDJSON_FOUND ${Rapidjson_FOUND})
endif()
