include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_NGHTTP3_IMPORT)
  if(TARGET Libnghttp3::libnghttp3)
    message(STATUS "Dependency(${PROJECT_NAME}): nghttp3 using target Libnghttp3::libnghttp3")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_LINK_NAME Libnghttp3::libnghttp3)

    if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
      include(CMakePushCheckState)
      include(CheckCXXSymbolExists)
      cmake_push_check_state()
      set(CMAKE_REQUIRED_LIBRARIES Libnghttp3::libnghttp3)
      if(MSVC)
        set(CMAKE_REQUIRED_FLAGS "/utf-8")
      endif()
      check_cxx_symbol_exists(nghttp3_version "nghttp3/nghttp3.h"
                              ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_DYNAMICLIB)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_DYNAMICLIB)
        set(CMAKE_REQUIRED_DEFINITIONS "-DNGHTTP3_STATICLIB=1")
        check_cxx_symbol_exists(nghttp3_version "nghttp3/nghttp3.h"
                                ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_STATICLIB)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_STATICLIB)
          project_build_tools_patch_imported_interface_definitions(Libnghttp3::libnghttp3 ADD_DEFINITIONS
                                                                   "NGHTTP3_STATICLIB=1")
        endif()
      endif()
      cmake_pop_check_state()
    else()
      if(Libnghttp3_LIBRARIES AND Libnghttp3_LIBRARIES MATCHES "\\.a$")
        project_build_tools_patch_imported_interface_definitions(Libnghttp3::libnghttp3 ADD_DEFINITIONS
                                                                 "NGHTTP3_STATICLIB=1")
      endif()
    endif()
  endif()
endmacro()

if(NOT TARGET Libnghttp3::libnghttp3)
  find_package(Libnghttp3 QUIET)
  project_third_party_nghttp3_import()

  if(NOT TARGET Libnghttp3::libnghttp3 AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_LINK_NAME)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_DEFAULT_BUILD_OPTIONS
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DENABLE_WERROR=OFF" "-DENABLE_LIB_ONLY=ON")

    if(VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=OFF")
    endif()

    project_third_party_port_declare(
      Libnghttp3
      VERSION
      "v0.10.0"
      GIT_URL
      "https://github.com/ngtcp2/nghttp3.git"
      BUILD_OPTIONS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_DEFAULT_BUILD_OPTIONS})
    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "nghttp3"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_VERSION}")

    project_third_party_append_build_shared_lib_var(
      "nghttp3" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_BUILD_OPTIONS BUILD_SHARED_LIBS ENABLE_SHARED_LIB)
    project_third_party_append_build_static_lib_var(
      "nghttp3" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_BUILD_OPTIONS ENABLE_STATIC_LIB)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      Libnghttp3
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_SRC_DIRECTORY_NAME}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_GIT_URL}")

    if(TARGET Libnghttp3::libnghttp3)
      project_third_party_nghttp3_import()
    endif()
  endif()
else()
  project_third_party_nghttp3_import()
endif()

if(NOT TARGET Libnghttp3::libnghttp3)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBNGHTTP3_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build nghttp3.")
endif()
