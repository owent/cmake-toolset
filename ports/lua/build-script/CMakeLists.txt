cmake_minimum_required(VERSION 3.14.0)
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0022 NEW)
cmake_policy(SET CMP0067 NEW)
cmake_policy(SET CMP0074 NEW)

project(lua)

if(CMAKE_CROSSCOMPILING)
  option(LUA_BUILD_CLI "Build lua program" OFF)
  option(LUA_BUILD_LEGACY_LUAC "Build luac progam" OFF)
else()
  option(LUA_BUILD_CLI "Build lua program" ON)
  option(LUA_BUILD_LEGACY_LUAC "Build luac progam" ON)
endif()

include(CMakeDependentOption)
cmake_dependent_option(BUILD_SHARED_LIBS "Build shared libraries" ON "NOT LZ4_BUNDLED_MODE" OFF)
cmake_dependent_option(BUILD_STATIC_LIBS "Build static libraries" OFF "BUILD_SHARED_LIBS" ON)

if(NOT BUILD_SHARED_LIBS AND NOT BUILD_STATIC_LIBS)
  message(FATAL_ERROR "Both BUILD_SHARED_LIBS and BUILD_STATIC_LIBS have been disabled")
endif()

file(READ "${LUA_TOP_SOURCE_DIR}/lua.h" PROJECT_LUA_HEADER_LUA_H)
if(PROJECT_LUA_HEADER_LUA_H MATCHES "LUA_VERSION_MAJOR[ \t\r\n]+\"?([0-9]+)\"")
  math(EXPR PROJECT_LUA_VERSION_MAJOR ${CMAKE_MATCH_1})
endif()
if(PROJECT_LUA_HEADER_LUA_H MATCHES "LUA_VERSION_MINOR[ \t\r\n]+\"?([0-9]+)\"")
  math(EXPR PROJECT_LUA_VERSION_MINOR ${CMAKE_MATCH_1})
endif()
if(PROJECT_LUA_HEADER_LUA_H MATCHES "LUA_VERSION_RELEASE[ \t\r\n]+\"?([0-9]+)\"")
  math(EXPR PROJECT_LUA_VERSION_RELEASE ${CMAKE_MATCH_1})
endif()

aux_source_directory("${LUA_TOP_SOURCE_DIR}" PROJECT_LUA_ALL_SRC)
unset(PROJECT_LUA_SRC_LIST)
foreach(PROJECT_LUA_SRC_FILE IN LISTS PROJECT_LUA_ALL_SRC)
  get_filename_component(PROJECT_LUA_SRC_FILE_BASENAME "${PROJECT_LUA_SRC_FILE}" NAME)
  if(NOT "${PROJECT_LUA_SRC_FILE_BASENAME}" STREQUAL "lua.c"
     AND NOT "${PROJECT_LUA_SRC_FILE_BASENAME}" STREQUAL "luac.c"
     AND NOT "${PROJECT_LUA_SRC_FILE_BASENAME}" STREQUAL "onelua.c")
    list(APPEND PROJECT_LUA_SRC_LIST "${PROJECT_LUA_SRC_FILE}")
  endif()
endforeach()
list(APPEND PROJECT_LUA_SRC_LIST ${PROJECT_LUA_ALL_HEADER})

set(PROJECT_LUA_EXPORT_NAME "${PROJECT_NAME}-target")
set(PROJECT_LUA_PUBLIC_HEADERS "${LUA_TOP_SOURCE_DIR}/lua.h" "${LUA_TOP_SOURCE_DIR}/lualib.h"
                               "${LUA_TOP_SOURCE_DIR}/luaconf.h" "${LUA_TOP_SOURCE_DIR}/lauxlib.h")

if(BUILD_STATIC_LIBS)
  add_library("${PROJECT_NAME}_STATIC" STATIC ${PROJECT_LUA_SRC_LIST})
endif()

if(BUILD_SHARED_LIBS)
  add_library("${PROJECT_NAME}_DYNAMIC" SHARED ${PROJECT_LUA_SRC_LIST})
