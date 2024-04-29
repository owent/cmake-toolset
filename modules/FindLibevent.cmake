# .rst: FindLibevent
# --------
#
# Find the native libevent includes and library.
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
# Libevent_INCLUDE_DIRS   - where to find event2/event.h, etc.
# Libevent_LIBRARIES      - List of libraries when using libevent.
# LIBEVENT_INCLUDE_DIRS   - where to find event2/event.h, etc.
# LIBEVENT_LIBRARIES      - List of libraries when using libevent.
# Libevent_FOUND          - True if libevent found.
# LIBEVENT_FOUND          - True if libevent found.
#
# ::
#
# Hints ^^^^^
#
# A user may set ``LIBEVENT_ROOT`` to a libevent installation root to tell this module where to look.

# =============================================================================
# Copyright 2024 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE for details.

unset(_LIBEVENT_SEARCH_ROOT_INC)
unset(_LIBEVENT_SEARCH_ROOT_LIB)

# Search LIBEVENT_ROOT first if it is set.
if(Libevent_ROOT)
  set(LIBEVENT_ROOT ${Libevent_ROOT})
endif()

if(LIBEVENT_ROOT)
  set(_LIBEVENT_SEARCH_ROOT_INC PATHS ${LIBEVENT_ROOT} ${LIBEVENT_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBEVENT_SEARCH_ROOT_LIB PATHS ${LIBEVENT_ROOT} ${LIBEVENT_ROOT}/lib NO_DEFAULT_PATH)
endif()

# Try each search configuration.
find_path(Libevent_INCLUDE_DIRS NAMES event.h ${_LIBEVENT_SEARCH_ROOT_INC})
find_library(Libevent_LIBRARIES_CORE NAMES event_core libevent_core ${_LIBEVENT_SEARCH_ROOT_LIB})
find_library(Libevent_LIBRARIES_EXTRA NAMES event_extra libevent_extra ${_LIBEVENT_SEARCH_ROOT_LIB})
find_library(Libevent_LIBRARIES_OPENSSL NAMES event_openssl libevent_openssl ${_LIBEVENT_SEARCH_ROOT_LIB})
find_library(Libevent_LIBRARIES_PTHREAD NAMES event_pthreads libevent_pthreads ${_LIBEVENT_SEARCH_ROOT_LIB})
if(NOT Libevent_LIBRARIES_CORE)
  find_library(Libevent_LIBRARIES NAMES event libevent ${_LIBEVENT_SEARCH_ROOT_LIB})
else()
  unset(Libevent_LIBRARIES)
  if(Libevent_LIBRARIES_OPENSSL)
    list(APPEND Libevent_LIBRARIES ${Libevent_LIBRARIES_OPENSSL})
  endif()
  if(Libevent_LIBRARIES_PTHREAD)
    list(APPEND Libevent_LIBRARIES ${Libevent_LIBRARIES_PTHREAD})
  endif()
  if(Libevent_LIBRARIES_EXTRA)
    list(APPEND Libevent_LIBRARIES ${Libevent_LIBRARIES_EXTRA})
  endif()
  if(Libevent_LIBRARIES_CORE)
    list(APPEND Libevent_LIBRARIES ${Libevent_LIBRARIES_CORE})
  endif()
endif()

mark_as_advanced(Libevent_INCLUDE_DIRS Libevent_LIBRARIES)

# handle the QUIETLY and REQUIRED arguments and set LIBEVENT_FOUND to TRUE if all listed variables are TRUE
include("FindPackageHandleStandardArgs")
find_package_handle_standard_args(
  Libevent
  REQUIRED_VARS Libevent_INCLUDE_DIRS Libevent_LIBRARIES
  FOUND_VAR Libevent_FOUND)

if(Libevent_FOUND)
  set(LIBEVENT_FOUND ${Libevent_FOUND})
  set(LIBEVENT_INCLUDE_DIRS "${Libevent_INCLUDE_DIRS}")
  set(LIBEVENT_LIBRARIES "${Libevent_LIBRARIES}")
  if(Libevent_LIBRARIES_CORE AND NOT TARGET libevent::core)
    add_library(libevent::core UNKNOWN IMPORTED)
    set_target_properties(libevent::core PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libevent_INCLUDE_DIRS}")
    set_target_properties(libevent::core PROPERTIES IMPORTED_LOCATION "${Libevent_LIBRARIES_CORE}")
  elseif(Libevent_LIBRARIES AND NOT TARGET libevent::core)
    list(GET Libevent_LIBRARIES 0 Libevent_LIBRARIES_LOCATION)
    set_target_properties(libevent::core PROPERTIES IMPORTED_LOCATION "${Libevent_LIBRARIES_LOCATION}")
    list(LENGTH Libevent_LIBRARIES Libevent_LIBRARIES_LENGTH)
    if(Libevent_LIBRARIES_LENGTH GREATER 1)
      set(Libevent_LIBRARIES_LOCATION ${Libevent_LIBRARIES})
      list(REMOVE_AT Libevent_LIBRARIES_LOCATION 0)
      set_target_properties(libevent::core PROPERTIES INTERFACE_LINK_LIBRARIES "${Libevent_LIBRARIES_LOCATION}")
    endif()
    unset(Libevent_LIBRARIES_LOCATION)
    unset(Libevent_LIBRARIES_LENGTH)
  endif()

  if(Libevent_LIBRARIES_EXTRA AND NOT TARGET libevent::extra)
    add_library(libevent::extra UNKNOWN IMPORTED)
    set_target_properties(libevent::extra PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libevent_INCLUDE_DIRS}")
    set_target_properties(libevent::extra PROPERTIES IMPORTED_LOCATION "${Libevent_LIBRARIES_EXTRA}")
    if(TARGET libevent::core)
      set_target_properties(libevent::extra PROPERTIES INTERFACE_LINK_LIBRARIES "libevent::core")
    endif()
  endif()

  if(Libevent_LIBRARIES_PTHREAD AND NOT TARGET libevent::pthreads)
    add_library(libevent::pthreads UNKNOWN IMPORTED)
    set_target_properties(libevent::pthreads PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libevent_INCLUDE_DIRS}")
    set_target_properties(libevent::pthreads PROPERTIES IMPORTED_LOCATION "${Libevent_LIBRARIES_PTHREAD}")
    if(TARGET libevent::core)
      set_target_properties(libevent::pthreads PROPERTIES INTERFACE_LINK_LIBRARIES "libevent::core")
    endif()
  endif()

  if(Libevent_LIBRARIES_OPENSSL AND NOT TARGET libevent::openssl)
    add_library(libevent::openssl UNKNOWN IMPORTED)
    set_target_properties(libevent::openssl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libevent_INCLUDE_DIRS}")
    set_target_properties(libevent::openssl PROPERTIES IMPORTED_LOCATION "${Libevent_LIBRARIES_OPENSSL}")

    if(TARGET libevent::core)
      list(APPEND Libevent_LIBRARIES_OPENSSL_LINK_LIBRARIES "libevent::core")
    endif()
    if(TARGET OpenSSL::SSL)
      list(APPEND Libevent_LIBRARIES_OPENSSL_LINK_LIBRARIES "OpenSSL::SSL")
    elseif(OPENSSL_LIBRARIES)
      list(APPEND Libevent_LIBRARIES_OPENSSL_LINK_LIBRARIES "${OPENSSL_LIBRARIES}")
    endif()
    if(Libevent_LIBRARIES_OPENSSL_LINK_LIBRARIES)
      set_target_properties(libevent::openssl PROPERTIES INTERFACE_LINK_LIBRARIES
                                                         "${Libevent_LIBRARIES_OPENSSL_LINK_LIBRARIES}")
    endif()
  endif()
endif()
