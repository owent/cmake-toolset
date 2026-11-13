include_guard(DIRECTORY)

# =========== third party openssl ==================

macro(PROJECT_THIRD_PARTY_OPENSSL_IMPORT)
  if(OPENSSL_FOUND OR OpenSSL_FOUND)
    message(STATUS "Dependency(${PROJECT_NAME}): openssl found.(${OPENSSL_VERSION})")
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME)
    if(TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto)
      if(TARGET OpenSSL::SSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::SSL)

        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES Threads::Threads
                                                                      ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES ${CMAKE_DL_LIBS})
        endif()
      endif()
      if(TARGET OpenSSL::Crypto)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::Crypto)

        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES Threads::Threads
                                                                      ${CMAKE_DL_LIBS})
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME Threads::Threads ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES ${CMAKE_DL_LIBS})
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME ${CMAKE_DL_LIBS})
        endif()
      endif()
    else()
      if(NOT OPENSSL_LIBRARIES)
        set(OPENSSL_LIBRARIES
            ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY}
            CACHE INTERNAL "Fix cmake module path for openssl" FORCE)
      endif()
      if(OPENSSL_LIBRARIES)
        add_library(OpenSSL::Crypto UNKNOWN IMPORTED)
        set_target_properties(OpenSSL::Crypto PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
        set_target_properties(OpenSSL::Crypto PROPERTIES IMPORTED_LOCATION ${OPENSSL_CRYPTO_LIBRARIES})
        add_library(OpenSSL::SSL UNKNOWN IMPORTED)
        set_target_properties(OpenSSL::SSL PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
        set_target_properties(OpenSSL::SSL PROPERTIES IMPORTED_LOCATION ${OPENSSL_SSL_LIBRARIES} OpenSSL::Crypto)

        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::SSL OpenSSL::Crypto)
      endif()
    endif()

    if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND "bcrypt" IN_LIST ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LIBRARIES)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME "bcrypt")
    endif()

    find_program(
      OPENSSL_EXECUTABLE
      NAMES openssl openssl.exe
      PATHS "${OPENSSL_INCLUDE_DIR}/../bin" "${OPENSSL_INCLUDE_DIR}/../" ${OPENSSL_INCLUDE_DIR}
      NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL
          TRUE
          CACHE BOOL "Cache ssl selector and directly use openssl next time")
    endif()
  endif()
