#.rst:
# FindLibngtcp2_crypto_openssl
# -----------
#
# Find Libngtcp2_crypto_openssl
#
# Find Libngtcp2_crypto_openssl headers and library
#
# ::
#
#   Libngtcp2_crypto_openssl_FOUND                     - True if libngtcp2_crypto_openssl is found.
#   Libngtcp2_crypto_openssl_INCLUDE_DIRS              - Directory where libngtcp2_crypto_openssl headers are located.
#   Libngtcp2_crypto_openssl_LIBRARIES                 - libngtcp2_crypto_openssl libraries to link against.
#   Libngtcp2_crypto_openssl_VERSION                   - version number as a string (ex: "0.12.0")
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   Libngtcp2::libngtcp2_crypto_openssl
#
# ::
#
# =============================================================================
# Copyright 2023 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

if(Libngtcp2_crypto_openssl_ROOT)
  set(LIBNGTCP2_CRYPTO_OPENSSL_ROOT ${Libngtcp2_crypto_openssl_ROOT})
endif()

if(LIBNGTCP2_CRYPTO_OPENSSL_ROOT)
  set(_LIBNGTCP2_CRYPTO_OPENSSL_SEARCH_ROOT PATHS ${LIBNGTCP2_CRYPTO_OPENSSL_ROOT} NO_DEFAULT_PATH)
  set(_LIBNGTCP2_CRYPTO_OPENSSL_SEARCH_INCLUDE PATHS ${LIBNGTCP2_CRYPTO_OPENSSL_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBNGTCP2_CRYPTO_OPENSSL_SEARCH_LIB PATHS ${LIBNGTCP2_CRYPTO_OPENSSL_ROOT}/lib64
                                           ${LIBNGTCP2_CRYPTO_OPENSSL_ROOT}/lib NO_DEFAULT_PATH)
endif()

find_path(Libngtcp2_crypto_openssl_INCLUDE_DIRS NAMES "ngtcp2/ngtcp2_crypto.h"
                                                      ${_LIBNGTCP2_CRYPTO_OPENSSL_SEARCH_INCLUDE})
find_library(Libngtcp2_crypto_openssl_LIBRARY NAMES ngtcp2_crypto_openssl ngtcp2_crypto_openssl_static
                                                    ${_LIBNGTCP2_CRYPTO_OPENSSL_SEARCH_LIB})
unset(_Libngtcp2_crypto_openssl_LIBRARIES)
set(Libngtcp2_crypto_openssl_LIBRARIES
    ${Libngtcp2_crypto_openssl_LIBRARY}
    CACHE FILEPATH "Path of libngtcp2_crypto_openssl libraries." FORCE)
get_filename_component(Libngtcp2_crypto_openssl_LIBRARY_DIRS ${Libngtcp2_crypto_openssl_LIBRARY} DIRECTORY CACHE)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Libngtcp2_crypto_openssl REQUIRED_VARS Libngtcp2_crypto_openssl_INCLUDE_DIRS
                                                                         Libngtcp2_crypto_openssl_LIBRARIES)

if(NOT Libngtcp2_crypto_openssl_VERSION
   AND Libngtcp2_crypto_openssl_INCLUDE_DIRS
   AND EXISTS "${Libngtcp2_crypto_openssl_INCLUDE_DIRS}/ngtcp2/version.h")
  file(STRINGS "${Libngtcp2_crypto_openssl_INCLUDE_DIRS}/ngtcp2/version.h" Libngtcp2_crypto_openssl_HEADER_CONTENTS
       REGEX "#define NGTCP2_VERSION[ \t]*\"[0-9\\.]*\"")

  string(REGEX REPLACE ".*#define NGTCP2_VERSION[ \t]*\"([0-9\\.]*)\"" "\\1" Libngtcp2_crypto_openssl_VERSION
                       "${Libngtcp2_crypto_openssl_HEADER_CONTENTS}")

  unset(Libngtcp2_crypto_openssl_HEADER_CONTENTS)
endif()

