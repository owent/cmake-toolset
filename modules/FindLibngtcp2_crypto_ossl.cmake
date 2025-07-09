#.rst:
# FindLibngtcp2_crypto_ossl
# -----------
#
# Find Libngtcp2_crypto_ossl
#
# Find Libngtcp2_crypto_ossl headers and library
#
# ::
#
#   Libngtcp2_crypto_ossl_FOUND                     - True if libngtcp2_crypto_ossl is found.
#   Libngtcp2_crypto_ossl_INCLUDE_DIRS              - Directory where libngtcp2_crypto_ossl headers are located.
#   Libngtcp2_crypto_ossl_LIBRARIES                 - libngtcp2_crypto_ossl libraries to link against.
#   Libngtcp2_crypto_ossl_VERSION                   - version number as a string (ex: "0.12.0")
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   Libngtcp2::libngtcp2_crypto_ossl
#
# ::
#
# =============================================================================
# Copyright 2025 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

if(Libngtcp2_crypto_ossl_ROOT)
  set(LIBNGTCP2_CRYPTO_OSSL_ROOT ${Libngtcp2_crypto_ossl_ROOT})
endif()

if(LIBNGTCP2_CRYPTO_OSSL_ROOT)
  set(_LIBNGTCP2_CRYPTO_OSSL_SEARCH_ROOT PATHS ${LIBNGTCP2_CRYPTO_OSSL_ROOT} NO_DEFAULT_PATH)
  set(_LIBNGTCP2_CRYPTO_OSSL_SEARCH_INCLUDE PATHS ${LIBNGTCP2_CRYPTO_OSSL_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBNGTCP2_CRYPTO_OSSL_SEARCH_LIB PATHS ${LIBNGTCP2_CRYPTO_OSSL_ROOT}/lib64 ${LIBNGTCP2_CRYPTO_OSSL_ROOT}/lib
                                        NO_DEFAULT_PATH)
endif()

find_path(Libngtcp2_crypto_ossl_INCLUDE_DIRS NAMES "ngtcp2/ngtcp2_crypto_ossl.h"
                                                   ${_LIBNGTCP2_CRYPTO_OSSL_SEARCH_INCLUDE})
find_library(Libngtcp2_crypto_ossl_LIBRARY NAMES ngtcp2_crypto_ossl ngtcp2_crypto_ossl_static
                                                 ${_LIBNGTCP2_CRYPTO_OSSL_SEARCH_LIB})
unset(_Libngtcp2_crypto_ossl_LIBRARIES)
set(Libngtcp2_crypto_ossl_LIBRARIES
    ${Libngtcp2_crypto_ossl_LIBRARY}
    CACHE FILEPATH "Path of libngtcp2_crypto_ossl libraries." FORCE)
get_filename_component(Libngtcp2_crypto_ossl_LIBRARY_DIRS ${Libngtcp2_crypto_ossl_LIBRARY} DIRECTORY CACHE)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Libngtcp2_crypto_ossl REQUIRED_VARS Libngtcp2_crypto_ossl_INCLUDE_DIRS
                                                                      Libngtcp2_crypto_ossl_LIBRARIES)

if(NOT Libngtcp2_crypto_ossl_VERSION
   AND Libngtcp2_crypto_ossl_INCLUDE_DIRS
   AND EXISTS "${Libngtcp2_crypto_ossl_INCLUDE_DIRS}/ngtcp2/version.h")
  file(STRINGS "${Libngtcp2_crypto_ossl_INCLUDE_DIRS}/ngtcp2/version.h" Libngtcp2_crypto_ossl_HEADER_CONTENTS
       REGEX "#define NGTCP2_VERSION[ \t]*\"[0-9\\.]*\"")

  string(REGEX REPLACE ".*#define NGTCP2_VERSION[ \t]*\"([0-9\\.]*)\"" "\\1" Libngtcp2_crypto_ossl_VERSION
                       "${Libngtcp2_crypto_ossl_HEADER_CONTENTS}")

  unset(Libngtcp2_crypto_ossl_HEADER_CONTENTS)
endif()

