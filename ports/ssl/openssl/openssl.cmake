include_guard(GLOBAL)

# =========== third party openssl ==================

macro(PROJECT_THIRD_PARTY_OPENSSL_IMPORT)
  if(OPENSSL_FOUND)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): openssl found.(${OPENSSL_VERSION})")
    if(TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto)
      if(TARGET OpenSSL::Crypto)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::Crypto)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES OpenSSL::Crypto)

        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(
            OpenSSL::Crypto ADD_LIBRARIES Threads::Threads ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES
                                                                      ${CMAKE_DL_LIBS})
        endif()
      endif()
      if(TARGET OpenSSL::SSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::SSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES OpenSSL::SSL)

        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(
            OpenSSL::SSL ADD_LIBRARIES Threads::Threads ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES
                                                                      ${CMAKE_DL_LIBS})
        endif()
      endif()
    else()
      if(OPENSSL_INCLUDE_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS
             ${OPENSSL_INCLUDE_DIR})
      endif()

      if(NOT OPENSSL_LIBRARIES)
        set(OPENSSL_LIBRARIES
            ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY}
            CACHE INTERNAL "Fix cmake module path for openssl" FORCE)
      endif()
      if(OPENSSL_LIBRARIES)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME ${OPENSSL_LIBRARIES})
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES ${OPENSSL_LIBRARIES})
      endif()
    endif()

    find_program(
      OPENSSL_EXECUTABLE
      NAMES openssl openssl.exe
      PATHS "${OPENSSL_INCLUDE_DIR}/../bin" "${OPENSSL_INCLUDE_DIR}/../" ${OPENSSL_INCLUDE_DIR}
      NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
    if(OPENSSL_EXECUTABLE)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN
           "${OPENSSL_EXECUTABLE}")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL
          TRUE
          CACHE BOOL "Cache ssl selector and directly use openssl next time")
    endif()
  endif()
