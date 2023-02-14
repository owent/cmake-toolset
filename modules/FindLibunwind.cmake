#.rst:
# FindLibUnwind
# -----------
#
# Find LibUnwind
#
# Find LibUnwind headers and library
#
# ::
#
#   Libunwind_FOUND                     - True if libunwind is found.
#   Libunwind_INCLUDE_DIRS              - Directory where libunwind headers are located.
#   Libunwind_LIBRARIES                 - Unwind libraries to link against.
#   Libunwind_HAS_UNW_GETCONTEXT        - True if unw_getcontext() is found (optional).
#   Libunwind_HAS_UNW_INIT_LOCAL        - True if unw_init_local() is found (optional).
#   Libunwind_VERSION_STRING            - version number as a string (ex: "5.0.3")
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
# ::
#
#   Libunwind::libunwind
#
# ::
#
# =============================================================================
# Copyright 2021 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE
# for details.

if(Libunwind_ROOT)
  set(LIBUNWIND_ROOT ${Libunwind_ROOT})
endif()

if(LIBUNWIND_ROOT)
  set(_LIBUNWIND_SEARCH_ROOT PATHS ${LIBUNWIND_ROOT} NO_DEFAULT_PATH)
  set(_LIBUNWIND_SEARCH_INCLUDE PATHS ${LIBUNWIND_ROOT}/include NO_DEFAULT_PATH)
  set(_LIBUNWIND_SEARCH_LIB PATHS ${LIBUNWIND_ROOT}/lib NO_DEFAULT_PATH)
endif()

find_package(PkgConfig)
if(PKG_CONFIG_FOUND)
  if(_LIBUNWIND_SEARCH_LIB AND EXISTS "${_LIBUNWIND_SEARCH_LIB}/pkgconfig")
    if("${_LIBUNWIND_SEARCH_LIB}/pkgconfig/libunwind-generic.pc")
      pkg_check_modules(Libunwind IMPORTED_TARGET GLOBAL "${_LIBUNWIND_SEARCH_LIB}/pkgconfig/libunwind-generic.pc")
    elseif("${_LIBUNWIND_SEARCH_LIB}/pkgconfig/libunwind.pc")
      pkg_check_modules(Libunwind IMPORTED_TARGET GLOBAL "${_LIBUNWIND_SEARCH_LIB}/pkgconfig/libunwind.pc")
    endif()
  else()
    pkg_check_modules(Libunwind IMPORTED_TARGET GLOBAL libunwind-generic)
    if(NOT Libunwind_FOUND AND NOT Libunwind_STATIC_FOUND)
      pkg_check_modules(Libunwind IMPORTED_TARGET GLOBAL libunwind)
    endif()
  endif()
  if(NOT Libunwind_FOUND AND Libunwind_STATIC_FOUND)
    set(Libunwind_FOUND ${Libunwind_STATIC_FOUND})
    set(Libunwind_INCLUDE_DIRS ${Libunwind_STATIC_INCLUDE_DIRS})
    set(Libunwind_LIBRARIES ${Libunwind_STATIC_LIBRARIES})
    set(Libunwind_LIBRARY_DIRS ${Libunwind_STATIC_LIBRARY_DIRS})
    set(Libunwind_LDFLAGS ${Libunwind_STATIC_LDFLAGS})
    set(Libunwind_CFLAGS ${Libunwind_STATIC_CFLAGS})
  endif()
  if(Libunwind_FOUND AND Libunwind_LIBRARY_DIRS)
    unset(_Libunwind_LIBRARYS_PKGCONFIG)
    foreach(_Libunwind_LIBRARY_PKGCONFIG ${Libunwind_LIBRARIES})
      if(IS_ABSOLUTE "${_Libunwind_LIBRARY_PKGCONFIG}")
        list(APPEND _Libunwind_LIBRARYS_PKGCONFIG "${_Libunwind_LIBRARY_PKGCONFIG}")
      else()
        unset(_Libunwind_LIBRARY_ABSOLUTE_PKGCONFIG)
        unset(_Libunwind_LIBRARY_ABSOLUTE_PKGCONFIG CACHE)
        find_library(
          _Libunwind_LIBRARY_ABSOLUTE_PKGCONFIG
          NAMES "${_Libunwind_LIBRARY_PKGCONFIG}"
          PATHS ${Libunwind_LIBRARY_DIRS}
          NO_DEFAULT_PATH)
        if(_Libunwind_LIBRARY_ABSOLUTE_PKGCONFIG)
          list(APPEND _Libunwind_LIBRARYS_PKGCONFIG "${_Libunwind_LIBRARY_ABSOLUTE_PKGCONFIG}")
        endif()
      endif()
    endforeach()
    set(Libunwind_LIBRARIES ${_Libunwind_LIBRARYS_PKGCONFIG})
    set(Libunwind_LIBRARIES
        ${_Libunwind_LIBRARYS_PKGCONFIG}
        CACHE INTERNAL "unwind" FORCE)
    unset(_Libunwind_LIBRARYS_PKGCONFIG)
  endif()
