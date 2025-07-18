cmake_minimum_required(VERSION 3.16)

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

project(cmake-toolset-test LANGUAGES C CXX)

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

set(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

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

foreach(
  COMPILER_OPTION_INHERIT_VAR_NAME
  ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX}
  ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON}
  ${PROJECT_BUILD_TOOLS_CMAKE_FIND_ROOT_VARS})
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

project_third_party_include_port("compression/import.cmake")

if(NOT ANDROID AND NOT CMAKE_HOST_APPLE)
  if(COMPILER_OPTIONS_TEST_EXCEPTION)
    project_third_party_include_port("jemalloc/jemalloc.cmake")
  endif()
  if(NOT WIN32
     AND NOT MINGW
     AND NOT PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER)
    #[[
    # There is a BUG in gcc 4.6-4.8 and finxed in gcc 4.9
    #   @see https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58016
    #   @see https://gcc.gnu.org/gcc-4.9/changes.html
    #]]
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.9")
      project_third_party_include_port("libunwind/libunwind.cmake")
    endif()
  endif()
endif()
if(COMPILER_OPTIONS_TEST_EXCEPTION)
  # mimalloc do not support VS2019
  if(NOT (MSVC AND MSVC_VERSION LESS 1930))
    project_third_party_include_port("malloc/mimalloc.cmake")
  endif()
endif()

project_third_party_include_port("algorithm/xxhash.cmake")
if(COMPILER_OPTIONS_TEST_EXCEPTION)
  # tbb do not support -fno-exceptions now
  project_third_party_include_port("algorithm/tbb.cmake")
endif()
project_third_party_include_port("libuv/libuv.cmake")
project_third_party_include_port("lua/lua.cmake")

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8")
    project_third_party_include_port("gsl/ms-gsl.cmake")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10")
    project_third_party_include_port("gsl/ms-gsl.cmake")
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10.3")
    project_third_party_include_port("gsl/ms-gsl.cmake")
  endif()
elseif(MSVC)
  if(MSVC_VERSION GREATER_EQUAL 1916)
    project_third_party_include_port("gsl/ms-gsl.cmake")
  endif()
endif()
if(NOT TARGET Microsoft.GSL::GSL)
  project_third_party_include_port("gsl/gsl-lite.cmake")
endif()

project_third_party_include_port("fmtlib/fmtlib.cmake")
if(COMPILER_OPTIONS_TEST_EXCEPTION)
  project_third_party_include_port("yaml-cpp/yaml-cpp.cmake")
endif()
project_third_party_include_port("json/rapidjson.cmake")
project_third_party_include_port("json/nlohmann_json.cmake")

project_third_party_include_port("test/gtest.cmake")
project_third_party_include_port("test/benchmark.cmake")

project_third_party_include_port("flatbuffers/flatbuffers.cmake")
project_third_party_include_port("ssl/port.cmake")
# nghttp2 do not work with libevent without openssl component
if(NOT (ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL
        OR ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL))
  project_third_party_include_port("libevent/libevent.cmake")
endif()
project_third_party_include_port("redis/hiredis.cmake")
project_third_party_include_port("cares/c-ares.cmake")
project_third_party_include_port("abseil-cpp/abseil-cpp.cmake")
project_third_party_include_port("re2/re2.cmake")
project_third_party_include_port("ngtcp2/nghttp3.cmake")
project_third_party_include_port("ngtcp2/ngtcp2.cmake")
project_third_party_include_port("nghttp2/nghttp2.cmake")
project_third_party_include_port("libcurl/libcurl.cmake")

if(COMPILER_OPTIONS_TEST_EXCEPTION)
  project_third_party_include_port("web/civetweb.cmake")
endif()
if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL)
  project_third_party_include_port("web/libwebsockets.cmake")
endif()

if(VCPKG_TOOLCHAIN
   AND MSVC
   AND MSVC_VERSION GREATER_EQUAL 1929)
  message(STATUS "Current protobuf in vcpkg is too old to support MSVC 1929(VS 16.10)")
