include_guard(GLOBAL)
# =========== third_party redis ==================

macro(PROJECT_THIRD_PARTY_REDIS_HIREDIS_IMPORT)
  if(TARGET hiredis::hiredis_ssl_static)
    message(STATUS "hiredis using target: hiredis::hiredis_ssl_static")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES hiredis::hiredis_ssl_static)
    if(TARGET hiredis::hiredis_static)
      project_build_tools_patch_imported_link_interface_libraries(
        hiredis::hiredis_ssl_static REMOVE_LIBRARIES hiredis::hiredis ADD_LIBRARIES
        hiredis::hiredis_static)
    endif()
  elseif(TARGET hiredis::hiredis_static)
    message(STATUS "hiredis using target: hiredis::hiredis_static")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES hiredis::hiredis_static)
  elseif(TARGET hiredis::hiredis_ssl)
    message(STATUS "hiredis using target: hiredis::hiredis_ssl")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES hiredis::hiredis_ssl)
    if(TARGET hiredis::hiredis)
      project_build_tools_patch_imported_link_interface_libraries(
        hiredis::hiredis_ssl REMOVE_LIBRARIES hiredis::hiredis_ssl_static ADD_LIBRARIES
        hiredis::hiredis)
    endif()
  elseif(TARGET hiredis::hiredis)
    message(STATUS "hiredis using target: hiredis::hiredis")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES hiredis::hiredis)
  else()
    message(STATUS "hiredis support disabled")
  endif()

  project_build_tools_patch_default_imported_config(
    "hiredis::hiredis_ssl_static" "hiredis::hiredis_static" "hiredis::hiredis_ssl"
    "hiredis::hiredis")
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

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION
        "2a5a57b90a57af5142221aa71f38c08f4a737376") # v1.0.0 with some
    # patch
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_GIT_URL
        "https://github.com/redis/hiredis.git")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_DIR)
    project_third_party_get_build_dir(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_DIR "hiredis"
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION})
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_REDIS_HIREDIS_DIR
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/hiredis-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_VERSION}"
  )

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS "-DDISABLE_TESTS=YES"
                                                                    "-DENABLE_EXAMPLES=OFF")
  endif()

  project_third_party_append_find_root_args(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS)

  # hiredis_ssl has linking error for android
  if(OPENSSL_FOUND AND NOT ANDROID)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS "-DENABLE_SSL=ON")
    # if(OPENSSL_ROOT_DIR AND (TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto OR OPENSSL_LIBRARIES))
    # list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
    # "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}") endif()
    if(MSVC)
      if(OPENSSL_CRYPTO_LIBRARY)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
             "-DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_CRYPTO_LIBRARY}")
      elseif(TARGET OpenSSL::Crypto)
        project_build_tools_get_imported_location(OPENSSL_CRYPTO_LIBRARY OpenSSL::Crypto)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
             "-DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_CRYPTO_LIBRARY}")
      endif()

      if(OPENSSL_SSL_LIBRARY)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
             "-DOPENSSL_SSL_LIBRARY=${OPENSSL_SSL_LIBRARY}")
      elseif(TARGET OpenSSL::SSL)
        project_build_tools_get_imported_location(OPENSSL_CRYPTO_LIBRARY OpenSSL::SSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
             "-DOPENSSL_SSL_LIBRARY=${OPENSSL_SSL_LIBRARY}")
      endif()

      if(OPENSSL_INCLUDE_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
             "-DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")
      elseif(TARGET OpenSSL::Crypto)
        get_target_property(OPENSSL_INCLUDE_DIR OpenSSL::Crypto INTERFACE_INCLUDE_DIRECTORIES)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
             "-DOPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR}")
      endif()
    endif()
  else()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS "-DENABLE_SSL=OFF")
  endif()
  # if(NOT MSVC) list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS
  # "-DCMAKE_C_VISIBILITY_PRESET=default") endif()

  find_configure_package(
    PACKAGE
    hiredis
    BUILD_WITH_CMAKE
    CMAKE_INHIRT_BUILD_ENV
    CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_INHIRT_FIND_ROOT_PATH
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HIREDIS_BUILD_OPTIONS}
    "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
    "-DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}"
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
