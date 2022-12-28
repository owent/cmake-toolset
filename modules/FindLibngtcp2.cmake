#.rst:
# FindLibngtcp2
# -----------
#
# Find Libngtcp2
#
# Find Libngtcp2 headers and library
#
# ::
#
#   Libngtcp2_FOUND                     - True if libngtcp2 is found.
#   Libngtcp2_INCLUDE_DIRS              - Directory where libngtcp2 headers are located.
#   Libngtcp2_LIBRARIES                 - libngtcp2 libraries to link against.
#   Libngtcp2_VERSION                   - version number as a string (ex: "0.12.0")
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   Libngtcp2::libngtcp2
#
# ::
#
# =============================================================================
# Copyright 2023 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

if(Libngtcp2_ROOT)
  set(LIBNGTCP2_ROOT ${Libngtcp2_ROOT})
endif()

if(LIBNGTCP2_ROOT)
  set(_LIBNGTCP2_SEARCH_ROOT PATHS ${LIBNGTCP2_ROOT} NO_DEFAULT_PATH)
  set(_LIBNGTCP2_SEARCH_INCLUDE PATHS ${LIBNGTCP2_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBNGTCP2_SEARCH_LIB PATHS ${LIBNGTCP2_ROOT}/lib64 ${LIBNGTCP2_ROOT}/lib NO_DEFAULT_PATH)
endif()

find_package(PkgConfig)
if(PKG_CONFIG_FOUND)
  if(_LIBNGTCP2_SEARCH_LIB AND EXISTS "${_LIBNGTCP2_SEARCH_LIB}/pkgconfig")
    if("${_LIBNGTCP2_SEARCH_LIB}/pkgconfig/libngtcp2.pc")
      pkg_check_modules(Libngtcp2 IMPORTED_TARGET GLOBAL "${_LIBNGTCP2_SEARCH_LIB}/pkgconfig/libngtcp2.pc")
    endif()
  else()
    pkg_check_modules(Libngtcp2 IMPORTED_TARGET GLOBAL libngtcp2)
  endif()
  if(NOT Libngtcp2_FOUND AND Libngtcp2_STATIC_FOUND)
    set(Libngtcp2_FOUND ${Libngtcp2_STATIC_FOUND})
    set(Libngtcp2_INCLUDE_DIRS ${Libngtcp2_STATIC_INCLUDE_DIRS})
    set(Libngtcp2_LIBRARIES ${Libngtcp2_STATIC_LIBRARIES})
    set(Libngtcp2_LIBRARY_DIRS ${Libngtcp2_STATIC_LIBRARY_DIRS})
    set(Libngtcp2_LDFLAGS ${Libngtcp2_STATIC_LDFLAGS})
    set(Libngtcp2_CFLAGS ${Libngtcp2_STATIC_CFLAGS})
  endif()
  if(Libngtcp2_FOUND AND Libngtcp2_LIBRARY_DIRS)
    # Patch for libngtcp2.pc and FindLibngtcp2.cmake in other repositories(nghttp2 and etc.).
    if(EXISTS "${Libngtcp2_LIBRARY_DIRS}/libngtcp2_static.a" AND NOT EXISTS "${Libngtcp2_LIBRARY_DIRS}/libngtcp2.a")
      file(CREATE_LINK "${Libngtcp2_LIBRARY_DIRS}/libngtcp2_static.a" "${Libngtcp2_LIBRARY_DIRS}/libngtcp2.a"
           COPY_ON_ERROR)
    endif()
    if(EXISTS "${Libngtcp2_LIBRARY_DIRS}/ngtcp2_static.lib" AND NOT EXISTS "${Libngtcp2_LIBRARY_DIRS}/ngtcp2.lib")
      file(CREATE_LINK "${Libngtcp2_LIBRARY_DIRS}/ngtcp2_static.lib" "${Libngtcp2_LIBRARY_DIRS}/ngtcp2.lib"
           COPY_ON_ERROR)
    endif()

    unset(_Libngtcp2_LIBRARYS_PKGCONFIG)
    foreach(_Libngtcp2_LIBRARY_PKGCONFIG ${Libngtcp2_LIBRARIES})
      if(IS_ABSOLUTE "${_Libngtcp2_LIBRARY_PKGCONFIG}")
        list(APPEND _Libngtcp2_LIBRARYS_PKGCONFIG "${_Libngtcp2_LIBRARY_PKGCONFIG}")
      else()
        unset(_Libngtcp2_LIBRARY_ABSOLUTE_PKGCONFIG)
        unset(_Libngtcp2_LIBRARY_ABSOLUTE_PKGCONFIG CACHE)
        find_library(
          _Libngtcp2_LIBRARY_ABSOLUTE_PKGCONFIG
          NAMES "${_Libngtcp2_LIBRARY_PKGCONFIG}"
          PATHS ${Libngtcp2_LIBRARY_DIRS}
          NO_DEFAULT_PATH)
        if(_Libngtcp2_LIBRARY_ABSOLUTE_PKGCONFIG)
          list(APPEND _Libngtcp2_LIBRARYS_PKGCONFIG "${_Libngtcp2_LIBRARY_ABSOLUTE_PKGCONFIG}")
        endif()
      endif()
    endforeach()
    set(Libngtcp2_LIBRARIES ${_Libngtcp2_LIBRARYS_PKGCONFIG})
    set(Libngtcp2_LIBRARIES
        ${_Libngtcp2_LIBRARYS_PKGCONFIG}
        CACHE INTERNAL "libngtcp2" FORCE)
    unset(_Libngtcp2_LIBRARYS_PKGCONFIG)
  endif()
endif()

if(NOT Libngtcp2_FOUND)
  find_path(Libngtcp2_INCLUDE_DIRS NAMES "ngtcp2/ngtcp2.h" ${_LIBNGTCP2_SEARCH_INCLUDE})
  find_library(Libngtcp2_LIBRARY NAMES ngtcp2 ngtcp2_static ${_LIBNGTCP2_SEARCH_LIB})
  unset(_Libngtcp2_LIBRARIES)
  set(Libngtcp2_LIBRARIES
      ${Libngtcp2_LIBRARY}
      CACHE FILEPATH "Path of libngtcp2 libraries." FORCE)
  get_filename_component(Libngtcp2_LIBRARY_DIRS ${Libngtcp2_LIBRARY} DIRECTORY CACHE)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Libngtcp2 REQUIRED_VARS Libngtcp2_INCLUDE_DIRS Libngtcp2_LIBRARIES)
