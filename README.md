# cmake-toolset

This is a cmake script set for atframework.It contains some utility functions and it can works with [vcpkg][1].

It's recommanded to use [vcpkg][1] if you just want a package manager on x86/x86_64 platform.
But if you want a special version of some package or custom some compile options, you can use this toolset.

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
+ Variable: ```ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN``` : Executable files of all imported packages.

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

### Package - libunwind

### Package - rapidjson

### Package - flatbuffers

### Package - protobuf

### Package - crypto(openssl/libressl/mbedtls/libsodium)

### Package - libcurl

### Package - libwebsockets

### Package - lua

### Package - yaml-cpp

### Package - hiredis

[1]: https://github.com/microsoft/vcpkg