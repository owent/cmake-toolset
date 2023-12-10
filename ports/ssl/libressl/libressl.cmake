# =========== third party libressl ==================
include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_LIBRESSL_IMPORT)
  if(TARGET LibreSSL::Crypto)
    set(OPENSSL_FOUND
        ${LIBRESSL_FOUND}
        CACHE BOOL "using libressl for erplacement of openssl" FORCE)
    set(OPENSSL_INCLUDE_DIR
        ${LIBRESSL_INCLUDE_DIR}
        CACHE PATH "libressl include dir" FORCE)
    set(OPENSSL_CRYPTO_LIBRARY
        ${LIBRESSL_CRYPTO_LIBRARY}
        CACHE STRING "libressl crypto libs" FORCE)
    set(OPENSSL_CRYPTO_LIBRARIES
        ${LIBRESSL_CRYPTO_LIBRARY}
        CACHE STRING "libressl crypto libs" FORCE)
    set(OPENSSL_SSL_LIBRARY
        ${LIBRESSL_SSL_LIBRARY}
        CACHE STRING "libressl ssl libs" FORCE)
    set(OPENSSL_SSL_LIBRARIES
        ${LIBRESSL_SSL_LIBRARY}
        CACHE STRING "libressl ssl libs" FORCE)
    set(OPENSSL_LIBRARIES
        ${LIBRESSL_LIBRARIES}
        CACHE STRING "libressl all libs" FORCE)
    set(OPENSSL_VERSION
        "1.1.0"
        CACHE STRING "openssl version of libressl" FORCE)

    set_target_properties(LibreSSL::Crypto LibreSSL::SSL PROPERTIES IMPORTED_GLOBAL TRUE)
    add_library(OpenSSL::Crypto ALIAS LibreSSL::Crypto)
    add_library(OpenSSL::SSL ALIAS LibreSSL::SSL)

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME)
    if(TARGET LibreSSL::TLS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME LibreSSL::TLS)

      if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND "bcrypt" IN_LIST ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LIBRARIES)
        project_build_tools_patch_imported_link_interface_libraries(LibreSSL::Crypto ADD_LIBRARIES bcrypt)
        project_build_tools_patch_imported_link_interface_libraries(LibreSSL::TLS ADD_LIBRARIES bcrypt)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME "bcrypt")
      endif()
    else()
      if(LIBRESSL_LIBRARIES)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME ${LIBRESSL_LIBRARIES})
      endif()
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_LIBRESSL
          TRUE
          CACHE BOOL "Cache ssl selector and directly use libressl next time")
    endif()
  endif()
endmacro()