if(Libngtcp2_crypto_openssl_FOUND)
  # Patch for libngtcp2_crypto_openssl.pc and FindLibngtcp2_crypto_openssl.cmake in other repositories(nghttp2 and
  # etc.).
  if(EXISTS "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/libngtcp2_crypto_openssl_static.a"
     AND NOT EXISTS "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/libngtcp2_crypto_openssl.a")
    file(CREATE_LINK "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/libngtcp2_crypto_openssl_static.a"
         "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/libngtcp2_crypto_openssl.a" COPY_ON_ERROR)
  endif()
  if(EXISTS "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/ngtcp2_crypto_openssl_static.lib"
     AND NOT EXISTS "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/ngtcp2_crypto_openssl.lib")
    file(CREATE_LINK "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/ngtcp2_crypto_openssl_static.lib"
         "${Libngtcp2_crypto_openssl_LIBRARY_DIRS}/ngtcp2_crypto_openssl.lib" COPY_ON_ERROR)
  endif()

  if(NOT LIBNGTCP2_CRYPTO_OPENSSL_FOUND)
    set(LIBNGTCP2_CRYPTO_OPENSSL_FOUND ${Libngtcp2_crypto_openssl_FOUND})
  endif()
  set(LIBNGTCP2_CRYPTO_OPENSSL_LIBRARIES ${Libngtcp2_crypto_openssl_LIBRARIES})
  set(LIBNGTCP2_CRYPTO_OPENSSL_INCLUDE_DIRS ${Libngtcp2_crypto_openssl_INCLUDE_DIRS})

  if(NOT TARGET Libngtcp2::libngtcp2_crypto_openssl)
    if(TARGET PkgConfig::Libngtcp2_crypto_openssl)
      add_library(Libngtcp2::libngtcp2_crypto_openssl ALIAS PkgConfig::Libngtcp2_crypto_openssl)
    else()
      if(Libngtcp2_crypto_openssl_LIBRARIES)
        add_library(Libngtcp2::libngtcp2_crypto_openssl UNKNOWN IMPORTED)
      else()
        add_library(Libngtcp2::libngtcp2_crypto_openssl INTERFACE IMPORTED)
      endif()
      set_target_properties(Libngtcp2::libngtcp2_crypto_openssl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                                                           "${Libngtcp2_crypto_openssl_INCLUDE_DIRS}")

      if(Libngtcp2_crypto_openssl_LIBRARIES)
        list(GET Libngtcp2_crypto_openssl_LIBRARIES 0 Libngtcp2_crypto_openssl_LIBRARIES_LOCATION)
        set_target_properties(
          Libngtcp2::libngtcp2_crypto_openssl
          PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX" IMPORTED_LOCATION
                                                               "${Libngtcp2_crypto_openssl_LIBRARIES_LOCATION}")
        list(LENGTH Libngtcp2_crypto_openssl_LIBRARIES Libngtcp2_crypto_openssl_LIBRARIES_LENGTH)
        if(Libngtcp2_crypto_openssl_LIBRARIES_LENGTH GREATER 1)
          set(Libngtcp2_crypto_openssl_LIBRARIES_LOCATION ${Libngtcp2_crypto_openssl_LIBRARIES})
          list(REMOVE_AT Libngtcp2_crypto_openssl_LIBRARIES_LOCATION 0)
          set_target_properties(Libngtcp2::libngtcp2_crypto_openssl
                                PROPERTIES INTERFACE_LINK_LIBRARIES "${Libngtcp2_crypto_openssl_LIBRARIES_LOCATION}")
        endif()
        unset(Libngtcp2_crypto_openssl_LIBRARIES_LOCATION)
        unset(Libngtcp2_crypto_openssl_LIBRARIES_LENGTH)
      endif()
      if(Libngtcp2_crypto_openssl_LDFLAGS)
        set_target_properties(Libngtcp2::libngtcp2_crypto_openssl PROPERTIES INTERFACE_LINK_OPTIONS
                                                                             "${Libngtcp2_crypto_openssl_LDFLAGS}")
      endif()
      if(Libngtcp2_crypto_openssl_CFLAGS)
        set_target_properties(Libngtcp2::libngtcp2_crypto_openssl PROPERTIES INTERFACE_COMPILE_OPTIONS
                                                                             "${Libngtcp2_crypto_openssl_CFLAGS}")
      endif()
    endif()
  endif()

  mark_as_advanced(
    LIBNGTCP2_CRYPTO_OPENSSL_FOUND
    Libngtcp2_crypto_openssl_FOUND
    LIBNGTCP2_CRYPTO_OPENSSL_INCLUDE_DIRS
    Libngtcp2_crypto_openssl_INCLUDE_DIRS
    LIBNGTCP2_CRYPTO_OPENSSL_LIBRARIES
    Libngtcp2_crypto_openssl_LIBRARIES
    Libngtcp2_crypto_openssl_LIBRARY_DIRS
    Libngtcp2_crypto_openssl_VERSION)
else()
  unset(Libngtcp2_crypto_openssl_FOUND CACHE)
  unset(Libngtcp2_crypto_openssl_INCLUDE_DIRS CACHE)
  unset(Libngtcp2_crypto_openssl_LIBRARIES CACHE)
  unset(Libngtcp2_crypto_openssl_LIBRARY_DIRS CACHE)
  unset(Libngtcp2_crypto_openssl_VERSION CACHE)
  unset(Libngtcp2_crypto_openssl_LIBRARY CACHE)
  unset(Libngtcp2_crypto_openssl_FOUND)
  unset(Libngtcp2_crypto_openssl_INCLUDE_DIRS)
  unset(Libngtcp2_crypto_openssl_LIBRARIES)
  unset(Libngtcp2_crypto_openssl_LIBRARY_DIRS)
  unset(Libngtcp2_crypto_openssl_VERSION)
  unset(Libngtcp2_crypto_openssl_LIBRARY)
endif()
