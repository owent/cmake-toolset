include_guard(DIRECTORY)

function(PROJECT_THIRD_PARTY_NGTCP2_IMPORT)
  if(TARGET ngtcp2::ngtcp2_static OR TARGET ngtcp2::ngtcp2)
    if(TARGET ngtcp2::ngtcp2)
      project_third_party_export_port_set(ngtcp2 LINK_NAME ngtcp2::ngtcp2)
    else()
      project_third_party_export_port_set(ngtcp2 LINK_NAME ngtcp2::ngtcp2_static)
    endif()
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): ngtcp2 using target ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME}")
    # Backward compatibility
    project_third_party_export_port_alias_var(libngtcp2 LINK_NAME ngtcp2 $LINK_NAME)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_LINK_NAME AND TARGET ngtcp2::ngtcp2_static)
      project_build_tools_patch_imported_link_interface_libraries(
        ngtcp2::ngtcp2_static ADD_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_LINK_NAME})
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_LINK_NAME AND TARGET ngtcp2::ngtcp2)
      project_build_tools_patch_imported_link_interface_libraries(
        ngtcp2::ngtcp2 ADD_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_LINK_NAME})
    endif()

    # Compatibility for some packages's build script
    if(NOT TARGET ngtcp2)
      add_library(ngtcp2 INTERFACE IMPORTED)
      set_target_properties(ngtcp2 PROPERTIES INTERFACE_LINK_LIBRARIES
                                              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME}")
    endif()

    # Modern openssl (3.5.0+)
    find_package(Libngtcp2_crypto_ossl)
    if(TARGET Libngtcp2::libngtcp2_crypto_ossl)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_CRYPTO_OSSL_LINK_NAME)
        message(STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_ossl using target Libngtcp2::libngtcp2_crypto_ossl")
        project_third_party_export_port_set(ngtcp2 CRYPTO_OSSL_LINK_NAME Libngtcp2::libngtcp2_crypto_ossl)
        # Backward compatibility
        project_third_party_export_port_alias_var(libngtcp2 CRYPTO_OSSL_LINK_NAME ngtcp2 CRYPTO_OSSL_LINK_NAME)
      endif()
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(
          Libngtcp2::libngtcp2_crypto_ossl ADD_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME})
      endif()

      # Compatibility for some packages's build script
      if(NOT TARGET ngtcp2_crypto_ossl)
        add_library(ngtcp2_crypto_ossl INTERFACE IMPORTED)
        set_target_properties(ngtcp2_crypto_ossl PROPERTIES INTERFACE_LINK_LIBRARIES "Libngtcp2::libngtcp2_crypto_ossl")
      endif()
    endif()
    # New name from v0.17.0
    find_package(Libngtcp2_crypto_quictls QUIET)
    if(TARGET Libngtcp2::libngtcp2_crypto_quictls)
      message(
        STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_quictls using target Libngtcp2::libngtcp2_crypto_quictls")
      project_third_party_export_port_set(ngtcp2 CRYPTO_QUICTLS_LINK_NAME Libngtcp2::libngtcp2_crypto_quictls)
      # Backward compatibility
      project_third_party_export_port_alias_var(libngtcp2 CRYPTO_QUICTLS_LINK_NAME ngtcp2 CRYPTO_QUICTLS_LINK_NAME)
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(
          Libngtcp2::libngtcp2_crypto_quictls ADD_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME})
      endif()

      # Compatibility for some packages's build script
      if(NOT TARGET ngtcp2_crypto_quictls)
        add_library(ngtcp2_crypto_quictls INTERFACE IMPORTED)
        set_target_properties(ngtcp2_crypto_quictls PROPERTIES INTERFACE_LINK_LIBRARIES
                                                               "Libngtcp2::libngtcp2_crypto_quictls")
      endif()

    endif()
    # Legacy name
    find_package(Libngtcp2_crypto_openssl QUIET)
    if(TARGET Libngtcp2::libngtcp2_crypto_openssl)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_CRYPTO_QUICTLS_LINK_NAME)
        message(
          STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_openssl using target Libngtcp2::libngtcp2_crypto_openssl")
        project_third_party_export_port_set(ngtcp2 CRYPTO_QUICTLS_LINK_NAME Libngtcp2::libngtcp2_crypto_openssl)
        # Backward compatibility
        project_third_party_export_port_alias_var(libngtcp2 CRYPTO_QUICTLS_LINK_NAME ngtcp2 CRYPTO_QUICTLS_LINK_NAME)
      endif()
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(
          Libngtcp2::libngtcp2_crypto_openssl ADD_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME})
      endif()

      # Compatibility for some packages's build script
      if(NOT TARGET ngtcp2_crypto_openssl)
        add_library(ngtcp2_crypto_openssl INTERFACE IMPORTED)
        set_target_properties(ngtcp2_crypto_openssl PROPERTIES INTERFACE_LINK_LIBRARIES
                                                               "Libngtcp2::libngtcp2_crypto_openssl")
      endif()
    endif()
    # Boringssl
    find_package(Libngtcp2_crypto_boringssl QUIET)
    if(TARGET Libngtcp2::libngtcp2_crypto_boringssl)
      message(
        STATUS "Dependency(${PROJECT_NAME}): ngtcp2_crypto_boringssl using target Libngtcp2::libngtcp2_crypto_boringssl"
      )
      project_third_party_export_port_set(ngtcp2 CRYPTO_BORINGSSL_LINK_NAME Libngtcp2::libngtcp2_crypto_boringssl)
      # Backward compatibility
      project_third_party_export_port_alias_var(libngtcp2 CRYPTO_BORINGSSL_LINK_NAME ngtcp2 CRYPTO_BORINGSSL_LINK_NAME)
      if(TARGET Libnghttp3::libnghttp3)
        project_build_tools_patch_imported_link_interface_libraries(
          Libngtcp2::libngtcp2_crypto_boringssl ADD_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_LINK_NAME})
      endif()

      # Compatibility for some packages's build script
      if(NOT TARGET ngtcp2_crypto_boringssl)
        add_library(ngtcp2_crypto_boringssl INTERFACE IMPORTED)
        set_target_properties(ngtcp2_crypto_boringssl PROPERTIES INTERFACE_LINK_LIBRARIES
                                                                 "Libngtcp2::libngtcp2_crypto_boringssl")
      endif()
    endif()
  endif()