endif()

if(NOT Libunwind_FOUND)
  find_path(Libunwind_INCLUDE_DIRS NAMES libunwind.h ${_LIBUNWIND_SEARCH_INCLUDE})
  if(Libunwind_INCLUDE_DIRS AND NOT EXISTS "${Libunwind_INCLUDE_DIRS}/unwind.h")
    message("Found libunwind.h but corresponding unwind.h is absent on ${Libunwind_INCLUDE_DIRS}!")
    unset(Libunwind_INCLUDE_DIRS CACHE)
    unset(Libunwind_INCLUDE_DIRS)
  endif()

  find_library(Libunwind_LIBRARY NAMES unwind ${_LIBUNWIND_SEARCH_LIB})
  find_library(Libunwind_LIBRARY_EXTRA NAMES unwind-${CMAKE_SYSTEM_PROCESSOR} ${_LIBUNWIND_SEARCH_LIB})
  if(NOT Libunwind_LIBRARY_EXTRA AND ${CMAKE_SYSTEM_PROCESSOR} EQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
    find_library(Libunwind_LIBRARY_EXTRA NAMES unwind-generic ${_LIBUNWIND_SEARCH_LIB})
  endif()
  unset(_Libunwind_LIBRARIES)
  if(Libunwind_LIBRARY_EXTRA)
    list(APPEND _Libunwind_LIBRARIES ${Libunwind_LIBRARY_EXTRA})
  endif()
  if(Libunwind_LIBRARY)
    list(APPEND _Libunwind_LIBRARIES ${Libunwind_LIBRARY})
  endif()
  set(Libunwind_LIBRARIES
      ${_Libunwind_LIBRARIES}
      CACHE FILEPATH "Path of libunwind libraries." FORCE)
  unset(_Libunwind_LIBRARIES)
  get_filename_component(Libunwind_LIBRARY_DIRS ${Libunwind_LIBRARY} DIRECTORY CACHE)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(Libunwind REQUIRED_VARS Libunwind_INCLUDE_DIRS Libunwind_LIBRARIES)
endif()

if(Libunwind_INCLUDE_DIRS AND EXISTS "${Libunwind_INCLUDE_DIRS}/libunwind-common.h")
  file(STRINGS "${Libunwind_INCLUDE_DIRS}/libunwind-common.h" Libunwind_HEADER_CONTENTS
       REGEX "#define UNW_VERSION_[A-Z]+\t[0-9]*")

  string(REGEX REPLACE ".*#define UNW_VERSION_MAJOR\t([0-9]*).*" "\\1" Libunwind_VERSION_MAJOR
                       "${Libunwind_HEADER_CONTENTS}")
  string(REGEX REPLACE ".*#define UNW_VERSION_MINOR\t([0-9]*).*" "\\1" Libunwind_VERSION_MINOR
                       "${Libunwind_HEADER_CONTENTS}")
  string(REGEX REPLACE ".*#define UNW_VERSION_EXTRA\t([0-9]*).*" "\\1" Libunwind_VERSION_EXTRA
                       "${Libunwind_HEADER_CONTENTS}")

  if(Libunwind_VERSION_EXTRA)
    set(Libunwind_VERSION_STRING
        "${Libunwind_VERSION_MAJOR}.${Libunwind_VERSION_MINOR}.${Libunwind_VERSION_EXTRA}"
        CACHE STRING "Version of libunwind" FORCE)
  else()
    set(Libunwind_VERSION_STRING
        "${Libunwind_VERSION_MAJOR}.${Libunwind_VERSION_MINOR}"
        CACHE STRING "Version of libunwind" FORCE)
  endif()
  unset(Libunwind_HEADER_CONTENTS)
endif()

if(Libunwind_FOUND AND Libunwind_LIBRARIES)
  include(CheckCSourceCompiles)
  set(CMAKE_REQUIRED_LIBRARIES_SAVE ${CMAKE_REQUIRED_LIBRARIES})
  set(CMAKE_REQUIRED_LIBRARIES ${Libunwind_LIBRARIES})
  set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
  set(CMAKE_REQUIRED_INCLUDES ${Libunwind_INCLUDE_DIRS})
  set(CMAKE_REQUIRED_FLAGS_SAVE ${CMAKE_REQUIRED_FLAGS})
  set(CMAKE_REQUIRED_FLAGS ${Libunwind_CFLAGS})
  set(CMAKE_REQUIRED_LINK_OPTIONS_SAVE ${CMAKE_REQUIRED_LINK_OPTIONS})
  set(CMAKE_REQUIRED_LINK_OPTIONS ${Libunwind_LDFLAGS})
  if(NOT Libunwind_HAS_UNW_GETCONTEXT)
    check_c_source_compiles(
      "
    #include <libunwind.h>
    int main() {
      unw_context_t unw_ctx;
      unw_getcontext(&unw_ctx);
      return 0;
    }"
      Libunwind_HAS_UNW_GETCONTEXT)
  endif()
  if(NOT Libunwind_HAS_UNW_INIT_LOCAL)
    check_c_source_compiles(
      "
    #include <libunwind.h>
    int main() {
      unw_context_t unw_ctx;
      unw_cursor_t unw_cur;
      unw_getcontext(&unw_ctx);
      unw_init_local(&unw_cur, &unw_ctx);
      return 0;
    }"
      Libunwind_HAS_UNW_INIT_LOCAL)
  endif()
  set(CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES_SAVE})
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})
  set(CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS_SAVE})
  set(CMAKE_REQUIRED_LINK_OPTIONS ${CMAKE_REQUIRED_LINK_OPTIONS_SAVE})
  unset(CMAKE_REQUIRED_LIBRARIES_SAVE)
  unset(CMAKE_REQUIRED_INCLUDES_SAVE)
  unset(CMAKE_REQUIRED_FLAGS_SAVE)
  unset(CMAKE_REQUIRED_LINK_OPTIONS_SAVE)
