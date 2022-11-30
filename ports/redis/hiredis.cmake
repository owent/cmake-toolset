include_guard(DIRECTORY)
# =========== third_party redis ==================

macro(PROJECT_THIRD_PARTY_REDIS_HIREDIS_IMPORT)
  if(TARGET hiredis::hiredis_ssl_static)
    message(STATUS "hiredis using target: hiredis::hiredis_ssl_static")
    if(TARGET hiredis::hiredis_static)
      project_build_tools_patch_imported_link_interface_libraries(
        hiredis::hiredis_ssl_static REMOVE_LIBRARIES hiredis::hiredis ADD_LIBRARIES hiredis::hiredis_static)
    endif()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_LINK_NAME hiredis::hiredis_ssl_static)
  elseif(TARGET hiredis::hiredis_static)
    message(STATUS "hiredis using target: hiredis::hiredis_static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_LINK_NAME hiredis::hiredis_static)
  elseif(TARGET hiredis::hiredis_ssl)
    message(STATUS "hiredis using target: hiredis::hiredis_ssl")
    if(TARGET hiredis::hiredis)
      project_build_tools_patch_imported_link_interface_libraries(
        hiredis::hiredis_ssl REMOVE_LIBRARIES hiredis::hiredis_ssl_static ADD_LIBRARIES hiredis::hiredis)
    endif()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_LINK_NAME hiredis::hiredis_ssl)
  elseif(TARGET hiredis::hiredis)
    message(STATUS "hiredis using target: hiredis::hiredis")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_LINK_NAME hiredis::hiredis)
  else()
    message(STATUS "hiredis support disabled")
  endif()

  project_build_tools_patch_default_imported_config("hiredis::hiredis_ssl_static" "hiredis::hiredis_static"
                                                    "hiredis::hiredis_ssl" "hiredis::hiredis")
endmacro()

if(VCPKG_TOOLCHAIN)
  find_package(hiredis QUIET CONFIG)
  if(TARGET hiredis::hiredis_static OR TARGET hiredis::hiredis)
    find_package(hiredis_ssl QUIET)
  endif()
  project_third_party_redis_hiredis_import()
endif()

if(NOT TARGET hiredis::hiredis_ssl_static
   AND NOT TARGET hiredis::hiredis_static
   AND NOT TARGET hiredis::hiredis_ssl
   AND NOT TARGET hiredis::hiredis)

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS "-DDISABLE_TESTS=ON"
                                                                            "-DENABLE_EXAMPLES=OFF")
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_APPEND_DEFAULT_BUILD_OPTIONS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_APPEND_DEFAULT_BUILD_OPTIONS})
    endif()
  endif()

  # hiredis_ssl has linking error for android
  if(OPENSSL_FOUND AND NOT ANDROID)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS "-DENABLE_SSL=ON")
    # if(OPENSSL_ROOT_DIR AND (TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto OR OPENSSL_LIBRARIES)) list(APPEND
    # ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}")
    # endif()
    if(MSVC AND NOT VCPKG_TOOLCHAIN)
      if(OPENSSL_CRYPTO_LIBRARY)
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                             "-DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_CRYPTO_LIBRARY}")
      elseif(TARGET OpenSSL::Crypto)
        project_build_tools_get_imported_location(OPENSSL_CRYPTO_LIBRARY OpenSSL::Crypto)
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                             "-DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_CRYPTO_LIBRARY}")
      endif()

      if(OPENSSL_SSL_LIBRARY)
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                             "-DOPENSSL_SSL_LIBRARY=${OPENSSL_SSL_LIBRARY}")
      elseif(TARGET OpenSSL::SSL)
        project_build_tools_get_imported_location(OPENSSL_CRYPTO_LIBRARY OpenSSL::SSL)
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                             "-DOPENSSL_SSL_LIBRARY=${OPENSSL_SSL_LIBRARY}")
      endif()

      if(OPENSSL_INCLUDE_DIR)
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                             "-DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")
      elseif(TARGET OpenSSL::Crypto)
        get_target_property(OPENSSL_INCLUDE_DIR OpenSSL::Crypto INTERFACE_INCLUDE_DIRECTORIES)
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                             "-DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")
      endif()
    elseif(OPENSSL_ROOT_DIR)
      list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
                           "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}")
    endif()
  else()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS "-DENABLE_SSL=OFF")
  endif()

  list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS
       "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}")
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_DEFAULT_BUILD_OPTIONS}")
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_APPEND_DEFAULT_BUILD_OPTIONS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_APPEND_DEFAULT_BUILD_OPTIONS}")
    endif()
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_APPEND_BUILD_OPTIONS)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_APPEND_BUILD_OPTIONS}")
  endif()
  project_third_party_port_declare(hiredis VERSION "v1.1.0" GIT_URL "https://github.com/redis/hiredis.git")

  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "hiredis"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION}")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_PATCH_FILE}")
  endif()

  find_configure_package(
    PACKAGE
    hiredis
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_INHERIT_FIND_ROOT_PATH
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "hiredis-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_GIT_URL}")

  if(NOT hiredis_FOUND)
    echowithcolor(
      COLOR
      RED
      "-- Dependency(${PROJECT_NAME}): hiredis is required, we can not find prebuilt for hiredis and can not build from the sources"
    )
    message(FATAL_ERROR "hiredis not found")
  endif()

  if(TARGET hiredis::hiredis_static OR TARGET hiredis::hiredis)
    find_package(hiredis_ssl QUIET)
  endif()

  project_third_party_redis_hiredis_import()
endif()

if(NOT hiredis_FOUND)
  echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): hiredis is required")
  message(FATAL_ERROR "hiredis not found")
endif()