if(NOT TARGET LibreSSL::Crypto)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION "3.8.2")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_TAR_URL_BASE)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_TAR_URL_BASE
        "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR)
    project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR "libressl"
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION})
  endif()

  find_package(LibreSSL QUIET)
  project_third_party_libressl_import()

  if(NOT TARGET LibreSSL::Crypto)
    message(STATUS "Try to configure and use libressl")
    unset(OPENSSL_FOUND CACHE)
    unset(OPENSSL_INCLUDE_DIR CACHE)
    unset(OPENSSL_CRYPTO_LIBRARY CACHE)
    unset(OPENSSL_CRYPTO_LIBRARIES CACHE)
    unset(OPENSSL_SSL_LIBRARY CACHE)
    unset(OPENSSL_SSL_LIBRARIES CACHE)
    unset(OPENSSL_LIBRARIES CACHE)
    unset(OPENSSL_VERSION CACHE)

    if(NOT EXISTS
       "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}")
      if(NOT
         EXISTS
         "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}.tar.gz"
      )
        findconfigurepackagedownloadfile(
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_TAR_URL_BASE}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}.tar.gz"
          "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}.tar.gz"
        )
      endif()

      execute_process(
        COMMAND
          ${CMAKE_COMMAND} -E tar xvf
          "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}.tar.gz"
        WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_PACKAGE_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    endif()

    if(NOT EXISTS
       "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}")
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Build libressl failed")
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): LibreSSL is required")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS
          ${CMAKE_COMMAND}
          "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}"
          "-DCMAKE_INSTALL_PREFIX=${PROJECT_THIRD_PARTY_INSTALL_DIR}" "-DLIBRESSL_TESTS=OFF")
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()

      project_third_party_append_build_shared_lib_var(
        "libressl" "CRYPTO" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS BUILD_SHARED_LIBS)
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS
          ${CMAKE_COMMAND}
          "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}"
          "-DCMAKE_INSTALL_PREFIX=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS})
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN)
      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VISIBILITY_HIDDEN
         AND NOT DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VISIBILITY_HIDDEN})
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VISIBILITY_HIDDEN
            ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN})
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VISIBILITY_HIDDEN)
      if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_C_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS}")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_CXX_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS}")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS} -fvisibility=hidden")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS} -fvisibility=hidden")
      endif()
    endif()
    project_build_tools_append_cmake_options_for_lib(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS
                                                     DISABLE_CXX_FLAGS)
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VISIBILITY_HIDDEN)
      if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_C_FLAGS)
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_C_FLAGS}")
        else()
          unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS)
        endif()
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_CXX_FLAGS)
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_CXX_FLAGS}")
        else()
          unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS)
        endif()
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_C_FLAGS)
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BACKUP_CMAKE_CXX_FLAGS)
      endif()
    endif()
    project_third_party_append_find_root_args(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS)

    if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR})
      file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR})
    endif()

    if(CMAKE_HOST_UNIX
       OR MSYS
       OR CYGWIN)
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.sh"
           "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.sh"
           "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.sh"
        "export PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      file(
        APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.sh"
        "export PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.sh")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.sh")
      project_expand_list_for_command_line_to_file(
        BASH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.sh"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS}")
      project_expand_list_for_command_line_to_file(
        BASH
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.sh"
        ${CMAKE_COMMAND}
        --build
        .
        --target
        install
        --config
        Release
        "-j")

      # build & install
      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.sh"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.sh"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

    else()
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-debug.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.bat"
           "@echo off${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.bat"
           "set PATH=${ATFRAME_THIRD_PARTY_ENV_PATH};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-debug.bat"
           "set PATH=${ATFRAME_THIRD_PARTY_ENV_PATH};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.bat"
           "set PATH=${ATFRAME_THIRD_PARTY_ENV_PATH};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.bat")
      project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-debug.bat")
      project_make_executable(
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.bat")
      project_expand_list_for_command_line_to_file(
        BAT "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.bat"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_OPTIONS}")
      project_expand_list_for_command_line_to_file(
        BAT
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.bat"
        ${CMAKE_COMMAND}
        --build
        .
        --target
        install
        --config
        Release
        "-j")

      # build & install
      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-cmake.bat"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      # install debug target
      if(MSVC)
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-debug.bat"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()

      execute_process(
        COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}/run-build-release.bat"
        WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    endif()
    if(EXISTS
       "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}/FindLibreSSL.cmake"
    )
      file(
        COPY "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libressl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_VERSION}/FindLibreSSL.cmake"
        DESTINATION "${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR}")
    endif()

    unset(LIBRESSL_FOUND CACHE)
    unset(LIBRESSL_INCLUDE_DIR CACHE)
    unset(LIBRESSL_CRYPTO_LIBRARY CACHE)
    unset(LIBRESSL_SSL_LIBRARY CACHE)
    unset(LIBRESSL_TLS_LIBRARY CACHE)
    unset(LIBRESSL_LIBRARIES CACHE)
    unset(LIBRESSL_LIBRARIES)
    unset(LIBRESSL_VERSION CACHE)

    if(WIN32)
      # Patch and remove postfix file
      file(GLOB LIBRESSL_PATCH_WIN32_FILE_NAMES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/crypto-*.lib")
      if(LIBRESSL_PATCH_WIN32_FILE_NAMES)
        list(GET LIBRESSL_PATCH_WIN32_FILE_NAMES 0 LIBRESSL_PATCH_WIN32_FILE_NAME)
        file(RENAME ${LIBRESSL_PATCH_WIN32_FILE_NAME} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/crypto.lib")
      endif()
      unset(LIBRESSL_PATCH_WIN32_FILE_NAMES)
      file(GLOB LIBRESSL_PATCH_WIN32_FILE_NAMES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/crypto-*.dll")
      if(LIBRESSL_PATCH_WIN32_FILE_NAMES)
        list(GET LIBRESSL_PATCH_WIN32_FILE_NAMES 0 LIBRESSL_PATCH_WIN32_FILE_NAME)
        file(RENAME ${LIBRESSL_PATCH_WIN32_FILE_NAME} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/crypto.dll")
      endif()
      unset(LIBRESSL_PATCH_WIN32_FILE_NAMES)

      file(GLOB LIBRESSL_PATCH_WIN32_FILE_NAMES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/ssl-*.lib")
      if(LIBRESSL_PATCH_WIN32_FILE_NAMES)
        list(GET LIBRESSL_PATCH_WIN32_FILE_NAMES 0 LIBRESSL_PATCH_WIN32_FILE_NAME)
        file(RENAME ${LIBRESSL_PATCH_WIN32_FILE_NAME} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/ssl.lib")
      endif()
      unset(LIBRESSL_PATCH_WIN32_FILE_NAMES)
      file(GLOB LIBRESSL_PATCH_WIN32_FILE_NAMES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/ssl-*.dll")
      if(LIBRESSL_PATCH_WIN32_FILE_NAMES)
        list(GET LIBRESSL_PATCH_WIN32_FILE_NAMES 0 LIBRESSL_PATCH_WIN32_FILE_NAME)
        file(RENAME ${LIBRESSL_PATCH_WIN32_FILE_NAME} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/ssl.dll")
      endif()
      unset(LIBRESSL_PATCH_WIN32_FILE_NAMES)

      file(GLOB LIBRESSL_PATCH_WIN32_FILE_NAMES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/tls-*.lib")
      if(LIBRESSL_PATCH_WIN32_FILE_NAMES)
        list(GET LIBRESSL_PATCH_WIN32_FILE_NAMES 0 LIBRESSL_PATCH_WIN32_FILE_NAME)
        file(RENAME ${LIBRESSL_PATCH_WIN32_FILE_NAME} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/tls.lib")
      endif()
      unset(LIBRESSL_PATCH_WIN32_FILE_NAMES)
      file(GLOB LIBRESSL_PATCH_WIN32_FILE_NAMES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/tls-*.dll")
      if(LIBRESSL_PATCH_WIN32_FILE_NAMES)
        list(GET LIBRESSL_PATCH_WIN32_FILE_NAMES 0 LIBRESSL_PATCH_WIN32_FILE_NAME)
        file(RENAME ${LIBRESSL_PATCH_WIN32_FILE_NAME} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/tls.dll")
      endif()
      unset(LIBRESSL_PATCH_WIN32_FILE_NAMES)

      unset(LIBRESSL_PATCH_WIN32_FILE_NAME)
    endif()
    find_package(LibreSSL)
    project_third_party_libressl_import()
  else()
    project_third_party_libressl_import()
  endif()

  if(LIBRESSL_FOUND)
    message(STATUS "Dependency(${PROJECT_NAME}): Libressl found.(${LIBRESSL_VERSION})")
  else()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
      project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBRESSL_BUILD_DIR}")
    endif()
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Libressl is required")
  endif()
else()
  project_third_party_libressl_import()
endif()
