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
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.22.0")
  cmake_policy(SET CMP0128 NEW)
endif()
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.27.0")
  cmake_policy(SET CMP0144 NEW)
endif()

project(cmake-toolset-flatbuffers-host)

if(NOT CMAKE_PARENT_LIST_FILE OR CMAKE_PARENT_LIST_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  if(MSVC)
    string(REGEX REPLACE "/EHsc" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REGEX REPLACE "/GR-?" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    string(REGEX REPLACE "-f(no-)?exceptions" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REGEX REPLACE "-f(no-)?rtti" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  endif()
endif()

set(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../")
set(ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING TRUE)

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")

project_third_party_include_port("flatbuffers/flatbuffers.cmake")

# Test protobuf generator
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/helloworld_generated.h"
  COMMAND
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE}" -I "${CMAKE_CURRENT_LIST_DIR}" --cpp --allow-non-utf8
    --natural-utf8 --gen-mutable --gen-object-api --reflect-types --reflect-names -o "${CMAKE_CURRENT_BINARY_DIR}"
    "${CMAKE_CURRENT_LIST_DIR}/helloworld.fbs"
  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/helloworld.fbs"
  COMMENT "Generate helloworld.* into ${CMAKE_CURRENT_BINARY_DIR}")

add_executable("${PROJECT_NAME}-cross-test" "${CMAKE_CURRENT_BINARY_DIR}/helloworld_generated.h" cross-main.cpp)
target_include_directories("${PROJECT_NAME}-cross-test" PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries("${PROJECT_NAME}-cross-test" ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_LINK_NAME})

target_compile_options("${PROJECT_NAME}-cross-test" PRIVATE "${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS}")