if(Libngtcp2_crypto_ossl_FOUND)
  # Patch for libngtcp2_crypto_ossl.pc and FindLibngtcp2_crypto_ossl.cmake in other repositories(nghttp2 and etc.).
  if(EXISTS "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/libngtcp2_crypto_ossl_static.a"
     AND NOT EXISTS "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/libngtcp2_crypto_ossl.a")
    file(CREATE_LINK "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/libngtcp2_crypto_ossl_static.a"
         "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/libngtcp2_crypto_ossl.a" COPY_ON_ERROR)
  endif()
  if(EXISTS "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/ngtcp2_crypto_ossl_static.lib"
     AND NOT EXISTS "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/ngtcp2_crypto_ossl.lib")
    file(CREATE_LINK "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/ngtcp2_crypto_ossl_static.lib"
         "${Libngtcp2_crypto_ossl_LIBRARY_DIRS}/ngtcp2_crypto_ossl.lib" COPY_ON_ERROR)
  endif()

  if(NOT LIBNGTCP2_CRYPTO_OSSL_FOUND)
    set(LIBNGTCP2_CRYPTO_OSSL_FOUND ${Libngtcp2_crypto_ossl_FOUND})
  endif()
  set(LIBNGTCP2_CRYPTO_OSSL_LIBRARIES ${Libngtcp2_crypto_ossl_LIBRARIES})
  set(LIBNGTCP2_CRYPTO_OSSL_INCLUDE_DIRS ${Libngtcp2_crypto_ossl_INCLUDE_DIRS})

  if(NOT TARGET Libngtcp2::libngtcp2_crypto_ossl)
    if(TARGET PkgConfig::Libngtcp2_crypto_ossl)
      add_library(Libngtcp2::libngtcp2_crypto_ossl ALIAS PkgConfig::Libngtcp2_crypto_ossl)
    else()
      include(CMakeFindDependencyMacro)
      find_dependency(OpenSSL REQUIRED)
      if(TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto)
        set(__openssl_link_names)
        if(TARGET OpenSSL::SSL)
          list(APPEND __openssl_link_names OpenSSL::SSL)
        endif()
        if(TARGET OpenSSL::Crypto)
          list(APPEND __openssl_link_names OpenSSL::Crypto)
        endif()
      else()
        set(__openssl_link_names "${OPENSSL_LIBRARIES}")
      endif()
      if(Libngtcp2_crypto_ossl_LIBRARIES)
        add_library(Libngtcp2::libngtcp2_crypto_ossl UNKNOWN IMPORTED)
      else()
        add_library(Libngtcp2::libngtcp2_crypto_ossl INTERFACE IMPORTED)
      endif()
      set_target_properties(Libngtcp2::libngtcp2_crypto_ossl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                                                        "${Libngtcp2_crypto_ossl_INCLUDE_DIRS}")

      if(Libngtcp2_crypto_ossl_LIBRARIES)
        list(GET Libngtcp2_crypto_ossl_LIBRARIES 0 Libngtcp2_crypto_ossl_LIBRARIES_LOCATION)
        set_target_properties(
          Libngtcp2::libngtcp2_crypto_ossl PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                                                      IMPORTED_LOCATION "${Libngtcp2_crypto_ossl_LIBRARIES_LOCATION}")
        list(LENGTH Libngtcp2_crypto_ossl_LIBRARIES Libngtcp2_crypto_ossl_LIBRARIES_LENGTH)
        if(Libngtcp2_crypto_ossl_LIBRARIES_LENGTH GREATER 1)
          set(Libngtcp2_crypto_ossl_LIBRARIES_LOCATION ${Libngtcp2_crypto_ossl_LIBRARIES})
          list(REMOVE_AT Libngtcp2_crypto_ossl_LIBRARIES_LOCATION 0)
          set_target_properties(
            Libngtcp2::libngtcp2_crypto_ossl
            PROPERTIES INTERFACE_LINK_LIBRARIES "${Libngtcp2_crypto_ossl_LIBRARIES_LOCATION};${__openssl_link_names}")
        else()
          set_target_properties(Libngtcp2::libngtcp2_crypto_ossl PROPERTIES INTERFACE_LINK_LIBRARIES
                                                                            "${__openssl_link_names}")
        endif()
        unset(Libngtcp2_crypto_ossl_LIBRARIES_LOCATION)
        unset(Libngtcp2_crypto_ossl_LIBRARIES_LENGTH)
      endif()
      if(Libngtcp2_crypto_ossl_LDFLAGS)
        set_target_properties(Libngtcp2::libngtcp2_crypto_ossl PROPERTIES INTERFACE_LINK_OPTIONS
                                                                          "${Libngtcp2_crypto_ossl_LDFLAGS}")
      endif()
      if(Libngtcp2_crypto_ossl_CFLAGS)
        set_target_properties(Libngtcp2::libngtcp2_crypto_ossl PROPERTIES INTERFACE_COMPILE_OPTIONS
                                                                          "${Libngtcp2_crypto_ossl_CFLAGS}")
      endif()
    endif()
  endif()

  mark_as_advanced(
    LIBNGTCP2_CRYPTO_QUICTLS_FOUND
    Libngtcp2_crypto_ossl_FOUND
    LIBNGTCP2_CRYPTO_QUICTLS_INCLUDE_DIRS
    Libngtcp2_crypto_ossl_INCLUDE_DIRS
    LIBNGTCP2_CRYPTO_QUICTLS_LIBRARIES
    Libngtcp2_crypto_ossl_LIBRARIES
    Libngtcp2_crypto_ossl_LIBRARY_DIRS
    Libngtcp2_crypto_ossl_VERSION)
else()
  unset(Libngtcp2_crypto_ossl_FOUND CACHE)
  unset(Libngtcp2_crypto_ossl_INCLUDE_DIRS CACHE)
  unset(Libngtcp2_crypto_ossl_LIBRARIES CACHE)
  unset(Libngtcp2_crypto_ossl_LIBRARY_DIRS CACHE)
  unset(Libngtcp2_crypto_ossl_VERSION CACHE)
  unset(Libngtcp2_crypto_ossl_LIBRARY CACHE)
  unset(Libngtcp2_crypto_ossl_FOUND)
  unset(Libngtcp2_crypto_ossl_INCLUDE_DIRS)
  unset(Libngtcp2_crypto_ossl_LIBRARIES)
  unset(Libngtcp2_crypto_ossl_LIBRARY_DIRS)
  unset(Libngtcp2_crypto_ossl_VERSION)
  unset(Libngtcp2_crypto_ossl_LIBRARY)
endif()
