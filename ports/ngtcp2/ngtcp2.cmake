include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_NGTCP2_IMPORT)
  if(TARGET Libngtcp2::libngtcp2)
    message(STATUS "Dependency(${PROJECT_NAME}): ngtcp2 using target Libngtcp2::libngtcp2")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_LINK_NAME Libngtcp2::libngtcp2)

    if(TARGET Libnghttp3::libnghttp3)
      project_build_tools_patch_imported_link_interface_libraries(Libngtcp2::libngtcp2 ADD_LIBRARIES
                                                                  Libnghttp3::libnghttp3)
    endif()

    # New name from v0.17.0
    find_package(Libngtcp2_crypto_quictls QUIET)
    if(TARGET Libngtcp2::libngtcp2_crypto_quictls)
      message(
        STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_quictls using target Libngtcp2::libngtcp2_crypto_quictls")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_CRYPTO_QUICTLS_LINK_NAME Libngtcp2::libngtcp2_crypto_quictls)
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(Libngtcp2::libngtcp2_crypto_quictls ADD_LIBRARIES
                                                                    Libngtcp2::libngtcp2)
      endif()
    endif()
    # Legacy name
    find_package(Libngtcp2_crypto_openssl QUIET)
    if(TARGET Libngtcp2::libngtcp2_crypto_openssl)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_CRYPTO_QUICTLS_LINK_NAME)
        message(
          STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_openssl using target Libngtcp2::libngtcp2_crypto_openssl")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_CRYPTO_QUICTLS_LINK_NAME
            Libngtcp2::libngtcp2_crypto_openssl)
      endif()
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(Libngtcp2::libngtcp2_crypto_openssl ADD_LIBRARIES
                                                                    Libngtcp2::libngtcp2)
      endif()
    endif()
    # Boringssl
    find_package(Libngtcp2_crypto_boringssl QUIET)
    if(TARGET Libngtcp2::libngtcp2_crypto_boringssl)
      message(
        STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_boringssl using target Libngtcp2::libngtcp2_crypto_boringssl"
      )
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_CRYPTO_BORINGSSL_LINK_NAME
          Libngtcp2::libngtcp2_crypto_boringssl)
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(Libngtcp2::libngtcp2_crypto_boringssl ADD_LIBRARIES
                                                                    Libngtcp2::libngtcp2)
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
      include(CMakePushCheckState)
      include(CheckCXXSymbolExists)
      cmake_push_check_state()
      set(CMAKE_REQUIRED_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_CRYPTO_QUICTLS_LINK_NAME}
                                   ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_CRYPTO_BORINGSSL_LINK_NAME})
      if(MSVC)
        set(CMAKE_REQUIRED_FLAGS "/utf-8")
      endif()
      check_cxx_symbol_exists(ngtcp2_version "ngtcp2/ngtcp2.h"
                              ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DYNAMICLIB)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DYNAMICLIB)
        set(CMAKE_REQUIRED_DEFINITIONS "-DNGTCP2_STATICLIB=1")
        check_cxx_symbol_exists(ngtcp2_version "ngtcp2/ngtcp2.h"
                                ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_STATICLIB)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_STATICLIB)
          project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2 ADD_DEFINITIONS
                                                                   "NGTCP2_STATICLIB=1")
          if(TARGET Libngtcp2::libngtcp2_crypto_quictls)
            project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2_crypto_quictls
                                                                     ADD_DEFINITIONS "NGTCP2_STATICLIB=1")
          endif()
          if(TARGET Libngtcp2::libngtcp2_crypto_openssl)
            project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2_crypto_openssl
                                                                     ADD_DEFINITIONS "NGTCP2_STATICLIB=1")
          endif()
          if(TARGET Libngtcp2::libngtcp2_crypto_boringssl)
            project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2_crypto_boringssl
                                                                     ADD_DEFINITIONS "NGTCP2_STATICLIB=1")
          endif()
        endif()
      endif()
      cmake_pop_check_state()
    else()
      if(Libngtcp2_LIBRARIES AND Libngtcp2_LIBRARIES MATCHES "\\.a$")
        project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2 ADD_DEFINITIONS
                                                                 "NGTCP2_STATICLIB=1")
        if(TARGET Libngtcp2::libngtcp2_crypto_quictls)
          project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2_crypto_quictls ADD_DEFINITIONS
                                                                   "NGTCP2_STATICLIB=1")
        endif()
        if(TARGET Libngtcp2::libngtcp2_crypto_openssl)
          project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2_crypto_openssl ADD_DEFINITIONS
                                                                   "NGTCP2_STATICLIB=1")
        endif()
        if(TARGET Libngtcp2::libngtcp2_crypto_boringssl)
          project_build_tools_patch_imported_interface_definitions(Libngtcp2::libngtcp2_crypto_boringssl
                                                                   ADD_DEFINITIONS "NGTCP2_STATICLIB=1")
        endif()
      endif()
    endif()
  endif()
