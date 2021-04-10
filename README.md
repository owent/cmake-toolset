# cmake-toolset

This is a cmake script set for atframework.It contains some utility functions and it can works with [vcpkg][1].

It's recommanded to use [vcpkg][1] if you just want a package manager on x86/x86_64 platform.
But if you want a special version of some packages or just download packages from custom mirrors, you can use this toolset.

> e.g.: If you want to use openssl 1.1.0k and use options ```no-dso no-tests no-external-tests no-shared no-idea no-md4 no-mdc2 no-rc2 no-ssl2 no-ssl3 no-weak-ssl-ciphers```
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

## Utility Scripts

### ```CompilerOption.cmake```

1. Use lastest C++/C standard.
2. Try to use libc++ and libc++abi when using clang or apple clang
3. Set ```CMAKE_MSVC_RUNTIME_LIBRARY``` into ```MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<NOT:$<STREQUAL:${VCPKG_CRT_LINKAGE},static>>:DLL>``` .
4. Add ```/Zc:__cplusplus``` for MSVC to make ```__cplusplus == _MSVC_LANG``` .
5. Set the default value of ```CMAKE_BUILD_TYPE``` to ```RelWithDebInfo``` .
6. Macro: ```add_compiler_flags_to_var(<VAR_NAME> [options...])```
7. Macro: ```add_compiler_define([KEY=VALUE...])```
8. Macro: ```add_linker_flags_for_runtime([LDFLAGS...])```
9. Macro: ```add_linker_flags_for_all([LDFLAGS...])```
10. Function: ```add_target_properties(<TARGET> <PROPERTY_NAME> [VALUES...])```
11. Function: ```remove_target_properties(<TARGET> <PROPERTY_NAME> [VALUES...])```
12. Function: ```add_target_link_flags(<TARGET> [LDFLAGS...])```
13. Variable ```COMPILER_OPTIONS_TEST_STD_COROUTINE``` : ```TRUE``` when toolchain support C++20 Coroutine.
14. Variable ```COMPILER_OPTIONS_TEST_STD_COROUTINE_TS``` : ```TRUE``` when toolchain experimental support C++20 Coroutine.
15. Variable ```COMPILER_OPTIONS_TEST_EXCEPTION``` : ```TRUE``` when toolchain enable exception support.
16. Variable ```COMPILER_OPTIONS_TEST_STD_EXCEPTION_PTR``` : ```TRUE``` when toolchain support C++11 ```std::exception_ptr``` .
17. Variable ```COMPILER_OPTIONS_TEST_RTTI``` : ```TRUE``` when toolchain enable runtime type information.
18. Variable ```COMPILER_STRICT_CFLAGS``` : flags of all but compatible warnings and turn warning to error.
19. Variable ```COMPILER_STRICT_EXTRA_CFLAGS``` : flags of all extra warnings.

### ```TargetOption.cmake```

1. Variable ```PROJECT_PREBUILT_PLATFORM_NAME``` to flags of all extra warnings.
2. Variable ```PROJECT_PREBUILT_HOST_PLATFORM_NAME``` to flags of all extra warnings.
3. Set the default value of ```CMAKE_ARCHIVE_OUTPUT_DIRECTORY``` to ```${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}``` .
4. Set the default value of ```CMAKE_LIBRARY_OUTPUT_DIRECTORY``` to ```${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}``` .
5. Set the default value of ```CMAKE_RUNTIME_OUTPUT_DIRECTORY``` to ```${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}``` .

## Package ports

### Options and requirements

+ Option(Optional): ```PROJECT_THIRD_PARTY_PACKAGE_DIR``` : Where to place package sources.
+ Option(Optional): ```PROJECT_THIRD_PARTY_INSTALL_DIR``` : Where to place installed packages.
+ Option(Optional): ```FindConfigurePackageGitFetchDepth``` : Fetch depth og git repository.

```cmake
# set(PROJECT_THIRD_PARTY_PACKAGE_DIR "${PROJECT_SOURCE_DIR}/third_party/packages")
# set(PROJECT_THIRD_PARTY_INSTALL_DIR "${PROJECT_SOURCE_DIR}/third_party/install/${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}-${CMAKE_CXX_COMPILER_ID}")
# Import.cmake is required by all ports and just need to include once
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/Import.cmake")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/<package dir>[/package sub dir]/<which package you need>.cmake")
```