endif()

if(Libunwind_FOUND)
  if(NOT LIBUNWIND_FOUND)
    set(LIBUNWIND_FOUND ${Libunwind_FOUND})
  endif()
  set(LIBUNWIND_LIBRARIES ${Libunwind_LIBRARIES})
  set(LIBUNWIND_INCLUDE_DIRS ${Libunwind_INCLUDE_DIRS})

  if(NOT TARGET Libunwind::libunwind)
    if(Libunwind_LIBRARIES)
      add_library(Libunwind::libunwind UNKNOWN IMPORTED)
    else()
      add_library(Libunwind::libunwind INTERFACE IMPORTED)
    endif()
    set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libunwind_INCLUDE_DIRS}")
    # if(Libunwind_LIBRARY_DIRS) set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_LINK_DIRECTORIES
    # "${Libunwind_LIBRARY_DIRS}") endif()

    if(Libunwind_LIBRARIES)
      list(GET Libunwind_LIBRARIES 0 Libunwind_LIBRARIES_LOCATION)
      set_target_properties(Libunwind::libunwind PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                                                            IMPORTED_LOCATION "${Libunwind_LIBRARIES_LOCATION}")
      list(LENGTH Libunwind_LIBRARIES Libunwind_LIBRARIES_LENGTH)
      if(Libunwind_LIBRARIES_LENGTH GREATER 1)
        set(Libunwind_LIBRARIES_LOCATION ${Libunwind_LIBRARIES})
        list(REMOVE_AT Libunwind_LIBRARIES_LOCATION 0)
        set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_LINK_LIBRARIES
                                                              "${Libunwind_LIBRARIES_LOCATION}")
      endif()
      unset(Libunwind_LIBRARIES_LOCATION)
      unset(Libunwind_LIBRARIES_LENGTH)
    endif()
    if(Libunwind_LDFLAGS)
      set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_LINK_OPTIONS "${Libunwind_LDFLAGS}")
    endif()
    if(Libunwind_CFLAGS)
      set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_COMPILE_OPTIONS "${Libunwind_CFLAGS}")
    endif()
  endif()

  mark_as_advanced(
    Libunwind_FOUND
    LIBUNWIND_FOUND
    Libunwind_INCLUDE_DIRS
    LIBUNWIND_INCLUDE_DIRS
    Libunwind_LIBRARIES
    LIBUNWIND_LIBRARIES
    Libunwind_LIBRARY_DIRS
    Libunwind_VERSION_STRING
    Libunwind_HAS_UNW_GETCONTEXT
    Libunwind_HAS_UNW_INIT_LOCAL)
else()
  unset(Libunwind_FOUND CACHE)
  unset(Libunwind_INCLUDE_DIRS CACHE)
  unset(Libunwind_LIBRARIES CACHE)
  unset(Libunwind_LIBRARY_DIRS CACHE)
  unset(Libunwind_VERSION_STRING CACHE)
  unset(Libunwind_LIBRARY CACHE)
  unset(Libunwind_LIBRARY_EXTRA CACHE)
  unset(Libunwind_FOUND)
  unset(Libunwind_INCLUDE_DIRS)
  unset(Libunwind_LIBRARIES)
  unset(Libunwind_LIBRARY_DIRS)
  unset(Libunwind_VERSION_STRING)
  unset(Libunwind_LIBRARY)
  unset(Libunwind_LIBRARY_EXTRA)
endif()
