#.rst:
# FindLibnghttp3
# -----------
#
# Find Libnghttp3
#
# Find Libnghttp3 headers and library
#
# ::
#
#   Libnghttp3_FOUND                     - True if libnghttp3 is found.
#   Libnghttp3_INCLUDE_DIRS              - Directory where libnghttp3 headers are located.
#   Libnghttp3_LIBRARIES                 - libnghttp3 libraries to link against.
#   Libnghttp3_VERSION                   - version number as a string (ex: "0.8.0")
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   Libnghttp3::libnghttp3
#
# ::
#
# =============================================================================
# Copyright 2023 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

if(Libnghttp3_ROOT)
  set(LIBNGHTTP3_ROOT ${Libnghttp3_ROOT})
endif()

if(LIBNGHTTP3_ROOT)
  set(_LIBNGHTTP3_SEARCH_ROOT PATHS ${LIBNGHTTP3_ROOT} NO_DEFAULT_PATH)
  set(_LIBNGHTTP3_SEARCH_INCLUDE PATHS ${LIBNGHTTP3_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBNGHTTP3_SEARCH_LIB PATHS ${LIBNGHTTP3_ROOT}/lib64 ${LIBNGHTTP3_ROOT}/lib NO_DEFAULT_PATH)
endif()

find_path(Libnghttp3_INCLUDE_DIRS NAMES "nghttp3/nghttp3.h" ${_LIBNGHTTP3_SEARCH_INCLUDE})
find_library(Libnghttp3_LIBRARY NAMES nghttp3 ${_LIBNGHTTP3_SEARCH_LIB})
unset(_Libnghttp3_LIBRARIES)
set(Libnghttp3_LIBRARIES
    ${Libnghttp3_LIBRARY}
    CACHE FILEPATH "Path of libnghttp3 libraries." FORCE)
get_filename_component(Libnghttp3_LIBRARY_DIRS ${Libnghttp3_LIBRARY} DIRECTORY CACHE)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Libnghttp3 REQUIRED_VARS Libnghttp3_INCLUDE_DIRS Libnghttp3_LIBRARIES)

if(NOT Libnghttp3_VERSION
   AND Libnghttp3_INCLUDE_DIRS
   AND EXISTS "${Libnghttp3_INCLUDE_DIRS}/nghttp3/version.h")
  file(STRINGS "${Libnghttp3_INCLUDE_DIRS}/nghttp3/version.h" Libnghttp3_HEADER_CONTENTS
       REGEX "#define NGHTTP3_VERSION[ \t]*\"[0-9\\.]*\"")

  string(REGEX REPLACE ".*#define NGHTTP3_VERSION[ \t]*\"([0-9\\.]*)\"" "\\1" Libnghttp3_VERSION
                       "${Libnghttp3_HEADER_CONTENTS}")

  unset(Libnghttp3_HEADER_CONTENTS)
endif()

if(Libnghttp3_FOUND)
  if(NOT LIBNGHTTP3_FOUND)
    set(LIBNGHTTP3_FOUND ${Libnghttp3_FOUND})
  endif()
  set(LIBNGHTTP3_LIBRARIES ${Libnghttp3_LIBRARIES})
  set(LIBNGHTTP3_INCLUDE_DIRS ${Libnghttp3_INCLUDE_DIRS})

  if(NOT TARGET Libnghttp3::libnghttp3)
    if(TARGET PkgConfig::Libnghttp3)
      add_library(Libnghttp3::libnghttp3 ALIAS PkgConfig::Libnghttp3)
    else()
      if(Libnghttp3_LIBRARIES)
        add_library(Libnghttp3::libnghttp3 UNKNOWN IMPORTED)
      else()
        add_library(Libnghttp3::libnghttp3 INTERFACE IMPORTED)
      endif()
      set_target_properties(Libnghttp3::libnghttp3 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                                              "${Libnghttp3_INCLUDE_DIRS}")

      if(Libnghttp3_LIBRARIES)
        list(GET Libnghttp3_LIBRARIES 0 Libnghttp3_LIBRARIES_LOCATION)
        set_target_properties(Libnghttp3::libnghttp3 PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                                                                IMPORTED_LOCATION "${Libnghttp3_LIBRARIES_LOCATION}")
        list(LENGTH Libnghttp3_LIBRARIES Libnghttp3_LIBRARIES_LENGTH)
        if(Libnghttp3_LIBRARIES_LENGTH GREATER 1)
          set(Libnghttp3_LIBRARIES_LOCATION ${Libnghttp3_LIBRARIES})
          list(REMOVE_AT Libnghttp3_LIBRARIES_LOCATION 0)
          set_target_properties(Libnghttp3::libnghttp3 PROPERTIES INTERFACE_LINK_LIBRARIES
                                                                  "${Libnghttp3_LIBRARIES_LOCATION}")
        endif()
        unset(Libnghttp3_LIBRARIES_LOCATION)
        unset(Libnghttp3_LIBRARIES_LENGTH)
      endif()
      if(Libnghttp3_LDFLAGS)
        set_target_properties(Libnghttp3::libnghttp3 PROPERTIES INTERFACE_LINK_OPTIONS "${Libnghttp3_LDFLAGS}")
      endif()
      if(Libnghttp3_CFLAGS)
        set_target_properties(Libnghttp3::libnghttp3 PROPERTIES INTERFACE_COMPILE_OPTIONS "${Libnghttp3_CFLAGS}")
      endif()
    endif()
  endif()

  mark_as_advanced(
    LIBNGHTTP3_FOUND
    Libnghttp3_FOUND
    LIBNGHTTP3_INCLUDE_DIRS
    Libnghttp3_INCLUDE_DIRS
    LIBNGHTTP3_LIBRARIES
    Libnghttp3_LIBRARIES
    Libnghttp3_LIBRARY_DIRS
    Libnghttp3_VERSION)
else()
  unset(Libnghttp3_FOUND CACHE)
  unset(Libnghttp3_INCLUDE_DIRS CACHE)
  unset(Libnghttp3_LIBRARIES CACHE)
  unset(Libnghttp3_LIBRARY_DIRS CACHE)
  unset(Libnghttp3_VERSION CACHE)
  unset(Libnghttp3_LIBRARY CACHE)
  unset(Libnghttp3_FOUND)
  unset(Libnghttp3_INCLUDE_DIRS)
  unset(Libnghttp3_LIBRARIES)
  unset(Libnghttp3_LIBRARY_DIRS)
  unset(Libnghttp3_VERSION)
  unset(Libnghttp3_LIBRARY)
endif()