endif()

if(NOT Libngtcp2_VERSION
   AND Libngtcp2_INCLUDE_DIRS
   AND EXISTS "${Libngtcp2_INCLUDE_DIRS}/ngtcp2/version.h")
  file(STRINGS "${Libngtcp2_INCLUDE_DIRS}/ngtcp2/version.h" Libngtcp2_HEADER_CONTENTS
       REGEX "#define NGTCP2_VERSION[ \t]*\"[0-9\\.]*\"")

  string(REGEX REPLACE ".*#define NGTCP2_VERSION[ \t]*\"([0-9\\.]*)\"" "\\1" Libngtcp2_VERSION
                       "${Libngtcp2_HEADER_CONTENTS}")

  unset(Libngtcp2_HEADER_CONTENTS)
endif()

if(Libngtcp2_FOUND)
  if(NOT LIBNGTCP2_FOUND)
    set(LIBNGTCP2_FOUND ${Libngtcp2_FOUND})
  endif()
  set(LIBNGTCP2_LIBRARIES ${Libngtcp2_LIBRARIES})
  set(LIBNGTCP2_INCLUDE_DIRS ${Libngtcp2_INCLUDE_DIRS})

  if(NOT TARGET Libngtcp2::libngtcp2)
    if(TARGET PkgConfig::Libngtcp2)
      add_library(Libngtcp2::libngtcp2 ALIAS PkgConfig::Libngtcp2)
    else()
      if(Libngtcp2_LIBRARIES)
        add_library(Libngtcp2::libngtcp2 UNKNOWN IMPORTED)
      else()
        add_library(Libngtcp2::libngtcp2 INTERFACE IMPORTED)
      endif()
      set_target_properties(Libngtcp2::libngtcp2 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libngtcp2_INCLUDE_DIRS}")

      if(Libngtcp2_LIBRARIES)
        list(GET Libngtcp2_LIBRARIES 0 Libngtcp2_LIBRARIES_LOCATION)
        set_target_properties(Libngtcp2::libngtcp2 PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                                                              IMPORTED_LOCATION "${Libngtcp2_LIBRARIES_LOCATION}")
        list(LENGTH Libngtcp2_LIBRARIES Libngtcp2_LIBRARIES_LENGTH)
        if(Libngtcp2_LIBRARIES_LENGTH GREATER 1)
          set(Libngtcp2_LIBRARIES_LOCATION ${Libngtcp2_LIBRARIES})
          list(REMOVE_AT Libngtcp2_LIBRARIES_LOCATION 0)
          set_target_properties(Libngtcp2::libngtcp2 PROPERTIES INTERFACE_LINK_LIBRARIES
                                                                "${Libngtcp2_LIBRARIES_LOCATION}")
        endif()
        unset(Libngtcp2_LIBRARIES_LOCATION)
        unset(Libngtcp2_LIBRARIES_LENGTH)
      endif()
      if(Libngtcp2_LDFLAGS)
        set_target_properties(Libngtcp2::libngtcp2 PROPERTIES INTERFACE_LINK_OPTIONS "${Libngtcp2_LDFLAGS}")
      endif()
      if(Libngtcp2_CFLAGS)
        set_target_properties(Libngtcp2::libngtcp2 PROPERTIES INTERFACE_COMPILE_OPTIONS "${Libngtcp2_CFLAGS}")
      endif()
    endif()
  endif()

  mark_as_advanced(
    LIBNGTCP2_FOUND
    Libngtcp2_FOUND
    LIBNGTCP2_INCLUDE_DIRS
    Libngtcp2_INCLUDE_DIRS
    LIBNGTCP2_LIBRARIES
    Libngtcp2_LIBRARIES
    Libngtcp2_LIBRARY_DIRS
    Libngtcp2_VERSION)
else()
  unset(Libngtcp2_FOUND CACHE)
  unset(Libngtcp2_INCLUDE_DIRS CACHE)
  unset(Libngtcp2_LIBRARIES CACHE)
  unset(Libngtcp2_LIBRARY_DIRS CACHE)
  unset(Libngtcp2_VERSION CACHE)
  unset(Libngtcp2_LIBRARY CACHE)
  unset(Libngtcp2_FOUND)
  unset(Libngtcp2_INCLUDE_DIRS)
  unset(Libngtcp2_LIBRARIES)
  unset(Libngtcp2_LIBRARY_DIRS)
  unset(Libngtcp2_VERSION)
  unset(Libngtcp2_LIBRARY)
endif()