endmacro()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION "1.1.1k")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL
        "https://github.com/openssl/openssl.git")
  endif()
  string(REPLACE "." "_" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_GITHUB_TAG
                 "OpenSSL_${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}")
  # "no-hw" and "no-engine" is recommanded by openssl only for mobile devices @see
  # https://wiki.openssl.org/index.php/Compilation_and_Installation
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
        "--prefix=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
        "--openssldir=${PROJECT_THIRD_PARTY_INSTALL_DIR}/ssl"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS})
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
        "--prefix=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
        "--openssldir=${PROJECT_THIRD_PARTY_INSTALL_DIR}/ssl"
        "--release"
        # "--api=1.1.1" # libwebsockets and atframe_utils has warnings of using deprecated APIs,
        # maybe it can be remove later "no-deprecated" # libcurl and gRPC requires openssl's API of
        # 1.1.0 and 1.0.2, so we can not disable deprecated APIS here
        "no-dso"
        "no-tests"
        "no-external-tests"
        "no-shared"
        "no-idea"
        "no-md4"
        "no-mdc2"
        "no-rc2"
        "no-ssl2"
        "no-ssl3"
        "no-weak-ssl-ciphers"
        "enable-static-engine")
    if(NOT MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
           "enable-ec_nistp_64_gcc_128")
    endif()

  endif()

  if(VCPKG_TOOLCHAIN)
    find_package(OpenSSL QUIET)
    project_third_party_openssl_import()
  endif()

  if(NOT OPENSSL_FOUND)
    set(OPENSSL_ROOT_DIR ${PROJECT_THIRD_PARTY_INSTALL_DIR})
    # set(OPENSSL_USE_STATIC_LIBS TRUE)

    find_library(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_CRYPTO
      NAMES crypto libcrypto
      PATHS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
      NO_DEFAULT_PATH)
    find_library(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_SSL
      NAMES ssl libssl
      PATHS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
      NO_DEFAULT_PATH)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_CRYPTO
       AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_SSL)
      find_package(OpenSSL QUIET)
    else()
      message(
        STATUS
          "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_CRYPTO -- ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_CRYPTO}"
      )
      message(
        STATUS
          "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_SSL    -- ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_SSL}"
      )
    endif()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_CRYPTO CACHE)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_LIB_SSL CACHE)
    project_third_party_openssl_import()
  endif()

  if(NOT OPENSSL_FOUND)
    echowithcolor(COLOR GREEN "-- Try to configure and use openssl")
    unset(OPENSSL_FOUND CACHE)
    unset(OPENSSL_EXECUTABLE CACHE)
    unset(OPENSSL_INCLUDE_DIR CACHE)
    unset(OPENSSL_CRYPTO_LIBRARY CACHE)
    unset(OPENSSL_CRYPTO_LIBRARIES CACHE)
    unset(OPENSSL_SSL_LIBRARY CACHE)
    unset(OPENSSL_SSL_LIBRARIES CACHE)
    unset(OPENSSL_LIBRARIES CACHE)
    unset(OPENSSL_VERSION CACHE)

    project_git_clone_repository(
      URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_GIT_URL}"
      REPO_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}"
      TAG
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_GITHUB_TAG}")

    if(NOT
       EXISTS
       "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}"
    )
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Build openssl failed")
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): openssl is required")
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR
        "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
    )
    if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR})
      file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR})
    endif()

    if(MSVC)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_MULTI_CORE "/MP")
    else()
      include(ProcessorCount)
      ProcessorCount(CPU_CORE_NUM)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_MULTI_CORE "-j${CPU_CORE_NUM}")
      unset(CPU_CORE_NUM)
    endif()
    # 服务器目前不需要适配ARM和android
    if(NOT MSVC)
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.sh"
           "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.sh"
           "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.sh"
        "export PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.sh"
        "export PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      project_make_executable(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.sh")
      project_make_executable(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.sh")

      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
           "CC=${CMAKE_C_COMPILER}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
           "CXX=${CMAKE_CXX_COMPILER}")
      if(CMAKE_AR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "AR=${CMAKE_AR}")
      endif()

      if(CMAKE_C_FLAGS OR CMAKE_C_FLAGS_RELEASE)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
             "CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")
      endif()

      if(CMAKE_CXX_FLAGS OR CMAKE_CXX_FLAGS_RELEASE)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
             "CXXFLAGS=${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
      endif()

      if(CMAKE_ASM_FLAGS OR CMAKE_ASM_FLAGS_RELEASE)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
             "ASFLAGS=${CMAKE_ASM_FLAGS} ${CMAKE_ASM_FLAGS_RELEASE}")
      endif()

      if(CMAKE_EXE_LINKER_FLAGS OR CMAKE_STATIC_LINKER_FLAGS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
             "LDFLAGS=${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS}")
      endif()

      if(CMAKE_RANLIB)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
             "RANLIB=${CMAKE_RANLIB}")
      endif()

      if(ANDROID)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "no-stdio")
        if(ANDROID_PLATFORM_LEVEL)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS
               "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}")
        endif()
        if(CMAKE_ANDROID_ARCH_ABI MATCHES "^armeabi(-v7a)?$")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS android-arm)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL arm64-v8a)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS android-arm64)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS android-x86)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86_64)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS android-x86_64)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL mips)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS android-mips)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL mips64)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS android-mips64)
        else()
          message(FATAL_ERROR "Invalid Android ABI: ${CMAKE_ANDROID_ARCH_ABI}.")
        endif()
      endif()
      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.sh"
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}/config"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS})
      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.sh" "make"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_MULTI_CORE})
      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.sh" "make"
        "install_sw" "install_ssldirs")

      # build & install
      message(
        STATUS "@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR} Run: ./run-config.sh")
      message(
        STATUS
          "@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR} Run: ./run-build-release.sh")
      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.sh"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR})

      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.sh"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR})

    else()
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.bat"
        "set PATH=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "set PATH=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}"
      )
      project_make_executable(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.bat")
      project_make_executable(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat")

      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "no-makedepend"
           "-utf-8" "no-capieng" # "enable-capieng"  # 有些第三方库没有加入对这个模块检测的支持，比如 libwebsockets
      )

      if(CMAKE_SIZEOF_VOID_P MATCHES 8)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "VC-WIN64A-masm")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "VC-WIN32" "no-asm")
      endif()

      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.bat"
        perl
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/openssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_OPENSSL_VERSION}/Configure"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_OPTIONS})
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat"
        "set CL=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_MULTI_CORE}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat" "nmake"
        "build_all_generated")
      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat" "nmake"
        "PERL=no-perl")
      project_expand_list_for_command_line_to_file(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat" "nmake"
        "install_sw" "install_ssldirs" # "DESTDIR=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      )

      # build & install
      message(
        STATUS
          "@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR} Run: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.bat"
      )
      message(
        STATUS
          "@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR} Run: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat"
      )
      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-config.bat"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR})

      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR}/run-build-release.bat"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_DIR})
    endif()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_BUILD_MULTI_CORE)

    find_package(OpenSSL)
    project_third_party_openssl_import()
  endif()

  if(NOT OPENSSL_FOUND AND OPENSSL_ROOT_DIR)
    unset(OPENSSL_ROOT_DIR)
  endif()

  if(OPENSSL_FOUND AND WIN32)
    find_library(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_CRYPT32 Crypt32)
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENSSL_FIND_CRYPT32)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME Crypt32)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES Crypt32)
    endif()
  endif()
else()
  project_third_party_openssl_import()
endif()
