cmake_minimum_required(VERSION 3.16)
cmake_policy(SET CMP0022 NEW)
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0067 NEW)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0077 NEW)
cmake_policy(SET CMP0091 NEW)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19.0")
  cmake_policy(SET CMP0111 NEW)
endif()

# MSVC RTTI flag /GR should not be not added to CMAKE_CXX_FLAGS by default. @see
# https://cmake.org/cmake/help/latest/policy/CMP0117.html
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.20.0")
  cmake_policy(SET CMP0117 NEW)
endif()

project(upb-binding-lua)

if(NOT CMAKE_PARENT_LIST_FILE OR CMAKE_PARENT_LIST_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  if(MSVC)
    string(REGEX REPLACE "/EHsc" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REGEX REPLACE "/GR-?" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    string(REGEX REPLACE "-f(no-)?exceptions" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REGEX REPLACE "-f(no-)?rtti" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  endif()
endif()

find_package(upb REQUIRED CONFIG)
find_package(absl REQUIRED CONFIG)
find_package(protobuf REQUIRED CONFIG)

# Try to use unofficial-lua-config.cmake in vcpkg
if(VCPKG_TOOLCHAIN
   AND NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  find_package(unofficial-lua QUIET CONFIG)
endif()

# Try to use lua-config.cmake
if(NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  find_package(lua QUIET CONFIG)
endif()

# Try to use FindLua.cmake
if(NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  find_package(Lua QUIET MODULE)
endif()

if(NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  message(
    FATAL_ERROR
      "lua::liblua-static,lua::liblua-dynamic,lua::liblua,unofficial-lua::lua,lua or Lua isrequired to build this module"
  )
endif()

include(CheckCXXSourceCompiles)
if(TARGET lua::liblua-dynamic)
  message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua::liblua-dynamic")
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME lua::liblua-dynamic)
  if(NOT TARGET lua)
    add_library(lua INTERFACE IMPORTED)
    set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua-dynamic)
  endif()
elseif(TARGET lua::liblua-static)
  message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua::liblua-static")
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME lua::liblua-static)
  if(NOT TARGET lua)
    add_library(lua INTERFACE IMPORTED)
    set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua-static)
  endif()
elseif(TARGET lua::liblua)
  message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua::liblua")
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME lua::liblua)
  if(NOT TARGET lua)
    add_library(lua INTERFACE IMPORTED)
    set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua)
  endif()
elseif(TARGET unofficial-lua::lua)
  message(STATUS "Dependency(${PROJECT_NAME}): Lua found target unofficial-lua::lua")
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME unofficial-lua::lua)
  if(NOT TARGET lua)
    add_library(lua INTERFACE IMPORTED)
    set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES unofficial-lua::lua)
  endif()
elseif(TARGET lua)
  message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua")
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME lua)
elseif(LUA_FOUND)
  add_library(lua::liblua UNKNOWN IMPORTED)
  set_target_properties(lua::liblua PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${LUA_INCLUDE_DIR}")
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS ${LUA_LIBRARIES})
  list(POP_FRONT UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS UPB_BINDING_LUA_THIRD_PARTY_LUA_IMPORTED_LOCATION)
  set_target_properties(lua::liblua PROPERTIES IMPORTED_LOCATION "${UPB_BINDING_LUA_THIRD_PARTY_LUA_IMPORTED_LOCATION}")

  if(ANDROID)
    list(APPEND UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS "log" "m" "c")
  elseif(UNIX)
    include(CMakePushCheckState)
    cmake_push_check_state()
    list(APPEND CMAKE_REQUIRED_LIBRARIES "m")
    check_cxx_source_compiles("#include <cstdio>
    int main() { return 0; }" UPB_BINDING_LUA_THIRD_PARTY_LUA_TEST_LINK_M)
    if(UPB_BINDING_LUA_THIRD_PARTY_LUA_TEST_LINK_M)
      list(APPEND UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS "m")
    endif()
    cmake_pop_check_state()

    cmake_push_check_state()
    list(APPEND CMAKE_REQUIRED_LIBRARIES "dl")
    check_cxx_source_compiles("#include <cstdio>
    int main() { return 0; }" UPB_BINDING_LUA_THIRD_PARTY_LUA_TEST_LINK_DL)
    if(UPB_BINDING_LUA_THIRD_PARTY_LUA_TEST_LINK_DL)
      list(APPEND UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS "dl")
    endif()
    cmake_pop_check_state()
  endif()

  if(UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS)
    set_target_properties(lua::liblua PROPERTIES INTERFACE_LINK_LIBRARIES
                                                 "${UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS}")
  endif()

  unset(UPB_BINDING_LUA_THIRD_PARTY_LUA_LIB_DEPEND_LIBS)
  message(
    STATUS
      "-- Dependency(${PROJECT_NAME}): Lua found ${LUA_VERSION_STRING}(module) and redirect to target lua::liblua(${LUA_LIBRARIES})"
  )
  set(UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME lua::liblua)
  if(NOT TARGET lua)
    add_library(lua INTERFACE IMPORTED)
    set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua)
  endif()
endif()

add_library(lupb STATIC "def.c" "msg.c" "upb.c")

get_filename_component(UPB_BINDING_LUA_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_WITH_LEGACY_BINDING_DIR)
  get_filename_component(UPB_BINDING_LUA_SRC_DIR "${UPB_BINDING_LUA_SRC_DIR}" DIRECTORY)
  get_filename_component(UPB_BINDING_LUA_SRC_DIR "${UPB_BINDING_LUA_SRC_DIR}" DIRECTORY)

  target_compile_definitions(lupb INTERFACE UPB_BINDING_LUA_WITH_LEGACY_BINDING=1)
endif()

target_include_directories(lupb PUBLIC "$<BUILD_INTERFACE:${UPB_BINDING_LUA_SRC_DIR}>" "$<INSTALL_INTERFACE:share/upb>")
target_link_libraries(lupb PUBLIC upb::json upb::reflection upb::textformat upb::upb
                                  ${UPB_BINDING_LUA_THIRD_PARTY_LUA_LINK_NAME})

add_library(upb::lupb ALIAS lupb)

if(MSVC)
  set_property(TARGET lupb PROPERTY FOLDER "upb")
endif(MSVC)
