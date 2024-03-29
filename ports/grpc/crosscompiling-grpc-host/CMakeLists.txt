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

project(cmake-toolset-grpc-host)

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

# Ports
project_third_party_include_port("compression/import.cmake")

project_third_party_include_port("algorithm/xxhash.cmake")

project_third_party_include_port("test/gtest.cmake")
project_third_party_include_port("test/benchmark.cmake")
project_third_party_include_port("ssl/port.cmake")
project_third_party_include_port("cares/c-ares.cmake")
project_third_party_include_port("abseil-cpp/abseil-cpp.cmake")
project_third_party_include_port("re2/re2.cmake")
project_third_party_include_port("libcurl/libcurl.cmake")
project_third_party_include_port("protobuf/protobuf.cmake")
project_third_party_include_port("grpc/import.cmake")

# Test protobuf generator
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.h" "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.cc"
         "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.cc" "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.h"
  COMMAND
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}" --proto_path "${CMAKE_CURRENT_LIST_DIR}"
    "--plugin=protoc-gen-grpc=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE}"
    "--cpp_out=${CMAKE_CURRENT_BINARY_DIR}/" "--grpc_out=${CMAKE_CURRENT_BINARY_DIR}"
    "${CMAKE_CURRENT_LIST_DIR}/helloworld.proto"
  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/helloworld.proto"
  COMMENT "Generate helloworld.* into ${CMAKE_CURRENT_BINARY_DIR}")

add_executable(
  "${PROJECT_NAME}-client-test"
  "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.cc" "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.h"
  "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.cc" "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.h"
  client-main.cpp)
target_include_directories("${PROJECT_NAME}-client-test" PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries(
  "${PROJECT_NAME}-client-test"
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_SNAPPY_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_LINK_NAME})

target_compile_options("${PROJECT_NAME}-client-test" PRIVATE "${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS}")

add_executable(
  "${PROJECT_NAME}-server-test"
  "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.cc" "${CMAKE_CURRENT_BINARY_DIR}/helloworld.pb.h"
  "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.cc" "${CMAKE_CURRENT_BINARY_DIR}/helloworld.grpc.pb.h"
  server-main.cpp)
target_include_directories("${PROJECT_NAME}-server-test" PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries(
  "${PROJECT_NAME}-server-test"
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_SNAPPY_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME}
  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_LINK_NAME})

target_compile_options("${PROJECT_NAME}-server-test" PRIVATE "${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS}")
