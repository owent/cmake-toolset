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

project(cmake-toolset-test)

enable_testing()

if(NOT DEFINED __COMPILER_OPTION_LOADED)
  set(CMAKE_TOOLSET_TEST_IS_TOP_LEVEL TRUE)
  if(MSVC)
    string(REGEX REPLACE "/EHsc" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REGEX REPLACE "/GR-?" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    string(REGEX REPLACE "-f(no-)?exceptions" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REGEX REPLACE "-f(no-)?rtti" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  endif()
endif()

set(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${CMAKE_CURRENT_LIST_DIR}/../..")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")

if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
  find_program(PROJECT_FIND_LINKER_MOLD NAMES mold mold.exe)
  if(PROJECT_FIND_LINKER_MOLD)
    get_filename_component(PROJECT_FIND_LINKER_MOLD_PREFIX_DIR "${PROJECT_FIND_LINKER_MOLD}" DIRECTORY)
    get_filename_component(PROJECT_FIND_LINKER_MOLD_PREFIX_DIR "${PROJECT_FIND_LINKER_MOLD_PREFIX_DIR}" DIRECTORY)
    if(EXISTS "${PROJECT_FIND_LINKER_MOLD_PREFIX_DIR}/libexec/mold/ld")
      try_set_linker(LINKER "${PROJECT_FIND_LINKER_MOLD}" LEGACY_LINKER_DIRECTORY
                     "${PROJECT_FIND_LINKER_MOLD_PREFIX_DIR}/libexec/mold")
    else()
      try_set_linker(LINKER "${PROJECT_FIND_LINKER_MOLD}")
    endif()
  endif()
endif()

# Disable shared protobuf library on windows for easy to run tests
if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS
      OFF
      CACHE BOOL "Allow build protobuf as dynamic(May cause duplicate symbol[File already exists in database])")
endif()

if(CMAKE_TOOLSET_TEST_IS_TOP_LEVEL)
  if(NOT COMPILER_OPTION_DEFAULT_ENABLE_RTTI)
    if(COMPILER_OPTIONS_TEST_RTTI)
      message(FATAL_ERROR "COMPILER_OPTIONS_TEST_RTTI=ON when COMPILER_OPTION_DEFAULT_ENABLE_RTTI=OFF")
    endif()
  else()
    if(NOT COMPILER_OPTIONS_TEST_RTTI)
      # Some versions of STL in MSVC may depend exception, we ignore this error here.
      file(WRITE "${CMAKE_BINARY_DIR}/ignore-configure-error.txt"
           "COMPILER_OPTIONS_TEST_RTTI=OFF when COMPILER_OPTION_DEFAULT_ENABLE_RTTI=ON")
      message(FATAL_ERROR "COMPILER_OPTIONS_TEST_RTTI=OFF when COMPILER_OPTION_DEFAULT_ENABLE_RTTI=ON")
    endif()
  endif()

  if(NOT COMPILER_OPTION_DEFAULT_ENABLE_EXCEPTION)
    if(COMPILER_OPTIONS_TEST_EXCEPTION)
      message(FATAL_ERROR "COMPILER_OPTIONS_TEST_EXCEPTION=ON when COMPILER_OPTION_DEFAULT_ENABLE_EXCEPTION=OFF")
    endif()
  else()
    if(NOT COMPILER_OPTIONS_TEST_EXCEPTION)
      message(FATAL_ERROR "COMPILER_OPTIONS_TEST_EXCEPTION=OFF when COMPILER_OPTION_DEFAULT_ENABLE_EXCEPTION=ON")
    endif()
  endif()
endif()

foreach(COMPILER_OPTION_INHERIT_VAR_NAME
        ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX}
        ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON})
  if(DEFINED COMPILER_OPTION_INHERIT_${COMPILER_OPTION_INHERIT_VAR_NAME})
    message(
      STATUS
        "COMPILER_OPTION_INHERIT_${COMPILER_OPTION_INHERIT_VAR_NAME}=${COMPILER_OPTION_INHERIT_${COMPILER_OPTION_INHERIT_VAR_NAME}}"
    )
  endif()
endforeach()
message(STATUS "ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS=${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS}")

# Ports
if(EXISTS "${CMAKE_BINARY_DIR}/ignore-configure-error.txt")
  file(REMOVE "${CMAKE_BINARY_DIR}/ignore-configure-error.txt")
endif()

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/lua/lua.cmake")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/abseil-cpp/abseil-cpp.cmake")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/protobuf/protobuf.cmake")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/grpc/upb.cmake")

add_subdirectory("${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/upb/upb/bindings/lua")

set(UPB_COMMAND_OPTIONS
    "--plugin=protoc-gen-upb=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPB}"
    "--plugin=protoc-gen-lua=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_LUA}"
    "--upb_out=${CMAKE_CURRENT_BINARY_DIR}" "--lua_out=${CMAKE_CURRENT_BINARY_DIR}")
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPBDEFS)
  list(APPEND UPB_COMMAND_OPTIONS
       "--plugin=protoc-gen-upbdefs=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPBDEFS}"
       "--upbdefs_out=${CMAKE_CURRENT_BINARY_DIR}")
endif()

add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb.c"
         "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upbdefs.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upbdefs.c"
         "${CMAKE_CURRENT_BINARY_DIR}/test_pb_pb.lua"
  COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}" --proto_path "${CMAKE_CURRENT_LIST_DIR}/.."
          ${UPB_COMMAND_OPTIONS} "${CMAKE_CURRENT_LIST_DIR}/../test_pb.proto"
  COMMAND "${CMAKE_COMMAND}" -E copy_if_different
          "${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/upb/upb/bindings/lua/upb.lua" "${CMAKE_CURRENT_BINARY_DIR}"
  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/../test_pb.proto"
  COMMENT
    "Generate test_pb_pb.lua,test_pb.upb.h,test_pb.upb.c,test_pb.upbdefs.h,test_pb.upbdefs.c into ${CMAKE_CURRENT_BINARY_DIR}"
)

add_executable(
  cmake-toolset-upb-and-lua-binding-test
  "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb.c"
  "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upbdefs.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upbdefs.c"
  ../upb-and-lua-binding.cpp)

target_include_directories("cmake-toolset-upb-and-lua-binding-test" PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

target_link_libraries("cmake-toolset-upb-and-lua-binding-test" ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_LINK_NAME}
                      upb::lupb ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME})

target_compile_options("cmake-toolset-upb-and-lua-binding-test"
                       PRIVATE "${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS}")