endmacro()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME)
  if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ENABLE_QUIC
     AND NOT DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ENABLE_QUIC})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ENABLE_QUIC TRUE)
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION)
    # OpenSSL 3.3 support quic but do not support HTTP/3
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION "3.5.9") # Latest LTS stable version
    # OpenSSL 3.0.0 has some problems with nmake and MSVC when installing
    if(CMAKE_VERSION VERSION_LESS "3.18.0") # OR MSVC
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION "1.1.1w")
    endif()
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL)
    # OpenSSL 3.3 support quic but do not support HTTP/3
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ENABLE_QUIC
       AND (ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_LESS "3.2.0"
            OR ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_EQUAL "3.3.0"))
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL "https://github.com/quictls/openssl.git")
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL "https://github.com/openssl/openssl.git")
    endif()
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG
        "openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}")
  else()
    string(REPLACE "." "_" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG
                   "OpenSSL_${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}")
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ENABLE_QUIC
     AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL MATCHES "github.com/quictls/openssl")
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.8"
       OR (ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION MATCHES "1\\.*"
           AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_GREATER_EQUAL "1.1.1t"))
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG}-quic1")
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG}+quic1")
    endif()
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR)
    project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR "openssl"
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION})
  endif()

  # "no-hw" and "no-engine" is recommanded by openssl only for mobile devices @see
  # https://wiki.openssl.org/index.php/Compilation_and_Installation
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PREFIX_OPTIONS
      "--prefix=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      "--openssldir=ssl"
      # FindOpenSSL.cmake only use lib as PATH_SUFFIX, and do not use pkg-config on no-unix like system So we should
      # always install libraries into <prefix>/lib
      "--libdir=lib")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PREFIX_OPTIONS}
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS})
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PREFIX_OPTIONS}
        # "--api=1.1.1"
        "--release"
        # "no-deprecated" # libcurl and gRPC requires openssl's API of 1.1.0 and 1.0.2, so we can not disable deprecated
        # APIS here
        "no-dso"
        "no-tests"
        "no-external-tests"
        "no-idea"
        "no-md4"
        "no-mdc2"
        "no-rc2"
        "no-ssl3"
        "no-weak-ssl-ciphers")
    # No deprecated options
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "no-ssl2")
    endif()
    if(NOT ANDROID
       AND NOT MSVC
       AND CMAKE_SIZEOF_VOID_P EQUAL 8)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "enable-ec_nistp_64_gcc_128")
    endif()

    project_third_party_check_build_shared_lib("openssl" "CRYPTO"
                                               ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_SHARED)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_SHARED)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "no-shared")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "shared")
    endif()

    if(CMAKE_CROSSCOMPILING)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "no-comp" "no-hw" "no-engine")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "enable-static-engine")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_APPEND_DEFAULT_BUILD_OPTIONS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_APPEND_DEFAULT_BUILD_OPTIONS})
    endif()
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM
     AND (NOT DEFINED ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM}
          OR NOT ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_WITH_SYSTEM}))
    set(OPENSSL_ROOT_DIR "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  endif()

  find_package(OpenSSL QUIET)
  project_third_party_openssl_import()

  # Restore if OpenSSL is found in a different path
  if(NOT OPENSSL_ROOT_DIR
     AND NOT OPENSSL_FOUND
     AND NOT OpenSSL_FOUND)
    find_library(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_CRYPTO
      NAMES crypto libcrypto
      PATHS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
      NO_DEFAULT_PATH)
    find_library(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_SSL
      NAMES ssl libssl
      PATHS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
      NO_DEFAULT_PATH)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_CRYPTO
       AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_SSL)
      set(OPENSSL_ROOT_DIR "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
      # set(OPENSSL_USE_STATIC_LIBS TRUE)
      find_package(OpenSSL QUIET)
    else()
      message(
        STATUS
          "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_CRYPTO -- ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_CRYPTO}"
      )
      message(
        STATUS
          "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_SSL    -- ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_SSL}"
      )
    endif()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_CRYPTO CACHE)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_FIND_LIB_SSL CACHE)
  endif()

  if(NOT OPENSSL_FOUND AND NOT OpenSSL_FOUND)
    find_package(Perl)
  endif()
  if(NOT OPENSSL_FOUND
     AND NOT OpenSSL_FOUND
     AND PERL_FOUND)
    message(STATUS "Try to configure and use openssl")
    unset(OPENSSL_FOUND CACHE)
    unset(OPENSSL_EXECUTABLE CACHE)
    unset(OPENSSL_INCLUDE_DIR CACHE)
    unset(OPENSSL_CRYPTO_LIBRARY CACHE)
    unset(OPENSSL_CRYPTO_LIBRARIES CACHE)
    unset(OPENSSL_SSL_LIBRARY CACHE)
    unset(OPENSSL_SSL_LIBRARIES CACHE)
    unset(OPENSSL_LIBRARIES CACHE)
    unset(OPENSSL_VERSION CACHE)

    # Cross compiling a unix like target(such as Android or Linux) from a Windows host requires a perl that produces
    # unix style paths, because openssl's Configurations/unix-checker.pm rejects native Win32 perl(such as Strawberry
    # Perl). Use the perl bundled with the detected bash(it's from Git for Windows on Windows hosts and produces unix
    # style paths). That perl is stripped down, stubs for the modules required by openssl's Configure but missing from
    # it are provided in "${CMAKE_CURRENT_LIST_DIR}/perl-stub" and injected via PERL5LIB. The POSIX style path is used
    # for the interpreter, so that the Makefile generated by Configure can also execute it from the bash driven build
    # scripts.
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL "${PERL_EXECUTABLE}")
    if(CMAKE_CROSSCOMPILING
       AND CMAKE_HOST_WIN32
       AND NOT WIN32)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUNDLED_PERL CACHE)
      get_filename_component(_openssl_bash_dir "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}" DIRECTORY)
      find_program(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUNDLED_PERL
        NAMES perl perl.exe
        PATHS "${_openssl_bash_dir}" "${_openssl_bash_dir}/../usr/bin"
        NO_DEFAULT_PATH)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUNDLED_PERL)
        message(FATAL_ERROR "Can not find the perl bundled with the bash(${ATFRAMEWORK_CMAKE_TOOLSET_BASH}). "
                            "The bash on Windows hosts comes from Git for Windows, please check its installation.")
      endif()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUNDLED_PERL MATCHES "/usr/bin/")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL "/usr/bin/perl")
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL "/bin/perl")
      endif()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL5LIB "${CMAKE_CURRENT_LIST_DIR}/perl-stub")
    endif()

    # Convert windows style paths to POSIX style(/c/dir) at configure time, it's a no-op on other platforms: the bundled
    # perl(Git for Windows) and the bash scripts generated below require POSIX style paths, because drive letter colons
    # break their list variables(such as PATH and PERL5LIB) and the unix style path math in openssl's Configure and the
    # NDK detection.
    function(project_third_party_openssl_to_posix_style_path out_var input_path)
      set(_openssl_posix_path "${input_path}")
      if(_openssl_posix_path MATCHES "^([A-Za-z]):[/\\\\](.*)")
        string(TOLOWER "${CMAKE_MATCH_1}" _openssl_posix_drive)
        string(REPLACE "\\" "/" _openssl_posix_rest "${CMAKE_MATCH_2}")
        set(_openssl_posix_path "/${_openssl_posix_drive}/${_openssl_posix_rest}")
      endif()
      set(${out_var}
          "${_openssl_posix_path}"
          PARENT_SCOPE)
    endfunction()

    function(project_third_party_openssl_generate_load_env_bash output_file)
      if(CMAKE_CROSSCOMPILING
         AND CMAKE_HOST_WIN32
         AND NOT WIN32)
        # OpenSSL's Unix Makefile needs a colon-separated target RPATH and doubled dollars for Make expansion. Keep the
        # adjustment local to this environment, leaving the parent CMake project's RPATH unchanged.
        string(REPLACE ";" ":" CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}")
        string(REPLACE "$" "$$" CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}")
      endif()
      project_third_party_generate_load_env_bash("${output_file}")
    endfunction()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR)
      if(WIN32
         AND NOT MINGW
         AND NOT CYGWIN)
        get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_ROOT
                               "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}" DIRECTORY)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_ROOT MATCHES
           "openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}[\\/]?\$")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_ROOT}/source")
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_ROOT}/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}-source"
          )
        endif()
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR
            "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}"
        )
      endif()
    endif()

    project_git_clone_repository(
      URL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL}" REPO_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}" TAG
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GITHUB_TAG}")

    if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}")
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Build openssl failed")
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): openssl is required")
    endif()

    # Patch build.info file to fix libdir on some platforms
    if(EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/build.info")
      file(READ "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/build.info"
           ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_INFO)
      string(
        REGEX
        REPLACE "LIBDIR=([ \t\r\n\\\\\"'])" "LIBDIR=\$(LIBDIR)\\1"
                ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_INFO
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_INFO}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/build.info"
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_INFO}")
    endif()

    if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR})
      file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR})
    endif()

    if(MSVC)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_MULTI_CORE "/MP")
    else()
      cmake_host_system_information(RESULT CPU_CORE_NUM QUERY NUMBER_OF_PHYSICAL_CORES)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_MULTI_CORE "-j${CPU_CORE_NUM}")
      unset(CPU_CORE_NUM)
    endif()
    # 服务器目前不需要适配ARM和android
    if(NOT MSVC)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "config")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.sh"
           "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.sh"
           "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      project_third_party_openssl_generate_load_env_bash(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh")
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.sh"
        "set -x${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        "source \"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.sh"
        "source \"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        "set -x${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.sh")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.sh")

      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
        "export PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL5LIB)
        # Copy the stub modules into the build directory and use a relative PERL5LIB: MSYS converts path like
        # environment variables(absolute POSIX paths) back to windows style when spawning native tools(such as make),
        # which breaks the list split of the bundled perl again. A relative name survives all the path conversions and
        # is resolved against the working directory of every perl invocation(Configure and all the Makefile rules run in
        # the build directory).
        file(COPY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL5LIB}"
             DESTINATION "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}")
        file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
             "export PERL5LIB=\"perl-stub\${PERL5LIB:+:\$PERL5LIB}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      endif()

      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS)
        if(DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS})
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS
              "$CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS}")
        elseif(DEFINED ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS}
               AND ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS})
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS
              "$ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS}")
        endif()
      endif()
      # Android flags is set by NDK toolchain
      if(NOT ANDROID AND NOT "${PROJECT_PREBUILT_PLATFORM_NAME}" STREQUAL "${PROJECT_PREBUILT_HOST_PLATFORM_NAME}")
        # OpenSSL invokes the compiler outside CMake, so it must receive Clang's cross target explicitly.
        if(CMAKE_C_COMPILER_TARGET AND CMAKE_C_COMPILER_ID MATCHES "Clang")
          add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS
                                    "--target=${CMAKE_C_COMPILER_TARGET}")
        endif()
        if(CMAKE_OSX_SYSROOT)
          add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS "-isysroot"
                                    "${CMAKE_OSX_SYSROOT}")
        elseif(CMAKE_SYSROOT)
          add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS "-isysroot"
                                    "${CMAKE_SYSROOT}")
        endif()

        if(CMAKE_OSX_DEPLOYMENT_TARGET)
          add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS
                                    "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
        endif()

        if(CMAKE_OSX_ARCHITECTURES)
          add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS
                                    "-arch ${CMAKE_OSX_ARCHITECTURES}")
        endif()
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN)
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VISIBILITY_HIDDEN
           AND NOT DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VISIBILITY_HIDDEN})
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VISIBILITY_HIDDEN
              ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN})
        endif()
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VISIBILITY_HIDDEN)
        if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
          add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS "-fvisibility=hidden")
        endif()
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS)
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
          "export CFLAGS=\"\$CFLAGS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        )
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
          "export CXXFLAGS=\"\$CXXFLAGS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        )
      endif()
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CFLAGS)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_LDFLAGS)
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
          "export LDFLAGS=\"\$LDFLAGS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_LDFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        )
      endif()
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_LDFLAGS)

      # Some ASM code may do not support -fPIC
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_SHARED)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "no-asm")
      endif()

      if(ANDROID)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "no-stdio")
        file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
             "export PATH=\"\$(dirname \"\$CC\"):\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
             "export CC=\"\$(basename \"\$CC\")\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        if(CMAKE_HOST_WIN32)
          # The bundled perl(Git for Windows) splits PATH and matches the NDK detection paths in POSIX style, re-export
          # the toolchain paths in POSIX style(converted at configure time). The Windows NDK only provides .cmd/.exe
          # binutils, which can not be detected by openssl's NDK toolchain probing(it looks for extension-less tools),
          # use the llvm tools explicitly instead(they are overridden to the same values when the probing succeeds).
          project_third_party_openssl_to_posix_style_path(_openssl_android_ndk_posix "${ANDROID_NDK}")
          project_third_party_openssl_to_posix_style_path(_openssl_android_toolchain_posix "${ANDROID_TOOLCHAIN_ROOT}")
          file(
            APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
            "export ANDROID_NDK=\"${_openssl_android_ndk_posix}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export ANDROID_NDK_HOME=\"${_openssl_android_ndk_posix}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export ANDROID_NDK_ROOT=\"${_openssl_android_ndk_posix}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export PATH=\"${_openssl_android_toolchain_posix}/bin:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export AR=\"llvm-ar\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export RANLIB=\":\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        endif()

        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET)
          if(CMAKE_ANDROID_ARCH_ABI MATCHES "^armeabi(-v7a)?$")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET android-arm)
          elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL arm64-v8a)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET android-arm64)
          elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET android-x86)
          elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86_64)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET android-x86_64)
          elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL mips)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET android-mips)
          elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL mips64)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET android-mips64)
          else()
            message(FATAL_ERROR "Invalid Android ABI: ${CMAKE_ANDROID_ARCH_ABI}.")
          endif()
        endif()

        # @see https://wiki.openssl.org/images/7/70/Setenv-android.sh @see https://wiki.openssl.org/index.php/Android
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
          "export SYSTEM=\"android\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
          "export ANDROID_API=\"${ANDROID_PLATFORM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
          # "export ARCH=\"${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
          # CROSS_COMPILE=\"\$ANDROID_TOOLCHAIN_PREFIX\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
          # ANDROID_SYSROOT=\"\$ANDROID_SYSTEM_LIBRARY_PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
          # CROSS_SYSROOT=\"\$ANDROID_SYSTEM_LIBRARY_PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
          # NDK_SYSROOT=\"\$ANDROID_SYSTEM_LIBRARY_PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
          # SYSROOT=\"\$ANDROID_SYSTEM_LIBRARY_PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        )
        if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION VERSION_GREATER_EQUAL "1.1.1")
          if(ANDROID_TOOLCHAIN_PREFIX)
            file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
                 "CROSS_COMPILE=\"${ANDROID_TOOLCHAIN_PREFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          else()
            if(NOT ANDROID_TOOLCHAIN_NAME)
              if(CMAKE_ANDROID_ARCH_ABI STREQUAL armeabi-v7a)
                set(ANDROID_TOOLCHAIN_NAME arm-linux-androideabi)
              elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL arm64-v8a)
                set(ANDROID_TOOLCHAIN_NAME aarch64-linux-android)
              elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86)
                set(ANDROID_TOOLCHAIN_NAME i686-linux-android)
              elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86_64)
                set(ANDROID_TOOLCHAIN_NAME x86_64-linux-android)
              else()
                message(FATAL_ERROR "Invalid Android ABI: ${ANDROID_ABI}.")
              endif()
            endif()
            file(
              APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-load-envs.sh"
              "CROSS_COMPILE=\"${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_NAME}-\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            )
          endif()
        endif()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")

        if(ANDROID_PLATFORM_LEVEL)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
               "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}")
        else()
          string(REPLACE "android-" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ANDROID_PLATFORM_LEVEL
                         ${ANDROID_PLATFORM})
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
               "-D__ANDROID_API__=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_ANDROID_PLATFORM_LEVEL}")
        endif()
      elseif(CMAKE_OSX_ARCHITECTURES)
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET)
          if(CMAKE_OSX_ARCHITECTURES MATCHES "armv7(s?)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "ios-cross")
          elseif(CMAKE_OSX_ARCHITECTURES MATCHES "arm64.*")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "ios64-cross")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")
          elseif(CMAKE_OSX_ARCHITECTURES MATCHES "i(3|6)86")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "darwin-i386-cc")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")
          elseif(CMAKE_OSX_ARCHITECTURES STREQUAL x86_64)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "darwin64-x86_64-cc")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")
          else()
            message(FATAL_ERROR "Invalid OSX ABI: ${CMAKE_OSX_ARCHITECTURES}.")
          endif()
        endif()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")
      elseif(
        CMAKE_SYSTEM_NAME STREQUAL "Linux"
        AND CMAKE_CROSSCOMPILING
        AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        # `config` detects the target by running uname of the host, which can not work when cross compiling on a
        # non-Unix host. We must always use an explicit target there.
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET)
          if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "linux-x86_64")
          elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "linux-aarch64")
          elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm|ARM)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "linux-armv4")
          elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i.86|x86|X86)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "linux-x86")
          elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(riscv64)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "linux-riscv64")
          elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(loongarch64)")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "linux64-loongarch")
          else()
            message(
              FATAL_ERROR
                "Unsupported Linux target for OpenSSL cross compiling: CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}"
            )
          endif()
        endif()
      endif()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET}")
      endif()
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL STREQUAL "${PERL_EXECUTABLE}")
        # Invoke Configure through a path relative to the build directory when using the bundled perl: the dependency
        # list in the generated Makefile records the configuration files with the same form as the Configure script
        # path, and the native make(such as GNU Make for Windows used by this port) can not resolve absolute POSIX style
        # paths such as /d/dir.
        file(
          RELATIVE_PATH
          _openssl_configure_script
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG}"
        )
      else()
        set(_openssl_configure_script
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG}"
        )
      endif()
      project_expand_list_for_command_line_to_file(
        BASH
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.sh"
        # Calling the perl interpreter explicitly instead of relying on the shebang line, so that we always use the
        # selected perl(a unix style one when cross compiling a unix like target from a Windows host, see above). The
        # shebang may resolve to a limited perl without the modules required by Configure, such as the one shipped with
        # Git for Windows.
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PERL}"
        "${_openssl_configure_script}"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS})

      # We must use make here even if parent project use ninja or other make program here
      project_build_tools_find_make_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_MAKE)
      project_expand_list_for_command_line_to_file(
        BASH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.sh"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_MAKE}"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_MULTI_CORE})
      project_expand_list_for_command_line_to_file(
        BASH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.sh"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_MAKE}" "install_sw" "install_ssldirs")

      # build & install
      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.sh"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.sh"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG "Configure")

      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.bat"
           "chcp 65001${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
           "chcp 65001${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(
        WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.ps1"
        "\$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.ps1"
        "\$OutputEncoding = [System.Text.UTF8Encoding]::new()${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1"
        "\$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1"
        "\$OutputEncoding = [System.Text.UTF8Encoding]::new()${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.bat"
        "set PATH=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.ps1"
        "\$ENV:PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR};\"+\$ENV:PATH${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "set PATH=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1"
        "\$ENV:PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR};\"+\$ENV:PATH${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.bat")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.ps1")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1")

      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS "no-makedepend" "-utf-8"
           "no-capieng" # "enable-capieng"  # 有些第三方库没有加入对这个模块检测的支持，比如 libwebsockets
      )

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET)
        if(CMAKE_SIZEOF_VOID_P MATCHES 8)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "VC-WIN64A-masm")
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET "VC-WIN32" "no-asm")
        endif()
      endif()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_DEFAULT_TARGET}")

      project_expand_list_for_command_line_to_file(
        BAT
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.bat"
        perl
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG}"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS})
      project_expand_list_for_command_line_to_file(
        PWSH
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.ps1"
        "&"
        perl
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_CONFIG}"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_OPTIONS})
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "set CL=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_MULTI_CORE}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1"
        "\$ENV:CL=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_MULTI_CORE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      project_build_tools_find_nmake_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE)
      project_expand_list_for_command_line_to_file(
        BAT "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE}" "build_all_generated")
      project_expand_list_for_command_line_to_file(
        PWSH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1" "&"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE}" "build_all_generated")
      project_expand_list_for_command_line_to_file(
        BAT "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE}" "PERL=no-perl")
      project_expand_list_for_command_line_to_file(
        PWSH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1" "&"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE}" "PERL=no-perl")
      project_expand_list_for_command_line_to_file(
        BAT "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE}" "install_sw"
        "install_ssldirs" # "DESTDIR=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      )
      project_expand_list_for_command_line_to_file(
        PWSH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1" "&"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_NMAKE}" "install_sw"
        "install_ssldirs" # "DESTDIR=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      )

      # build & install
      if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" "-File"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.ps1"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" "-File"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.ps1"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-config.bat"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}/run-build-release.bat"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
    endif()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_MULTI_CORE)

    find_package(OpenSSL)
    project_third_party_openssl_import()
  elseif(OPENSSL_FOUND OR OpenSSL_FOUND)
    project_third_party_openssl_import()
  endif()

  if(OPENSSL_FOUND)
    if((DEFINED VCPKG_CMAKE_SYSTEM_NAME AND VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
       OR MINGW
       OR (CMAKE_SYSTEM_NAME STREQUAL "MinGW")
       OR (CMAKE_SYSTEM_NAME STREQUAL "Windows"))
      if(TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto)
        if(TARGET OpenSSL::Crypto)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto REMOVE_LIBRARIES "Ws2_32;Crypt32"
                                                                      ADD_LIBRARIES "Ws2_32;Crypt32")
        endif()
        if(TARGET OpenSSL::SSL)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL REMOVE_LIBRARIES "Ws2_32;Crypt32"
                                                                      ADD_LIBRARIES "Ws2_32;Crypt32")
        endif()
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME Ws2_32 Crypt32)
      endif()
    endif()
  else()
    if(OPENSSL_ROOT_DIR)
      unset(OPENSSL_ROOT_DIR)
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
      project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_BUILD_DIR}")
    endif()
  endif()
else()
  project_third_party_openssl_import()
endif()
