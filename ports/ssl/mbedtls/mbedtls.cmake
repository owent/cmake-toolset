# =========== third party mbedtls ==================
include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_MBEDTLS_IMPORT)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND)
    if(TARGET mbedtls_static)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME mbedtls_static)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES mbedtls_static)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND TRUE)
    elseif(TARGET mbedtls)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME mbedtls)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES mbedtls)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND TRUE)
    elseif(mbedTLS_FOUND OR MbedTLS_FOUND)
      if(MBEDTLS_INCLUDE_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS ${MBEDTLS_INCLUDE_DIR})
      elseif(MbedTLS_INCLUDE_DIRS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS ${MbedTLS_INCLUDE_DIRS})
      endif()

      if(MBEDTLS_TLS_LIBRARY)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES ${MBEDTLS_TLS_LIBRARY})
      elseif(MbedTLS_TLS_LIBRARIES)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES ${MbedTLS_TLS_LIBRARIES})
      endif()

      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND TRUE)
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND AND NOT
                                                               ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS
          TRUE
          CACHE BOOL "Cache ssl selector and directly use mbedtls next time")
    endif()
  endif()
endmacro()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION "v2.26.0")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_GIT_URL "https://github.com/ARMmbed/mbedtls.git")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_DIR)
    project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_DIR "mbedtls"
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION})
  endif()

  if(VCPKG_TOOLCHAIN)
    find_package(mbedtls QUIET)
    project_third_party_mbedtls_import()
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_FLAGS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_FLAGS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DENABLE_TESTING=OFF" "-DUSE_STATIC_MBEDTLS_LIBRARY=ON"
          "-DUSE_SHARED_MBEDTLS_LIBRARY=OFF" "-DENABLE_PROGRAMS=OFF")
    endif()

    project_third_party_append_build_shared_lib_var(USE_SHARED_MBEDTLS_LIBRARY BUILD_SHARED_LIBS)

    if(ZLIB_FOUND AND ZLIB_ROOT)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_FLAGS "-DZLIB_ROOT=${ZLIB_ROOT}"
           "-DENABLE_ZLIB_SUPPORT=ON")
    endif()

    echowithcolor(COLOR GREEN "-- Try to configure and use mbedtls")
    find_configure_package(
      PACKAGE
      MbedTLS
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHIRT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_FLAGS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      SRC_DIRECTORY_NAME
      "mbedtls-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_VERSION}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_MBEDTLS_GIT_URL}")

    project_third_party_mbedtls_import()
  endif()
else()
  project_third_party_mbedtls_import()
endif()