else()
  project_third_party_include_port("protobuf/protobuf.cmake")
  project_third_party_include_port("grpc/import.cmake")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_STANDALONE_UPB)
    project_third_party_include_port("grpc/upb.cmake")
  endif()

  if(COMPILER_OPTIONS_TEST_EXCEPTION)
    project_third_party_include_port("telemetry/prometheus-cpp.cmake")
  endif()
  if(MSVC AND MSVC_VERSION LESS 1920)
    message(
      STATUS "Opentelemetry-cpp only support Visual Studio 2019 and upper. Skip it for MSVC_VERSION=${MSVC_VERSION}")
  else()
    project_third_party_include_port("telemetry/opentelemetry-cpp.cmake")
  endif()
endif()

project_third_party_include_port("libcopp/libcopp.cmake")

# Test protobuf generator
set(MAIN_TEST_SRC_FILES main.cpp)
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC)
  add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/test_pb.pb.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.pb.cc"
           "${CMAKE_CURRENT_BINARY_DIR}/test_pb.pb"
    COMMAND
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC} --proto_path "${CMAKE_CURRENT_LIST_DIR}" -o
      "${CMAKE_CURRENT_BINARY_DIR}/test_pb.pb" "--cpp_out=${CMAKE_CURRENT_BINARY_DIR}/"
      "${CMAKE_CURRENT_LIST_DIR}/test_pb.proto"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/test_pb.proto"
    COMMENT "Generate test_pb.pb,test_pb.pb.h,test_pb.pb.cc into ${CMAKE_CURRENT_BINARY_DIR}")

  list(APPEND MAIN_TEST_SRC_FILES "${CMAKE_CURRENT_BINARY_DIR}/test_pb.pb.cc"
       "${CMAKE_CURRENT_BINARY_DIR}/test_pb.pb.h")
endif()

# Test flatbuffer
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE)
  add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/helloworld_generated.h"
    COMMAND
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE}" -I
      "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/flatbuffers/crosscompiling-host" --cpp --allow-non-utf8 --natural-utf8
      --gen-mutable --gen-object-api --reflect-types --reflect-names -o "${CMAKE_CURRENT_BINARY_DIR}"
      "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/flatbuffers/crosscompiling-host/helloworld.fbs"
    DEPENDS "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/flatbuffers/crosscompiling-host/helloworld.fbs"
    COMMENT "Generate helloworld_generated.h into ${CMAKE_CURRENT_BINARY_DIR}")

  list(APPEND MAIN_TEST_SRC_FILES "${CMAKE_CURRENT_BINARY_DIR}/helloworld_generated.h")
endif()

add_executable(cmake-toolset-test ${MAIN_TEST_SRC_FILES})

if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC)
  target_include_directories(cmake-toolset-test PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
  target_compile_definitions(cmake-toolset-test PRIVATE "HAVE_PROTOBUF=1")
endif()

if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_LINK_NAMES)
  target_compile_definitions(cmake-toolset-test PRIVATE "HAVE_OPENTELEMETRY_CPP=1")
endif()

add_test(NAME cmake-toolset.main-test COMMAND cmake-toolset-test)

target_link_directories(cmake-toolset-test PRIVATE ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
target_link_libraries(
  cmake-toolset-test
  PRIVATE ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_LINK_NAMES}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RAPIDJSON_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_CRYPTO_QUICTLS_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_CRYPTO_BORINGSSL_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_CRYPTO_OSSL_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_SNAPPY_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME}
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_LINK_NAME})

get_target_property(CMAKE_TOOLSE_TEST_LINK_LIBRARIES cmake-toolset-test LINK_LIBRARIES)
message(STATUS "CMAKE_TOOLSE_TEST_LINK_LIBRARIES=${CMAKE_TOOLSE_TEST_LINK_LIBRARIES}")

