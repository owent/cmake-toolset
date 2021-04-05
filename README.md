# cmake-toolset

This is a cmake script set for atframework.It contains some utility functions and it can works with [vcpkg][1].

It's recommanded to use [vcpkg][1] if you just want a package manager on x86/x86_64 platform.
But if you want a special version of some package or custom some compile options, you can use this toolset.

> e.g.: If you want to use openssl 1.1.0k and use options ```no-dso no-tests no-external-tests no-shared no-idea no-md4 no-mdc2 no-rc2 no-ssl2 no-ssl3 no-weak-ssl-ciphers```
> Just add these codes below:
>
> ```cmake
> # FindPlatform.cmake and Configure.cmake is sahred by all ports and just need to include once
> include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/FindPlatform.cmake")
> include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/Configure.cmake")
> 
> # openssl options
> set(ATFRAMEWORK_CMAKE_TOOLSET_PORTS_OPENSSL_VERSION "1.1.0k")
> set(ATFRAMEWORK_CMAKE_TOOLSET_PORTS_OPENSSL_OPTIONS "no-dso no-tests no-external-tests no-shared no-idea no-md4 no-mdc2 no-rc2 no-ssl2 no-ssl3 no-weak-ssl-ciphers")
> include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/ssl/openssl/openssl.cmake")
> ```

This toolset also works with iOS toolchain and Android NDK.

[1]: https://github.com/microsoft/vcpkg