endif()

set(PROJECT_LUA_EXT_OPTIONS "LUA_COMPAT_5_3")

if(CMAKE_HOST_APPLE OR APPLE)
  list(APPEND PROJECT_LUA_EXT_OPTIONS LUA_USE_MACOSX)
elseif(CYGWIN OR MINGW)
  # do nothing
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND PROJECT_LUA_EXT_OPTIONS LUA_USE_LINUX)
else()
  # do nothing
endif()

include(CheckCXXSourceCompiles)
include(CheckCXXCompilerFlag)
include(CMakePackageConfigHelpers)
# Allow to add flags from outside, don't unset it unset(PROJECT_LUA_LIB_DEPEND_LIBS) unset(PROJECT_LUA_LIB_DEPEND_DEFS)
# unset(PROJECT_LUA_LIB_DEPEND_FLAGS)
if(BUILD_SHARED_LIBS
   AND NOT WIN32
   AND NOT MINGW)
  set(PROJECT_LUA_BIN_DEPEND_LIBS "${PROJECT_NAME}_DYNAMIC")
elseif(BUILD_STATIC_LIBS)
  set(PROJECT_LUA_BIN_DEPEND_LIBS "${PROJECT_NAME}_STATIC")
else()
  set(PROJECT_LUA_BIN_DEPEND_LIBS "${PROJECT_NAME}_DYNAMIC")
endif()

set(CMAKE_INSTALL_RPATH_USE_LINK_PATH YES)
set(CMAKE_BUILD_WITH_INSTALL_RPATH NO)
set(CMAKE_BUILD_RPATH_USE_ORIGIN YES)

if(MSVC)
  list(APPEND PROJECT_LUA_LIB_DEPEND_FLAGS "/W4" "/MP" "/EHsc")
  if(MSVC_VERSION GREATER_EQUAL 1914 AND COMPILER_OPTION_MSVC_ZC_CPP)
    list(APPEND PROJECT_LUA_LIB_DEPEND_FLAGS "/Zc:__cplusplus")
  endif()

  set(CMAKE_MSVC_RUNTIME_LIBRARY
      "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<NOT:$<STREQUAL:${VCPKG_CRT_LINKAGE},static>>:DLL>"
      CACHE STRING "")
else()
  list(
    APPEND
    PROJECT_LUA_LIB_DEPEND_FLAGS_FOR_C
    "-Wdeclaration-after-statement"
    "-Wmissing-prototypes"
    "-Wnested-externs"
    "-Wstrict-prototypes"
    "-Wc++-compat"
    "-Wold-style-definition")
  list(
    APPEND
    PROJECT_LUA_LIB_DEPEND_FLAGS
    "-Wall"
    "-Wextra"
    "-Wshadow"
    "-Wsign-compare"
    "-Wundef"
    "-Wwrite-strings"
    "-Wredundant-decls"
    "-Wdisabled-optimization"
    "-Wdouble-promotion"
    "$<$<COMPILE_LANGUAGE:CXX>:-Wlogical-op;-Wno-aggressive-loop-optimizations>"
    "$<$<COMPILE_LANGUAGE:C>:${PROJECT_LUA_LIB_DEPEND_FLAGS_FOR_C}>")
  check_cxx_compiler_flag("-fno-stack-protector" PROJECT_LUA_TEST_NO_STACK_PROTECTOR)
  check_cxx_compiler_flag("-fno-common" PROJECT_LUA_TEST_NO_COMMON)
  check_cxx_compiler_flag("-march=native" PROJECT_LUA_TEST_NO_MARCH_NATIVE)
  check_cxx_compiler_flag("-rdynamic" PROJECT_LUA_TEST_RDYNAMIC)
  if(PROJECT_LUA_TEST_NO_STACK_PROTECTOR)
    list(APPEND PROJECT_LUA_LIB_DEPEND_FLAGS "-fno-stack-protector")
  endif()
  if(PROJECT_LUA_TEST_NO_COMMON)
    list(APPEND PROJECT_LUA_LIB_DEPEND_FLAGS "-fno-common")
  endif()
  if(PROJECT_LUA_TEST_NO_MARCH_NATIVE)
    list(APPEND PROJECT_LUA_LIB_DEPEND_FLAGS "-march=native")
  endif()
