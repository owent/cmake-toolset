#.rst:
# FindLibnghttp2
# -----------
#
# Find Libnghttp2
#
# Find Libnghttp2 headers and library
#
# ::
#
#   Libnghttp2_FOUND                     - True if libnghttp2 is found.
#   Libnghttp2_INCLUDE_DIRS              - Directory where libnghttp2 headers are located.
#   Libnghttp2_LIBRARIES                 - libnghttp2 libraries to link against.
#   Libnghttp2_VERSION                   - version number as a string (ex: "1.51.0")
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   Libnghttp2::libnghttp2
#
# ::
#
# =============================================================================
# Copyright 2023 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

if(Libnghttp2_ROOT)
  set(LIBNGHTTP2_ROOT ${Libnghttp2_ROOT})
endif()

if(LIBNGHTTP2_ROOT)
  set(_LIBNGHTTP2_SEARCH_ROOT PATHS ${LIBNGHTTP2_ROOT} NO_DEFAULT_PATH)
  set(_LIBNGHTTP2_SEARCH_INCLUDE PATHS ${LIBNGHTTP2_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBNGHTTP2_SEARCH_LIB PATHS ${LIBNGHTTP2_ROOT}/lib64 ${LIBNGHTTP2_ROOT}/lib NO_DEFAULT_PATH)
endif()

find_package(PkgConfig)
if(PKG_CONFIG_FOUND)
  if(_LIBNGHTTP2_SEARCH_LIB AND EXISTS "${_LIBNGHTTP2_SEARCH_LIB}/pkgconfig")
    if("${_LIBNGHTTP2_SEARCH_LIB}/pkgconfig/libnghttp2.pc")
      pkg_check_modules(Libnghttp2 IMPORTED_TARGET GLOBAL "${_LIBNGHTTP2_SEARCH_LIB}/pkgconfig/libnghttp2.pc")
    endif()
  else()
    pkg_check_modules(Libnghttp2 IMPORTED_TARGET GLOBAL libnghttp2)
  endif()
  if(NOT Libnghttp2_FOUND AND Libnghttp2_STATIC_FOUND)
    set(Libnghttp2_FOUND ${Libnghttp2_STATIC_FOUND})
    set(Libnghttp2_INCLUDE_DIRS ${Libnghttp2_STATIC_INCLUDE_DIRS})
    set(Libnghttp2_LIBRARIES ${Libnghttp2_STATIC_LIBRARIES})
    set(Libnghttp2_LIBRARY_DIRS ${Libnghttp2_STATIC_LIBRARY_DIRS})
    set(Libnghttp2_LDFLAGS ${Libnghttp2_STATIC_LDFLAGS})
    set(Libnghttp2_CFLAGS ${Libnghttp2_STATIC_CFLAGS})
  endif()
  if(Libnghttp2_FOUND AND Libnghttp2_LIBRARY_DIRS)
    unset(_Libnghttp2_LIBRARYS_PKGCONFIG)
    foreach(_Libnghttp2_LIBRARY_PKGCONFIG ${Libnghttp2_LIBRARIES})
      if(IS_ABSOLUTE "${_Libnghttp2_LIBRARY_PKGCONFIG}")
        list(APPEND _Libnghttp2_LIBRARYS_PKGCONFIG "${_Libnghttp2_LIBRARY_PKGCONFIG}")
      else()
        unset(_Libnghttp2_LIBRARY_ABSOLUTE_PKGCONFIG)
        unset(_Libnghttp2_LIBRARY_ABSOLUTE_PKGCONFIG CACHE)
        find_library(
          _Libnghttp2_LIBRARY_ABSOLUTE_PKGCONFIG
          NAMES "${_Libnghttp2_LIBRARY_PKGCONFIG}"
          PATHS ${Libnghttp2_LIBRARY_DIRS}
          NO_DEFAULT_PATH)
        if(_Libnghttp2_LIBRARY_ABSOLUTE_PKGCONFIG)
          list(APPEND _Libnghttp2_LIBRARYS_PKGCONFIG "${_Libnghttp2_LIBRARY_ABSOLUTE_PKGCONFIG}")
        endif()
      endif()
    endforeach()
    set(Libnghttp2_LIBRARIES ${_Libnghttp2_LIBRARYS_PKGCONFIG})
    set(Libnghttp2_LIBRARIES
        ${_Libnghttp2_LIBRARYS_PKGCONFIG}
        CACHE INTERNAL "libnghttp2" FORCE)
    unset(_Libnghttp2_LIBRARYS_PKGCONFIG)
  endif()
endif()

if(NOT Libnghttp2_FOUND)
  find_path(Libnghttp2_INCLUDE_DIRS NAMES "nghttp2/nghttp2.h" ${_LIBNGHTTP2_SEARCH_INCLUDE})
  find_library(Libnghttp2_LIBRARY NAMES nghttp2 ${_LIBNGHTTP2_SEARCH_LIB})
  unset(_Libnghttp2_LIBRARIES)
  set(Libnghttp2_LIBRARIES
      ${Libnghttp2_LIBRARY}
      CACHE FILEPATH "Path of libnghttp2 libraries." FORCE)
  get_filename_component(Libnghttp2_LIBRARY_DIRS ${Libnghttp2_LIBRARY} DIRECTORY CACHE)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Libnghttp2 REQUIRED_VARS Libnghttp2_INCLUDE_DIRS Libnghttp2_LIBRARIES)