### Output

+ Variable: ```ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS``` : Directories to include of all imported packages.
+ Variable: ```ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES``` : Public libraries and targets to link of all imported packages.
+ Variable: ```ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INTERFACE_LINK_NAMES``` : Interface libraries and targets to link of all imported packages.
+ Variable: ```ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN``` : Executable file patterns of all imported packages.

### Package - jemalloc

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE "release")  # debug/release
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION "5.2.1")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_GIT_URL "https://github.com/jemalloc/jemalloc.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/jemalloc/jemalloc.cmake")
```

### Package - fmtlib/std::format

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION "7.1.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_GIT_URL "https://github.com/fmtlib/fmt.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/fmtlib/fmtlib.cmake")
```

### Package - compression

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION "v1.2.11")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_GIT_URL "https://github.com/madler/zlib.git")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION "v1.9.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_GIT_URL "https://github.com/lz4/lz4.git")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_VERSION "v1.4.9")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_GIT_URL "https://github.com/facebook/zstd.git")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/compression/import.cmake")
```

### Package - libuv

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION "v1.41.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_GIT_URL "https://github.com/libuv/libuv.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libuv/libuv.cmake")
```

### Package - libunwind

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION "v1.5")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL "https://github.com/libunwind/libunwind.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libunwind/libunwind.cmake")
```

### Package - rapidjson

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RAPIDJSON_VERSION "47b837e14ab5712fade68e0b00768ff95c120966")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RAPIDJSON_GIT_URL "https://github.com/Tencent/rapidjson.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/rapidjson/rapidjson.cmake")
```

### Package - flatbuffers

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION "47b837e14ab5712fade68e0b00768ff95c120966")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_GIT_URL "https://github.com/Tencent/rapidjson.git")
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
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
#   "-Dprotobuf_BUILD_TESTS=OFF"
#   "-Dprotobuf_BUILD_EXAMPLES=OFF"
#   "-Dprotobuf_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}"
#   "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/protobuf/protobuf.cmake")
```

### Package - crypto(openssl/libressl/mbedtls/libsodium)

```cmake
# ============ crypto - openssl ============
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL) # Not support yet
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS)
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_DISABLED)

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION "1.1.1k")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL "https://github.com/openssl/openssl.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
#   "--release"
#   # "--api=1.1.1" # libwebsockets and atframe_utils has warnings of using deprecated APIs,
#   # maybe it can be remove later "no-deprecated" # libcurl and gRPC requires openssl's API of
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

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION "v3.2.5")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_GIT_URL "https://github.com/libressl-portable/portable.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_FLAGS "-DLIBRESSL_TESTS=OFF")

# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION "v2.26.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_GIT_URL "https://github.com/ARMmbed/mbedtls.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_FLAGS
#   "-DENABLE_TESTING=OFF" "-DUSE_STATIC_MBEDTLS_LIBRARY=ON" "-DENABLE_PROGRAMS=OFF")

include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/ssl/port.cmake")
```

### Package - libcurl

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION "7.76.0")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_GIT_URL "https://github.com/curl/curl.git")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_FLAGS
#   "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_TESTING=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libcurl/libcurl.cmake")
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
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libwebsockets/libwebsockets.cmake")
```

### Package - lua

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION "v5.4.3")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL "https://github.com/lua/lua.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/lua/lua.cmake")
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
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_OPTIONS "-DDISABLE_TESTS=YES" "-DENABLE_EXAMPLES=OFF")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/redis/hiredis.cmake")
```

### Package - libcopp

```cmake
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION "v2")
# set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_GIT_URL "https://github.com/owt5008137/libcopp.git")
include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/libcopp/libcopp.cmake")
```

## CI

+ Format
+ Build shared libries
+ Build static libraries
+ GCC
+ Clang
+ Apple Clang
+ GCC 4.8
+ MinGW
+ VS 2017
+ VS 2019
+ Build openssl
+ Build libressl
+ Build mbedtls

[1]: https://github.com/microsoft/vcpkg