endif()

if(NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 11)
endif()

if(NOT CMAKE_CXX_STANDARD)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
    set(CMAKE_CXX_STANDARD 20)
  elseif(CMAKE_VERSION VERSION_GREATER_EQUAL "3.8.0")
    set(CMAKE_CXX_STANDARD 17)
  else()
    set(CMAKE_CXX_STANDARD 14)
  endif()
endif()

if(ANDROID)
  list(APPEND PROJECT_LUA_LIB_DEPEND_LIBS "log" "m" "c")
elseif(UNIX)
  include(CMakePushCheckState)

  cmake_push_check_state()
  list(APPEND CMAKE_REQUIRED_LIBRARIES "m")
  check_cxx_source_compiles("#include <cstdio>
    int main() { return 0; }" PROJECT_LUA_TEST_LINK_M)
  if(PROJECT_LUA_TEST_LINK_M)
    list(APPEND PROJECT_LUA_LIB_DEPEND_LIBS "m")
  endif()
  cmake_pop_check_state()

  cmake_push_check_state()
  list(APPEND CMAKE_REQUIRED_LIBRARIES "dl")
  check_cxx_source_compiles("#include <cstdio>
    int main() { return 0; }" PROJECT_LUA_TEST_LINK_DL)
  if(PROJECT_LUA_TEST_LINK_DL)
    list(APPEND PROJECT_LUA_LIB_DEPEND_LIBS "dl")
  endif()
  cmake_pop_check_state()
endif()

if(NOT MSVC)
  include(CMakePushCheckState)

  cmake_push_check_state()
  list(APPEND CMAKE_REQUIRED_LIBRARIES "readline")
  check_cxx_source_compiles("#include <readline/readline.h>
    int main() { return 0; }" PROJECT_LUA_TEST_HAS_READLINE)
  if(PROJECT_LUA_TEST_HAS_READLINE)
    list(APPEND PROJECT_LUA_EXT_OPTIONS "LUA_USE_READLINE")
    list(APPEND PROJECT_LUA_BIN_DEPEND_LIBS "readline")
  endif()
  cmake_pop_check_state()
endif()

if(BUILD_STATIC_LIBS)
  target_include_directories("${PROJECT_NAME}_STATIC" PUBLIC "$<BUILD_INTERFACE:${LUA_TOP_SOURCE_DIR}>"
                                                             "$<INSTALL_INTERFACE:include>")

  target_compile_options("${PROJECT_NAME}_STATIC" PRIVATE ${PROJECT_LUA_LIB_DEPEND_FLAGS})

  target_compile_definitions("${PROJECT_NAME}_STATIC" PRIVATE ${PROJECT_LUA_EXT_OPTIONS})

  set_target_properties(
    "${PROJECT_NAME}_STATIC"
    PROPERTIES EXPORT_NAME "lib${PROJECT_NAME}-static"
               OUTPUT_NAME "${PROJECT_NAME}"
               VERSION "${PROJECT_LUA_VERSION_MAJOR}.${PROJECT_LUA_VERSION_MINOR}.${PROJECT_LUA_VERSION_RELEASE}"
               POSITION_INDEPENDENT_CODE TRUE
               PUBLIC_HEADER "${PROJECT_LUA_PUBLIC_HEADERS}")
endif()

if(BUILD_SHARED_LIBS)
  target_include_directories("${PROJECT_NAME}_DYNAMIC" PUBLIC "$<BUILD_INTERFACE:${LUA_TOP_SOURCE_DIR}>"
                                                              "$<INSTALL_INTERFACE:include>")

  target_compile_options("${PROJECT_NAME}_DYNAMIC" PRIVATE ${PROJECT_LUA_LIB_DEPEND_FLAGS})

  target_compile_definitions("${PROJECT_NAME}_DYNAMIC" PRIVATE ${PROJECT_LUA_EXT_OPTIONS})

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN)
    if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VISIBILITY_HIDDEN
       AND NOT DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VISIBILITY_HIDDEN})
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VISIBILITY_HIDDEN
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN})
    endif()
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VISIBILITY_HIDDEN)
    target_compile_definitions("${PROJECT_NAME}_DYNAMIC" PUBLIC LUA_BUILD_AS_DLL=1)
    set_target_properties("${PROJECT_NAME}_DYNAMIC" PROPERTIES C_VISIBILITY_PRESET "hidden" CXX_VISIBILITY_PRESET
                                                                                            "hidden")
  else()
    set_target_properties("${PROJECT_NAME}_DYNAMIC" PROPERTIES C_VISIBILITY_PRESET "default" CXX_VISIBILITY_PRESET
                                                                                             "default")
  endif()

  set_target_properties(
    "${PROJECT_NAME}_DYNAMIC"
    PROPERTIES OUTPUT_NAME "${PROJECT_NAME}"
               EXPORT_NAME "lib${PROJECT_NAME}-dynamic"
               VERSION "${PROJECT_LUA_VERSION_MAJOR}.${PROJECT_LUA_VERSION_MINOR}.${PROJECT_LUA_VERSION_RELEASE}"
               SOVERSION "${PROJECT_LUA_VERSION_MAJOR}.${PROJECT_LUA_VERSION_MINOR}.${PROJECT_LUA_VERSION_RELEASE}"
               POSITION_INDEPENDENT_CODE TRUE
               PUBLIC_HEADER "${PROJECT_LUA_PUBLIC_HEADERS}")
