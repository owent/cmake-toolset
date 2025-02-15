include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_NGHTTP2_IMPORT)
  if(TARGET Libnghttp2::libnghttp2)
    message(STATUS "Dependency(${PROJECT_NAME}): nghttp2 using target Libnghttp2::libnghttp2")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_LINK_NAME Libnghttp2::libnghttp2)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP2_LINK_NAME
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_LINK_NAME})

    if(TARGET ngtcp2::ngtcp2)
      project_build_tools_patch_imported_link_interface_libraries(Libnghttp2::libnghttp2 ADD_LIBRARIES ngtcp2::ngtcp2)
    elseif(TARGET ngtcp2::ngtcp2_static)
      project_build_tools_patch_imported_link_interface_libraries(Libnghttp2::libnghttp2 ADD_LIBRARIES
                                                                  ngtcp2::ngtcp2_static)
    endif()

    if(TARGET nghttp3::nghttp3)
      project_build_tools_patch_imported_link_interface_libraries(Libnghttp2::libnghttp2 ADD_LIBRARIES nghttp3::nghttp3)
    elseif(TARGET nghttp3::nghttp3_static)
      project_build_tools_patch_imported_link_interface_libraries(Libnghttp2::libnghttp2 ADD_LIBRARIES
                                                                  nghttp3::nghttp3_static)
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
      include(CMakePushCheckState)
      include(CheckCXXSymbolExists)
      include(CheckTypeSize)
      cmake_push_check_state()
      set(CMAKE_REQUIRED_LIBRARIES Libnghttp2::libnghttp2)
      if(MSVC)
        set(CMAKE_REQUIRED_FLAGS "/utf-8")
      endif()
      check_type_size(ssize_t SIZEOF_SSIZE_T)
      if(NOT HAVE_SIZEOF_SSIZE_T)
        check_type_size("long" SIZEOF_LONG)
        check_type_size("__int64" SIZEOF___INT64)
        if(SIZEOF_LONG EQUAL SIZEOF_SIZE_T)
          set(CMAKE_REQUIRED_DEFINITIONS "-Dssize_t=long")
        elseif(SIZEOF___INT64 EQUAL SIZEOF_SIZE_T)
          set(CMAKE_REQUIRED_DEFINITIONS "-Dssize_t=__int64")
        else()
          set(CMAKE_REQUIRED_DEFINITIONS "-Dssize_t=long long")
        endif()
      endif()
      check_cxx_symbol_exists(nghttp2_version "nghttp2/nghttp2.h"
                              ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DYNAMICLIB)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DYNAMICLIB)
        list(APPEND CMAKE_REQUIRED_DEFINITIONS "-DNGHTTP2_STATICLIB=1")
        check_cxx_symbol_exists(nghttp2_version "nghttp2/nghttp2.h"
                                ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_STATICLIB)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_STATICLIB)
          project_build_tools_patch_imported_interface_definitions(Libnghttp2::libnghttp2 ADD_DEFINITIONS
                                                                   "NGHTTP2_STATICLIB=1")
        endif()
      endif()
      cmake_pop_check_state()
    else()
      if(Libnghttp2_LIBRARIES AND Libnghttp2_LIBRARIES MATCHES "\\.a$")
        project_build_tools_patch_imported_interface_definitions(Libnghttp2::libnghttp2 ADD_DEFINITIONS
                                                                 "NGHTTP2_STATICLIB=1")
      endif()
    endif()

    # Compatibility for some packages's build script
    if(NOT TARGET nghttp2)
      add_library(nghttp2 INTERFACE IMPORTED)
      set_target_properties(nghttp2 PROPERTIES INTERFACE_LINK_LIBRARIES "Libnghttp2::libnghttp2")
    endif()
  endif()
endmacro()

if(NOT TARGET Libnghttp2::libnghttp2)
  find_package(Libnghttp2 QUIET)
  project_third_party_nghttp2_import()

  if(NOT TARGET Libnghttp2::libnghttp2 AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_LINK_NAME)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DEFAULT_BUILD_OPTIONS
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
        "-DENABLE_WERROR=OFF"
        "-DENABLE_DEBUG=OFF"
        "-DENABLE_FAILMALLOC=OFF"
        "-DENABLE_APP=OFF"
        "-DENABLE_HPACK_TOOLS=OFF"
        "-DENABLE_EXAMPLES=OFF"
        "-DBUILD_TESTING=OFF"
        "-DENABLE_ASIO_LIB=OFF")

    if(VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=OFF")
    endif()

    # nghttp2 only support openssl-quic1 now
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_LINK_NAME
       AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGTCP2_CRYPTO_QUICTLS_LINK_NAME
       AND (TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto))
      cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME}
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME})
      include(CheckSymbolExists)
      check_symbol_exists(SSL_provide_quic_data "openssl/ssl.h"
                          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_HAVE_SSL_PROVIDE_QUIC_DATA)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_HAVE_SSL_PROVIDE_QUIC_DATA)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DEFAULT_BUILD_OPTIONS "-DENABLE_HTTP3=ON")
      endif()
      cmake_pop_check_state()
    endif()

    project_third_party_port_declare(
      nghttp2
      VERSION
      "v1.64.0" # curl support ngtcp2 v0.17.0 from 8.2 and v1.55.0 need ngtcp2 v0.17.0 or upper
      GIT_URL
      "https://github.com/nghttp2/nghttp2.git"
      BUILD_OPTIONS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_DEFAULT_BUILD_OPTIONS})
    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "nghttp2"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_VERSION}")

    project_third_party_append_build_shared_lib_var(
      "nghttp2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_BUILD_OPTIONS BUILD_SHARED_LIBS ENABLE_SHARED_LIB)
    project_third_party_append_build_static_lib_var(
      "nghttp2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_BUILD_OPTIONS BUILD_STATIC_LIBS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_PATCH_FILE}")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_RESET_SUBMODULE_URLS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_SUB_MODULES GIT_RESET_SUBMODULE_URLS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_RESET_SUBMODULE_URLS})
    endif()

    find_configure_package(
      PACKAGE
      Libnghttp2
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_SRC_DIRECTORY_NAME}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_GIT_URL}"
      GIT_ENABLE_SUBMODULE
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_SUB_MODULES})

    if(TARGET Libnghttp2::libnghttp2)
      project_third_party_nghttp2_import()
    endif()
  endif()
else()
  project_third_party_nghttp2_import()
endif()

if(NOT TARGET Libnghttp2::libnghttp2)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP2_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build nghttp2.")
endif()
