# cmake-toolset

[![Build](https://github.com/atframework/cmake-toolset/actions/workflows/build.yaml/badge.svg)](https://github.com/atframework/cmake-toolset/actions/workflows/build.yaml)
[![Repo size](https://img.shields.io/github/repo-size/atframework/cmake-toolset)][2]
[![Latest release](https://img.shields.io/github/v/release/atframework/cmake-toolset)][2]
[![Languages](https://img.shields.io/github/languages/count/atframework/cmake-toolset)][2]
[![License](https://img.shields.io/github/license/atframework/cmake-toolset)][2]

[![Discord](https://img.shields.io/discord/846584335921840148)](https://discord.com/channels/846584335921840148)

This is a cmake script set for atframework.It contains some utility functions and it can works with [vcpkg][1].

It's recommanded to use [vcpkg][1] if you do not need cross-compiling and has GCC 6+/Visual Studio 2015 Update 3+ with the English language pack/macOS 10.15+.
But if you want a special version of some packages or just download packages from custom mirrors, you can use this toolset.

> E.g.: If you want to use openssl 1.1.0k and use options ```no-dso no-tests no-external-tests no-shared no-idea no-md4 no-mdc2 no-rc2 no-ssl2 no-ssl3 no-weak-ssl-ciphers```
> Just add these codes below:
>
> ```cmake
> # set(PROJECT_THIRD_PARTY_PACKAGE_DIR "Where to place third party source packages")
> # set(PROJECT_THIRD_PARTY_INSTALL_DIR "Where to place third party installed packages")
> # Import.cmake is required by all ports and just need to include once
> include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")
> 
> # openssl options
> set(ATFRAMEWORK_CMAKE_TOOLSET_PORTS_OPENSSL_VERSION "1.1.0k")
> set(ATFRAMEWORK_CMAKE_TOOLSET_PORTS_OPENSSL_OPTIONS "no-dso no-tests no-external-tests no-shared no-idea no-md4 no-mdc2 no-rc2 no-ssl2 no-ssl3 no-weak-ssl-ciphers")
> include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/ssl/openssl/openssl.cmake")
> ```

This toolset also works with iOS toolchain and Android NDK.

## Quick Start

```cmake
cmake_minimum_required(VERSION 3.16.0)
cmake_policy(SET CMP0022 NEW)
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0067 NEW)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0077 NEW)
cmake_policy(SET CMP0091 NEW)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19.0")
  cmake_policy(SET CMP0111 NEW)
endif()

set(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${PROJECT_SOURCE_DIR}/cmake")

include(FetchContent)
FetchContent_Populate(
    "download-atframework-cmake-toolset"
    SOURCE_DIR "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}"
    GIT_REPOSITORY "https://github.com/atframework/cmake-toolset.git"
    GIT_TAG "origin/main"
    GIT_REMOTE_NAME "origin"
    GIT_SHALLOW TRUE)

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")
```

Or using toolchain

```bash
cmake <where to find CMakeLists.txt> -DCMAKE_TOOLCHAIN_FILE=$ATFRAMEWORK_CMAKE_TOOLSET_DIR/Toolchain.cmake [other options...]

# With vcpkg on x64-linux
cmake <where to find CMakeLists.txt> -DCMAKE_TOOLCHAIN_FILE=$ATFRAMEWORK_CMAKE_TOOLSET_DIR/Toolchain.cmake  \
  -DATFRAMEWORK_CHAINLOAD_TOOLCHAIN_FILE=$VCPKG_INSTALLATION_ROOT/scripts/buildsystems/vcpkg.cmake          \
  -DVCPKG_TARGET_TRIPLET=x64-linux [other options...]
```

## CI Job Matrix

| Name                    | Target System   | Toolchain         | Note                                   |
| ----------------------- | --------------- | ----------------- | -------------------------------------- |
| Format                  | -               |                   |
| gcc.static.test         | Linux           | GCC               | Static linking                         |
| gcc.shared.test         | Linux           | GCC               | Dynamic linking                        |
| gcc.libressl.test       | Linux           | GCC               | Using libressl for SSL porting         |
| gcc.boringssl.test      | Linux           | GCC               | Using boringssl for SSL porting        |
| gcc.mbedtls.test        | Linux           | GCC               | Using mbedtls for SSL porting          |
| gcc.4.8.test            | Linux           | GCC 4.8           | Legacy                                 |
| clang.test              | Linux           | Clang with libc++ |
| gcc.vcpkg.test          | Linux           | GCC With vcpkg    |
| msys2.mingw.static.test | Windows         | GCC               | Static linking                         |
| msys2.mingw.shared.test | Windows         | GCC               | Dynamic linking                        |
| msvc.static.test        | Windows         | MSVC              | Static linking                         |
| msvc.shared.test        | Windows         | MSVC              | Dynamic linking                        |
| msvc.vcpkg.test         | Windows         | MSVC With vcpkg   |
| msvc2017.test           | Windows         | MSVC              | Legacy                                 |
| macos.appleclang.test   | macOS           | Clang with libc++ |
| android.arm64.test      | Android         | Clang with libc++ | ```-DANDROID_ABI=arm64-v8a```          |
| android.x86_64.test     | Android         | Clang with libc++ | ```-DANDROID_ABI=x86_64```             |
| ios.test                | iOS             | Clang with libc++ | ```-DCMAKE_OSX_ARCHITECTURES=arm64```  |
| iphone_simulator.test   | iPhoneSimulator | Clang with libc++ | ```-DCMAKE_OSX_ARCHITECTURES=x86_64``` |

## Utility Scripts

### ```CompilerOption.cmake```

1. Use lastest C++/C standard.
2. Try to use libc++ and libc++abi when using clang or apple clang
3. Set ```CMAKE_MSVC_RUNTIME_LIBRARY``` into ```MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<NOT:$<STREQUAL:${VCPKG_CRT_LINKAGE},static>>:DLL>``` .
4. Add ```/Zc:__cplusplus``` for MSVC to make ```__cplusplus == _MSVC_LANG``` .
5. Set the default value of ```CMAKE_BUILD_TYPE``` to ```RelWithDebInfo``` .
6. Macro: ```add_compiler_flags_to_var(<VAR_NAME> [options...])```
7. Macro: ```add_compiler_flags_to_var_unique(<VAR_NAME> [options...])```
8. Macro: ```add_compiler_flags_to_inherit_var(<VAR_NAME> [options...])```
9. Macro: ```add_compiler_flags_to_inherit_var_unique(<VAR_NAME> [options...])```
10. Macro: ```add_list_flags_to_var(<VAR_NAME> [options...])```
11. Macro: ```add_list_flags_to_var_unique(<VAR_NAME> [options...])```
12. Macro: ```add_list_flags_to_inherit_var(<VAR_NAME> [options...])```
13. Macro: ```add_list_flags_to_inherit_var_unique(<VAR_NAME> [options...])```
14. Macro: ```add_compiler_define([KEY=VALUE...])```
15. Macro: ```add_linker_flags_for_runtime([LDFLAGS...])```
16. Macro: ```add_linker_flags_for_all([LDFLAGS...])```
17. Function: ```add_target_properties(<TARGET> <PROPERTY_NAME> [VALUES...])```
18. Function: ```remove_target_properties(<TARGET> <PROPERTY_NAME> [VALUES...])```
19. Function: ```add_target_link_flags(<TARGET> [LDFLAGS...])```
20. Variable ```COMPILER_OPTIONS_TEST_STD_COROUTINE``` : ```TRUE``` when toolchain support C++20 Coroutine.
21. Variable ```COMPILER_OPTIONS_TEST_STD_COROUTINE_TS``` : ```TRUE``` when toolchain experimental support C++20 Coroutine.
22. Variable ```COMPILER_OPTIONS_TEST_EXCEPTION``` : ```TRUE``` when toolchain enable exception support.
23. Variable ```COMPILER_OPTIONS_TEST_STD_EXCEPTION_PTR``` : ```TRUE``` when toolchain support C++11 ```std::exception_ptr``` .
24. Variable ```COMPILER_OPTIONS_TEST_RTTI``` : ```TRUE``` when toolchain enable runtime type information.
25. Variable ```COMPILER_STRICT_CFLAGS``` : flags of all but compatible warnings and turn warning to error.
26. Variable ```COMPILER_STRICT_EXTRA_CFLAGS``` : flags of all extra warnings.

### ```TargetOption.cmake```

1. Variable ```PROJECT_PREBUILT_PLATFORM_NAME``` : Target platform name.
2. Variable ```PROJECT_PREBUILT_HOST_PLATFORM_NAME``` : Host platform name.
3. Set the default value of ```CMAKE_ARCHIVE_OUTPUT_DIRECTORY``` to ```${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}``` .
4. Set the default value of ```CMAKE_LIBRARY_OUTPUT_DIRECTORY``` to ```${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}``` .
5. Set the default value of ```CMAKE_RUNTIME_OUTPUT_DIRECTORY``` to ```${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}``` .

## Package ports

### Options and requirements

+ Option(Optional): ```PROJECT_THIRD_PARTY_PACKAGE_DIR``` : Where to place package sources.
+ Option(Optional): ```PROJECT_THIRD_PARTY_INSTALL_DIR``` : Where to place installed packages.
+ Option(Optional): ```PROJECT_THIRD_PARTY_HOST_INSTALL_DIR``` : Where to place installed packages of host system.
+ Option(Optional): ```FindConfigurePackageGitFetchDepth``` : Fetch depth og git repository.

```cmake
# set(PROJECT_THIRD_PARTY_PACKAGE_DIR "${PROJECT_SOURCE_DIR}/third_party/packages")
# set(PROJECT_THIRD_PARTY_INSTALL_DIR "${PROJECT_SOURCE_DIR}/third_party/install/${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}-${CMAKE_CXX_COMPILER_ID}")
# Import.cmake is required by all ports and just need to include once
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/<package dir>[/package sub dir]/<which package you need>.cmake")
```

### Package - jemalloc

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE "release")  # debug/release
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION "5.2.1")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_GIT_URL "https://github.com/jemalloc/jemalloc.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/jemalloc/jemalloc.cmake")
```

### Package - algorithm - xxhash

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_VERSION "v0.8.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_GIT_URL "https://github.com/Cyan4973/xxHash.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/algorithm/xxhash.cmake")
```

### Package - fmtlib/std::format

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION "7.1.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_GIT_URL "https://github.com/fmtlib/fmt.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_ALTERNATIVE_STD ON)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DFMT_DOC=OFF" "-DFMT_INSTALL=ON"
#   "-DFMT_TEST=OFF" "-DFMT_FUZZ=OFF" "-DFMT_CUDA_TEST=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/fmtlib/fmtlib.cmake")
```

### Package - compression

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION "v1.2.11")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_GIT_URL "https://github.com/madler/zlib.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_TESTING=OFF")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION "v1.9.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_GIT_URL "https://github.com/lz4/lz4.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DLZ4_POSITION_INDEPENDENT_LIB=ON"
#   "-DLZ4_BUILD_CLI=ON" "-DLZ4_BUILD_LEGACY_LZ4C=ON" "-DCMAKE_DEBUG_POSTFIX=d")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_VERSION "1.1.9")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_GIT_URL "https://github.com/google/snappy.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
#   "-DSNAPPY_BUILD_TESTS=OFF"
#   "-DSNAPPY_BUILD_BENCHMARKS=OFF"
#   "-DSNAPPY_FUZZING_BUILD=OFF"
#   "-DSNAPPY_INSTALL=ON")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_VERSION "v1.5.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_GIT_URL "https://github.com/facebook/zstd.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
#   "-DZSTD_BUILD_TESTS=OFF"
#   "-DZSTD_BUILD_CONTRIB=0"
#   "-DCMAKE_DEBUG_POSTFIX=d"
#   "-DZSTD_BUILD_PROGRAMS=ON"
#   "-DZSTD_MULTITHREAD_SUPPORT=ON"
#   "-DZSTD_ZLIB_SUPPORT=ON"
#   "-DZSTD_LZ4_SUPPORT=ON")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/compression/import.cmake")
```

### Package - libuv

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION "v1.41.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_GIT_URL "https://github.com/libuv/libuv.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_TESTING=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libuv/libuv.cmake")
```

### Package - libunwind

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION "v1.5")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL "https://github.com/libunwind/libunwind.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libunwind/libunwind.cmake")
```

### Package - GTest

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_VERSION "release-1.10.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GIT_URL "https://github.com/google/googletest.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_GMOCK=ON" "-DINSTALL_GTEST=ON")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/test/gtest.cmake")
```

### Package - benchmark

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BENCHMARK_VERSION "v1.5.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BENCHMARK_GIT_URL "https://github.com/google/benchmark.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BENCHMARK_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBENCHMARK_ENABLE_TESTING=OFF"
#   "-DBENCHMARK_ENABLE_LTO=OFF" "-DBENCHMARK_ENABLE_INSTALL=ON"
#   "-DALLOW_DOWNLOADING_GOOGLETEST=ON" "-DBENCHMARK_ENABLE_GTEST_TESTS=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/test/benchmark.cmake")
```

### Package - rapidjson

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RAPIDJSON_VERSION "47b837e14ab5712fade68e0b00768ff95c120966")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RAPIDJSON_GIT_URL "https://github.com/Tencent/rapidjson.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RAPIDJSON_BUILD_OPTIONS
#   "-DRAPIDJSON_BUILD_DOC=OFF" "-DRAPIDJSON_BUILD_EXAMPLES=OFF" "-DRAPIDJSON_BUILD_TESTS=OFF"
#   "-DRAPIDJSON_BUILD_THIRDPARTY_GTEST=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/json/rapidjson.cmake")
```

### Package - nlohmann_json

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_VERSION "v3.9.1")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_GIT_URL "https://github.com/nlohmann/json.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS
#   "-DJSON_Install=ON" "-DJSON_BuildTests=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/json/nlohmann_json.cmake")
```

### Package - flatbuffers

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION "v1.12.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_GIT_URL "https://github.com/google/flatbuffers.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS
#   -DFLATBUFFERS_CODE_COVERAGE=OFF
#   -DFLATBUFFERS_BUILD_TESTS=OFF
#   -DFLATBUFFERS_INSTALL=ON
#   -DFLATBUFFERS_BUILD_FLATLIB=ON
#   -DFLATBUFFERS_BUILD_FLATC=ON
#   -DFLATBUFFERS_BUILD_FLATHASH=ON
#   -DFLATBUFFERS_BUILD_GRPCTEST=OFF
#   -DFLATBUFFERS_BUILD_SHAREDLIB=OFF)
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/flatbuffers/flatbuffers.cmake")
```

### Package - protobuf

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.15.8")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL "https://github.com/protocolbuffers/protobuf.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS OFF CACHE BOOL
#   "Allow build protobuf as dynamic(May cause duplicate symbol in global data base.[File already exists in database])"
# )
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
#   "-Dprotobuf_BUILD_TESTS=OFF"
#   "-Dprotobuf_BUILD_EXAMPLES=OFF"
#   "-Dprotobuf_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"
#   "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/protobuf/protobuf.cmake")
```

### Package - crypto(openssl/boringssl/libressl/mbedtls/libsodium)

```cmake
# ============ crypto - openssl ============
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_DISABLED)

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION "3.0.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL "https://github.com/openssl/openssl.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
#   # "--api=1.1.1"
#   "--release"
#   # libcurl and gRPC requires openssl's API of
#   # 1.1.0 and 1.0.2, so we can not disable deprecated APIS here
#   "no-dso"
#   "no-tests"
#   "no-external-tests"
#   "no-shared"
#   "no-idea"
#   "no-md4"
#   "no-mdc2"
#   "no-rc2"
#   "no-ssl2"
#   "no-ssl3"
#   "no-weak-ssl-ciphers"
#   "enable-static-engine")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_VERSION "479adf98d54a21c1d154aac59b2ce120e1d1a6d6")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_GIT_URL "https://github.com/google/boringssl.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_SHARED_LIBS=OFF" "-DGO_EXECUTABLE=${GO_EXECUTABLE}"
#   "-DPERL_EXECUTABLE=${PERL_EXECUTABLE}")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION "3.3.1")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_TAR_URL_BASE "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_FLAGS "-DLIBRESSL_TESTS=OFF")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION "v2.26.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_GIT_URL "https://github.com/ARMmbed/mbedtls.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_FLAGS
#   "-DENABLE_TESTING=OFF" "-DUSE_STATIC_MBEDTLS_LIBRARY=ON" "-DENABLE_PROGRAMS=OFF")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/ssl/port.cmake")
```

### Package - c-ares

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION "1.17.1")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_GIT_URL "https://github.com/c-ares/c-ares.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS
#  "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DCARES_STATIC_PIC=ON")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/cares/c-ares.cmake")
```

### Package - re2

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_VERSION "2021-04-01")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_GIT_URL "https://github.com/google/re2.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_BUILD_OPTIONS 
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DRE2_BUILD_TESTING=OFF")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/re2/re2.cmake")
```

### Package - libcurl

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION "7.76.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_GIT_URL "https://github.com/curl/curl.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_DISABLE_ARES OFF)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_FLAGS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_TESTING=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libcurl/libcurl.cmake")
```

### Package - civetweb

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_VERSION "v1.14")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_GIT_URL "https://github.com/civetweb/civetweb.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
#   "-DCIVETWEB_BUILD_TESTING=OFF"
#   "-DCIVETWEB_ENABLE_DEBUG_TOOLS=OFF"
#   "-DCIVETWEB_ENABLE_ASAN=OFF"
#   "-DCIVETWEB_ENABLE_CXX=ON"
#   "-DCIVETWEB_ENABLE_IPV6=ON"
#   "-DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF"
#   "-DCIVETWEB_ENABLE_WEBSOCKETS=ON")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/web/civetweb.cmake")
```

### Package - libwebsockets

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION "v4.1.6")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_URL "https://github.com/warmcat/libwebsockets.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
#   "-DLWS_STATIC_PIC=ON"
#   "-DLWS_LINK_TESTAPPS_DYNAMIC=OFF"
#   "-DLWS_WITHOUT_CLIENT=ON"
#   "-DLWS_WITHOUT_DAEMONIZE=ON"
#   "-DLWS_WITHOUT_TESTAPPS=ON"
#   "-DLWS_WITHOUT_TEST_CLIENT=ON"
#   "-DLWS_WITHOUT_TEST_PING=ON"
#   "-DLWS_WITHOUT_TEST_SERVER=ON"
#   "-DLWS_WITHOUT_TEST_SERVER_EXTPOLL=ON"
#   "-DLWS_WITH_PLUGINS=ON"
#   "-DLWS_WITHOUT_EXTENSIONS=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/web/libwebsockets.cmake")
```

### Package - lua

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION "v5.4.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL "https://github.com/lua/lua.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/lua/lua.cmake")
```

### Package - Microsoft.GSL

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_VERSION "v3.1.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_GIT_URL "https://github.com/microsoft/GSL.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_BUILD_OPTIONS "-DGSL_TEST=OFF" "-DGSL_INSTALL=ON")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/gsl/ms-gsl.cmake")
```

### Package - gsl-lite

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_VERSION "v0.38.1")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_GIT_URL "https://github.com/gsl-lite/gsl-lite.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_BUILD_OPTIONS
#   "-DGSL_LITE_OPT_BUILD_TESTS=OFF"
#   "-DGSL_LITE_OPT_BUILD_CUDA_TESTS=OFF"
#   "-DGSL_LITE_OPT_BUILD_EXAMPLES=OFF"
#   "-DGSL_LITE_OPT_BUILD_STATIC_ANALYSIS_DEMOS=OFF"
#   "-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF"
#   "-DGSL_LITE_OPT_INSTALL_COMPAT_HEADER=OFF"
#   "-DGSL_LITE_OPT_INSTALL_LEGACY_HEADERS=OFF"
# )
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/gsl/gsl-lite.cmake")
```

### Package - yaml-cpp

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION "0.6.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_GIT_URL "https://github.com/jbeder/yaml-cpp.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/yaml-cpp/yaml-cpp.cmake")
```

### Package - hiredis

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION "2a5a57b90a57af5142221aa71f38c08f4a737376") # v1.0.0 with some patch
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_GIT_URL "https://github.com/redis/hiredis.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS "-DDISABLE_TESTS=YES" "-DENABLE_EXAMPLES=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/redis/hiredis.cmake")
```

### Package - libcopp

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION "v2")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_GIT_URL "https://github.com/owent/libcopp.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libcopp/libcopp.cmake")
```

### Package - gRPC

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20210324.2")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_GIT_URL "https://github.com/abseil/abseil-cpp.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS
#   "-DgRPC_INSTALL_CSHARP_EXT=OFF" "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_TESTING=OFF")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.38.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL "https://github.com/grpc/grpc.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DgRPC_INSTALL=ON")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/grpc/import.cmake")
```

### Package - prometheus-cpp

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_VERSION "v0.12.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_GIT_URL "https://github.com/jupp0r/prometheus-cpp.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DENABLE_TESTING=OFF"
#   "-DUSE_THIRDPARTY_LIBRARIES=OFF" "-DRUN_IWYU=OFF" "-DENABLE_WARNINGS_AS_ERRORS=OFF")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/telemetry/prometheus-cpp.cmake")
```

### Package - opentelemetry-cpp

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION "v1.0.0-rc3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_GIT_URL "https://github.com/open-telemetry/opentelemetry-cpp.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL OFF)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ABSEIL ON)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP ON)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ELASTICSEARCH ON)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZIPKIN ON)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_PROMETHEUS OFF)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
#   "-Dprotobuf_MODULE_COMPATIBLE=ON" "-DBUILD_TESTING=OFF" "-DWITH_EXAMPLES=OFF")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/telemetry/opentelemetry-cpp.cmake")
```

## Custom ports

### Add custom ports from git as subdirectory

```cmake
include_guard(GLOBAL)

macro(PROJECT_<PACKAGE NAME:UPPERCASE>_IMPORT)
  if(TARGET <target to link>)
    echowithcolor(COLOR GREEN "-- Dependency: <target to link> found.(Target: <target to link>)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_LINK_NAME <target to link>)
  endif()
endmacro()

if(NOT TARGET <target to link>)
  project_third_party_port_declare(<package name>
    VERSION "<package version>"
    GIT_URL "<git url>")

  project_git_clone_repository(
    URL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_GIT_URL}" REPO_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_SRC_DIRECTORY_NAME}" TAG
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_VERSION}")

  add_subdirectory(
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_SRC_DIRECTORY_NAME}"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_BUILD_DIR}")
  project_<package name:lowercase>_import()
else()
  project_<package name:lowercase>_import()
endif()
```

### Add custom ports from submodule as subdirectory

```cmake
include_guard(GLOBAL)

macro(PROJECT_<PACKAGE NAME:UPPERCASE>_IMPORT)
  if(TARGET <target to link>)
    echowithcolor(COLOR GREEN "-- Dependency: <target to link> found.(Target: <target to link>)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_LINK_NAME <target to link>)
  endif()
endmacro()

if(NOT TARGET <target to link>)
  if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/_deps/<package name>")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/_deps/<package name>")
  endif()
  maybe_populate_submodule(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE> "<submodule path>" "${PROJECT_SOURCE_DIR}/<submodule path>")
  add_subdirectory("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_REPO_DIR}"
                   "${CMAKE_CURRENT_BINARY_DIR}/_deps/<package name>")
  project_<package name:lowercase>_import()
else()
  project_<package name:lowercase>_import()
endif()
```

### Add custom ports from git and install it

```cmake
include_guard(GLOBAL)

macro(PROJECT_<PACKAGE NAME:UPPERCASE>_IMPORT)
  if(TARGET <target to link>)
    echowithcolor(COLOR GREEN "-- Dependency: <target to link> found.(Target: <target to link>)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_LINK_NAME <target to link>)
  endif()
endmacro()

if(NOT TARGET <target to link>)
  project_third_party_port_declare(<package name>
    VERSION "<package version>"
    GIT_URL "<git url>"
    BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      # Other default options
  )

  project_third_party_append_build_shared_lib_var(<package name> "[PREFIX, left empty string for none]"
                                                    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_PATCH_FILE}")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_PATCH_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_PATCH_FILE}")
  else()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_PATCH_OPTIONS)
  endif()

  find_configure_package(
      PACKAGE
      <package name>
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      # CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS    # For CXX only project
      # CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS  # For C only project
      # CMAKE_INHERIT_BUILD_ENV_DISABLE_ASM_FLAGS
      # CMAKE_INHERIT_FIND_ROOT_PATH              # Need to find dependency from install path
      # CMAKE_INHERIT_SYSTEM_LINKS                # Nedd to link system libraries
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_BUILD_OPTIONS}
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_PATCH_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_SRC_DIRECTORY_NAME}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_SRC_DIRECTORY_NAME}" # Where to find CMakeLists.txt
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_<PACKAGE NAME:UPPERCASE>_GIT_URL}")

    project_third_party_<target to link>_import()
else()
  project_<package name:lowercase>_import()
endif()
```

[1]: https://github.com/microsoft/vcpkg
[2]: https://github.com/atframework/cmake-toolset