endfunction()

project_third_party_import_port_targets(ngtcp2 ngtcp2::ngtcp2_static ngtcp2::ngtcp2)
if(ngtcp2_FOUND)
  project_third_party_ngtcp2_import()
else()
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DENABLE_WERROR=OFF" "-DENABLE_DEBUG=OFF" "-DENABLE_LIB_ONLY=ON")

  if(VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=ON")
  else()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=OFF")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_BORINGSSL=ON"
         "-DENABLE_OPENSSL=OFF")
    if(OPENSSL_INCLUDE_DIR)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS
           "-DBORINGSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")
    endif()
    if(OPENSSL_LIBRARIES)
      string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BORINGSSL_LIBRARIES
                     "-DBORINGSSL_LIBRARIES=${OPENSSL_LIBRARIES}")
    elseif(OPENSSL_SSL_LIBRARY AND OPENSSL_CRYPTO_LIBRARY)
      string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BORINGSSL_LIBRARIES
                     "-DBORINGSSL_LIBRARIES=${OPENSSL_SSL_LIBRARY}|${OPENSSL_CRYPTO_LIBRARY}")
    elseif(OPENSSL_SSL_LIBRARY)
      string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BORINGSSL_LIBRARIES
                     "-DBORINGSSL_LIBRARIES=${OPENSSL_SSL_LIBRARY}")
    elseif(OPENSSL_CRYPTO_LIBRARY)
      string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BORINGSSL_LIBRARIES
                     "-DBORINGSSL_LIBRARIES=${OPENSSL_CRYPTO_LIBRARY}")
    endif()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BORINGSSL_LIBRARIES}")
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BORINGSSL_LIBRARIES)
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_OPENSSL)
    # Check if this version of openssl support quictls
    cmake_push_check_state()
    list(APPEND CMAKE_REQUIRED_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME}
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME})
    include(CheckSymbolExists)
    check_symbol_exists(SSL_provide_quic_data "openssl/ssl.h"
                        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_HAVE_SSL_PROVIDE_QUIC_DATA)
    check_symbol_exists(SSL_set_quic_tls_cbs "openssl/ssl.h"
                        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_HAVE_SSL_SET_QUIC_TLS_CBS)
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_HAVE_SSL_PROVIDE_QUIC_DATA
       OR ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_HAVE_SSL_SET_QUIC_TLS_CBS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_OPENSSL=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_OPENSSL=OFF")
    endif()
    cmake_pop_check_state()
  else()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS "-DENABLE_OPENSSL=OFF")
  endif()

  #[[
  # curl support v0.17.0 and v0.16.0 from 8.2
  #     v0.17.0 Rename ngtcp2_crypto_openssl to ngtcp2_crypto_quictls)
  #     v0.16.0 Rename ngtcp2_settings.qlog.write to ngtcp2_settings.qlog_write)
  ]]
  project_third_party_port_declare(
    ngtcp2
    VERSION
    "v1.13.0"
    GIT_URL
    "https://github.com/ngtcp2/ngtcp2.git"
    BUILD_OPTIONS
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_DEFAULT_BUILD_OPTIONS}")
  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "ngtcp2"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_VERSION}")

  project_third_party_append_build_shared_lib_var(
    "ngtcp2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BUILD_OPTIONS BUILD_SHARED_LIBS ENABLE_SHARED_LIB)
  project_third_party_append_build_static_lib_var(
    "ngtcp2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BUILD_OPTIONS ENABLE_STATIC_LIB)

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BUILD_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_PATCH_FILE}")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_RESET_SUBMODULE_URLS)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_SUB_MODULES GIT_RESET_SUBMODULE_URLS
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_RESET_SUBMODULE_URLS})
  endif()

  find_configure_package(
    PACKAGE
    ngtcp2
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_FIND_ROOT_PATH
    CMAKE_INHERIT_BUILD_ENV
    LIST_SEPARATOR
    "|"
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_SRC_DIRECTORY_NAME}"
    PROJECT_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_SRC_DIRECTORY_NAME}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_GIT_URL}"
    GIT_ENABLE_SUBMODULE
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_SUB_MODULES})

  project_third_party_ngtcp2_import()
endif()

if(NOT TARGET ngtcp2::ngtcp2 AND NOT TARGET ngtcp2::ngtcp2_static)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build ngtcp2.")
endif()