endif()

if(PROJECT_LUA_LIB_DEPEND_DEFS)
  if(BUILD_STATIC_LIBS)
    target_compile_definitions("${PROJECT_NAME}_STATIC" PUBLIC ${PROJECT_LUA_LIB_DEPEND_DEFS})
  endif()

  if(BUILD_SHARED_LIBS)
    target_compile_definitions("${PROJECT_NAME}_DYNAMIC" PUBLIC ${PROJECT_LUA_LIB_DEPEND_DEFS})
  endif()
endif()

if(PROJECT_LUA_LIB_DEPEND_LIBS)
  if(BUILD_STATIC_LIBS)
    set_target_properties("${PROJECT_NAME}_STATIC" PROPERTIES INTERFACE_LINK_LIBRARIES "${PROJECT_LUA_LIB_DEPEND_LIBS}")
  endif()
  if(BUILD_SHARED_LIBS)
    target_link_libraries("${PROJECT_NAME}_DYNAMIC" PUBLIC "${PROJECT_LUA_LIB_DEPEND_LIBS}")
  endif()
endif()

if(BUILD_SHARED_LIBS AND PROJECT_LUA_TEST_RDYNAMIC)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
    set(PROJECT_LUA_LINK_FLAGS_VAR_NAME "LINK_OPTIONS")
  else()
    set(PROJECT_LUA_LINK_FLAGS_VAR_NAME "LINK_FLAGS")
  endif()
  get_target_property(PROJECT_LUA_LINK_FLAGS_OF_DYNAMIC "${PROJECT_NAME}_DYNAMIC" ${PROJECT_LUA_LINK_FLAGS_VAR_NAME})
  if(PROJECT_LUA_LINK_FLAGS_OF_DYNAMIC)
    list(APPEND "-rdynamic" PROJECT_LUA_LINK_FLAGS_OF_DYNAMIC)
  else()
    set(PROJECT_LUA_LINK_FLAGS_OF_DYNAMIC "-rdynamic")
  endif()
  set_target_properties("${PROJECT_NAME}_DYNAMIC" PROPERTIES ${PROJECT_LUA_LINK_FLAGS_VAR_NAME}
                                                             "${PROJECT_LUA_LINK_FLAGS_OF_DYNAMIC}")
  unset(PROJECT_LUA_LINK_FLAGS_OF_DYNAMIC)