endif()

if(NOT Libnghttp2_VERSION
   AND Libnghttp2_INCLUDE_DIRS
   AND EXISTS "${Libnghttp2_INCLUDE_DIRS}/nghttp2/nghttp2ver.h")
  file(STRINGS "${Libnghttp2_INCLUDE_DIRS}/nghttp2/nghttp2ver.h" Libnghttp2_HEADER_CONTENTS
       REGEX "#define NGHTTP2_VERSION[ \t]*\"[0-9\\.]*\"")

  string(REGEX REPLACE ".*#define NGHTTP2_VERSION[ \t]*\"([0-9\\.]*)\"" "\\1" Libnghttp2_VERSION
                       "${Libnghttp2_HEADER_CONTENTS}")

  unset(Libnghttp2_HEADER_CONTENTS)
endif()

if(Libnghttp2_FOUND)
  if(NOT LIBNGHTTP2_FOUND)
    set(LIBNGHTTP2_FOUND ${Libnghttp2_FOUND})
  endif()
  set(LIBNGHTTP2_LIBRARIES ${Libnghttp2_LIBRARIES})
  set(LIBNGHTTP2_INCLUDE_DIRS ${Libnghttp2_INCLUDE_DIRS})

  if(NOT TARGET Libnghttp2::libnghttp2)
    if(TARGET PkgConfig::Libnghttp2)
      add_library(Libnghttp2::libnghttp2 ALIAS PkgConfig::Libnghttp2)
    else()
      if(Libnghttp2_LIBRARIES)
        add_library(Libnghttp2::libnghttp2 UNKNOWN IMPORTED)
      else()
        add_library(Libnghttp2::libnghttp2 INTERFACE IMPORTED)
      endif()
      set_target_properties(Libnghttp2::libnghttp2 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                                              "${Libnghttp2_INCLUDE_DIRS}")

      if(Libnghttp2_LIBRARIES)
        list(GET Libnghttp2_LIBRARIES 0 Libnghttp2_LIBRARIES_LOCATION)
        set_target_properties(Libnghttp2::libnghttp2 PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                                                                IMPORTED_LOCATION "${Libnghttp2_LIBRARIES_LOCATION}")
        list(LENGTH Libnghttp2_LIBRARIES Libnghttp2_LIBRARIES_LENGTH)
        if(Libnghttp2_LIBRARIES_LENGTH GREATER 1)
          set(Libnghttp2_LIBRARIES_LOCATION ${Libnghttp2_LIBRARIES})
          list(REMOVE_AT Libnghttp2_LIBRARIES_LOCATION 0)
          set_target_properties(Libnghttp2::libnghttp2 PROPERTIES INTERFACE_LINK_LIBRARIES
                                                                  "${Libnghttp2_LIBRARIES_LOCATION}")
        endif()
        unset(Libnghttp2_LIBRARIES_LOCATION)
        unset(Libnghttp2_LIBRARIES_LENGTH)
      endif()
      if(Libnghttp2_LDFLAGS)
        set_target_properties(Libnghttp2::libnghttp2 PROPERTIES INTERFACE_LINK_OPTIONS "${Libnghttp2_LDFLAGS}")
      endif()
      if(Libnghttp2_CFLAGS)
        set_target_properties(Libnghttp2::libnghttp2 PROPERTIES INTERFACE_COMPILE_OPTIONS "${Libnghttp2_CFLAGS}")
      endif()
    endif()
  endif()

  mark_as_advanced(
    LIBNGHTTP2_FOUND
    Libnghttp2_FOUND
    LIBNGHTTP2_INCLUDE_DIRS
    Libnghttp2_INCLUDE_DIRS
    LIBNGHTTP2_LIBRARIES
    Libnghttp2_LIBRARIES
    Libnghttp2_LIBRARY_DIRS
    Libnghttp2_VERSION)
else()
  unset(Libnghttp2_FOUND CACHE)
  unset(Libnghttp2_INCLUDE_DIRS CACHE)
  unset(Libnghttp2_LIBRARIES CACHE)
  unset(Libnghttp2_LIBRARY_DIRS CACHE)
  unset(Libnghttp2_VERSION CACHE)
  unset(Libnghttp2_LIBRARY CACHE)
  unset(Libnghttp2_FOUND)
  unset(Libnghttp2_INCLUDE_DIRS)
  unset(Libnghttp2_LIBRARIES)
  unset(Libnghttp2_LIBRARY_DIRS)
  unset(Libnghttp2_VERSION)
  unset(Libnghttp2_LIBRARY)
endif()