if(TARGET GTest::gtest_main)
  add_executable(cmake-toolset-gtest gtest.cpp)
  target_link_directories(cmake-toolset-gtest PRIVATE ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
  target_link_libraries(cmake-toolset-gtest PRIVATE GTest::gtest_main)
  add_test(NAME cmake-toolset.gtest-test COMMAND cmake-toolset-test)
else()
  message(FATAL_ERROR "Build GTest failed")
endif()

if(TARGET benchmark::benchmark)
  add_executable(cmake-toolset-benchmark benchmark.cpp)
  target_link_directories(cmake-toolset-benchmark PRIVATE ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
  target_link_libraries(cmake-toolset-benchmark PRIVATE benchmark::benchmark)
  add_test(NAME cmake-toolset.benchmark-test COMMAND cmake-toolset-test)
else()
  message(FATAL_ERROR "Build benchmark failed")
endif()

if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_LUA
   AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_LINK_NAME
   AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC
   AND EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/upb/lua/CMakeLists.txt")

  add_subdirectory("${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/upb/lua")

  set(UPB_COMMAND_OPTIONS
      "--plugin=protoc-gen-upb=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPB}"
      "--plugin=protoc-gen-lua=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_LUA}"
      "--upb_out=${CMAKE_CURRENT_BINARY_DIR}" "--lua_out=${CMAKE_CURRENT_BINARY_DIR}")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPBDEFS)
    list(APPEND UPB_COMMAND_OPTIONS
         "--plugin=protoc-gen-upbdefs=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPBDEFS}"
         "--upbdefs_out=${CMAKE_CURRENT_BINARY_DIR}")
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPB_MINITABLE)
    list(APPEND UPB_COMMAND_OPTIONS
         "--plugin=protoc-gen-upb_minitable=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPB_MINITABLE}"
         "--upb_minitable_out=${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  set(UPB_TEST_GENERATE_CXX_FILES
      "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb.c"
      "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upbdefs.h" "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upbdefs.c")
  set(UPB_TEST_GENERATE_LUA_FILES "${CMAKE_CURRENT_BINARY_DIR}/test_pb_pb.lua"
                                  "${CMAKE_CURRENT_BINARY_DIR}/test_upb-and-lua-binding.lua")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_PROTOC_GEN_UPB_MINITABLE)
    list(APPEND UPB_TEST_GENERATE_CXX_FILES "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb_minitable.h"
         "${CMAKE_CURRENT_BINARY_DIR}/test_pb.upb_minitable.c")
  endif()

  add_custom_command(
    OUTPUT ${UPB_TEST_GENERATE_CXX_FILES} ${UPB_TEST_GENERATE_LUA_FILES}
    COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}" --proto_path "${CMAKE_CURRENT_LIST_DIR}"
            ${UPB_COMMAND_OPTIONS} "${CMAKE_CURRENT_LIST_DIR}/test_pb.proto"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/upb/lua/upb.lua"
            "${CMAKE_CURRENT_BINARY_DIR}"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/test_upb-and-lua-binding.lua"
            "${CMAKE_CURRENT_BINARY_DIR}"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/test_pb.proto"
    COMMENT "Generate ${UPB_TEST_GENERATE_CXX_FILES};${UPB_TEST_GENERATE_LUA_FILES} into ${CMAKE_CURRENT_BINARY_DIR}")

  add_executable(cmake-toolset-upb-and-lua-binding-test ${UPB_TEST_GENERATE_CXX_FILES} upb-and-lua-binding.cpp)

  target_include_directories("cmake-toolset-upb-and-lua-binding-test" PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

  target_link_directories(cmake-toolset-upb-and-lua-binding-test PRIVATE ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
  target_link_libraries(
    "cmake-toolset-upb-and-lua-binding-test" PRIVATE ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_LINK_NAME} upb::lupb
                                                     ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME})

  target_compile_options("cmake-toolset-upb-and-lua-binding-test"
                         PRIVATE "${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS}")

  add_test(
    NAME cmake-toolset.upb-and-lua-binding-test
    COMMAND cmake-toolset-upb-and-lua-binding-test "./test_upb-and-lua-binding.lua"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
endif()