endmacro()

if(NOT TARGET Libngtcp2::libngtcp2)
  find_package(Libngtcp2 QUIET)
  project_third_party_ngtcp2_import()

  if(NOT TARGET Libngtcp2::libngtcp2 AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_LINK_NAME)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DENABLE_WERROR=OFF" "-DENABLE_DEBUG=OFF" "-DENABLE_LIB_ONLY=ON")

    if(VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=OFF")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_BORINGSSL=ON"
           "-DENABLE_OPENSSL=OFF")
      if(OPENSSL_INCLUDE_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS
             "-DBORINGSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")
      endif()
      if(OPENSSL_LIBRARIES)
        string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BORINGSSL_LIBRARIES
                       "-DBORINGSSL_LIBRARIES=${OPENSSL_LIBRARIES}")
      elseif(OPENSSL_SSL_LIBRARY AND OPENSSL_CRYPTO_LIBRARY)
        string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BORINGSSL_LIBRARIES
                       "-DBORINGSSL_LIBRARIES=${OPENSSL_SSL_LIBRARY}|${OPENSSL_CRYPTO_LIBRARY}")
      elseif(OPENSSL_SSL_LIBRARY)
        string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BORINGSSL_LIBRARIES
                       "-DBORINGSSL_LIBRARIES=${OPENSSL_SSL_LIBRARY}")
      elseif(OPENSSL_CRYPTO_LIBRARY)
        string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BORINGSSL_LIBRARIES
                       "-DBORINGSSL_LIBRARIES=${OPENSSL_CRYPTO_LIBRARY}")
      endif()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BORINGSSL_LIBRARIES}")
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BORINGSSL_LIBRARIES)
    elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_OPENSSL=ON")
    endif()

    #[[
    # curl support v0.17.0 and v0.16.0 from 8.2
    #     v0.17.0 Rename ngtcp2_crypto_openssl to ngtcp2_crypto_quictls)
    #     v0.16.0 Rename ngtcp2_settings.qlog.write to ngtcp2_settings.qlog_write)
    ]]
    project_third_party_port_declare(
      Libngtcp2
      VERSION
      "v1.4.0"
      GIT_URL
      "https://github.com/ngtcp2/ngtcp2.git"
      BUILD_OPTIONS
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_DEFAULT_BUILD_OPTIONS}")
    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "ngtcp2"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_VERSION}")

    project_third_party_append_build_shared_lib_var(
      "ngtcp2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BUILD_OPTIONS BUILD_SHARED_LIBS ENABLE_SHARED_LIB)
    project_third_party_append_build_static_lib_var(
      "ngtcp2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BUILD_OPTIONS ENABLE_STATIC_LIB)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      Libngtcp2
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_BUILD_ENV
      LIST_SEPARATOR
      "|"
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_SRC_DIRECTORY_NAME}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_GIT_URL}"
      GIT_ENABLE_SUBMODULE)

    if(TARGET Libngtcp2::libngtcp2)
      project_third_party_ngtcp2_import()
    endif()
  endif()
else()
  project_third_party_ngtcp2_import()
endif()

if(NOT TARGET Libngtcp2::libngtcp2)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGTCP2_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build ngtcp2.")
endif()