endif()

unset(PROJECT_LUA_EXPORT_TARGETS)
if(BUILD_STATIC_LIBS)
  list(APPEND PROJECT_LUA_EXPORT_TARGETS "${PROJECT_NAME}_STATIC")
endif()
if(BUILD_SHARED_LIBS)
  list(APPEND PROJECT_LUA_EXPORT_TARGETS "${PROJECT_NAME}_DYNAMIC")
endif()

macro(add_lua_executable_target TARGET_NAME)
  add_executable("${TARGET_NAME}" ${ARGN})
  target_include_directories("${TARGET_NAME}" PUBLIC "$<BUILD_INTERFACE:${LUA_TOP_SOURCE_DIR}>"
                                                     "$<INSTALL_INTERFACE:include>")
  target_compile_options("${TARGET_NAME}" PRIVATE ${PROJECT_LUA_LIB_DEPEND_FLAGS})

  target_compile_definitions("${TARGET_NAME}" PRIVATE ${PROJECT_LUA_EXT_OPTIONS})

  target_link_libraries("${TARGET_NAME}" ${PROJECT_LUA_BIN_DEPEND_LIBS})

  add_executable("lua::${TARGET_NAME}" ALIAS "${TARGET_NAME}")
  list(APPEND PROJECT_LUA_EXPORT_TARGETS "${TARGET_NAME}")
endmacro()

if(LUA_BUILD_CLI AND EXISTS "${LUA_TOP_SOURCE_DIR}/lua.c")
  add_lua_executable_target("${PROJECT_NAME}" "${LUA_TOP_SOURCE_DIR}/lua.c")
endif()

if(LUA_BUILD_LEGACY_LUAC AND EXISTS "${LUA_TOP_SOURCE_DIR}/luac.c")
  add_lua_executable_target("${PROJECT_NAME}c" "${LUA_TOP_SOURCE_DIR}/luac.c")
endif()

include(GNUInstallDirs)

# alias is the same as exported target
if(BUILD_STATIC_LIBS)
  add_library("lua::lib${PROJECT_NAME}-static" ALIAS "${PROJECT_NAME}_STATIC")
endif()
if(BUILD_SHARED_LIBS)
  add_library("lua::lib${PROJECT_NAME}-dynamic" ALIAS "${PROJECT_NAME}_DYNAMIC")
endif()

install(
  TARGETS ${PROJECT_LUA_EXPORT_TARGETS}
  EXPORT ${PROJECT_LUA_EXPORT_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

export(
  EXPORT ${PROJECT_LUA_EXPORT_NAME}
  NAMESPACE lua::
  FILE "cmake/${PROJECT_LUA_EXPORT_NAME}.cmake")

install(
  EXPORT ${PROJECT_LUA_EXPORT_NAME}
  NAMESPACE lua::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/lua")

configure_package_config_file(
  "${CMAKE_CURRENT_LIST_DIR}/lua-config.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/lua"
  # PATH_VARS PROJECT_NAME
  NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
  VERSION "${PROJECT_LUA_VERSION_MAJOR}.${PROJECT_LUA_VERSION_MINOR}.${PROJECT_LUA_VERSION_RELEASE}"
  COMPATIBILITY SameMinorVersion)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
              "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/lua")

set(CPACK_PACKAGE_VENDOR "lua")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_LUA_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_LUA_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_LUA_VERSION_RELEASE}")
set(CPACK_PACKAGE_DESCRIPTION "Lua ${PROJECT_LUA_VERSION_MAJOR}.${PROJECT_LUA_VERSION_MINOR}")
set(CPACK_PACKAGE_CONTACT "admin@owent.net")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://www.lua.org/")

include(CPack)
