include_guard(DIRECTORY)

function(PROJECT_THIRD_PARTY_NGHTTP3_IMPORT)
  if(TARGET nghttp3::nghttp3 OR TARGET nghttp3::nghttp3_static)
    if(TARGET nghttp3::nghttp3)
      message(STATUS "Dependency(${PROJECT_NAME}): nghttp3 using target nghttp3::nghttp3")
      project_third_party_export_port_set(nghttp3 LINK_NAME nghttp3::nghttp3)
    elseif(TARGET nghttp3::nghttp3_static)
      message(STATUS "Dependency(${PROJECT_NAME}): nghttp3 using target nghttp3::nghttp3_static")
      project_third_party_export_port_set(nghttp3 LINK_NAME nghttp3::nghttp3_static)
    endif()
    # Backward compatibility
    project_third_party_export_port_alias_var(libnghttp3 LINK_NAME nghttp3 LINK_NAME)
    project_build_tools_patch_default_imported_config(nghttp3::nghttp3 nghttp3::nghttp3_static)

    # Compatibility for some packages's build script
    if(NOT TARGET nghttp3)
      add_library(nghttp3 INTERFACE IMPORTED)
      set_target_properties(nghttp3 PROPERTIES INTERFACE_LINK_LIBRARIES
                                               "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_LINK_NAME}")
    endif()
  endif()
endfunction()

project_third_party_import_port_targets(nghttp3 nghttp3::nghttp3_static nghttp3::nghttp3)
if(nghttp3_FOUND)
  project_third_party_nghttp3_import()
else()
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_DEFAULT_BUILD_OPTIONS "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
                                                                          "-DENABLE_WERROR=OFF" "-DENABLE_LIB_ONLY=ON")

  if(VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=ON")
  else()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_DEFAULT_BUILD_OPTIONS "-DENABLE_STATIC_CRT=OFF")
  endif()

  project_third_party_port_declare(
    nghttp3
    VERSION
    "v1.10.1"
    GIT_URL
    "https://github.com/ngtcp2/nghttp3.git"
    BUILD_OPTIONS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_DEFAULT_BUILD_OPTIONS})
  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "nghttp3"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_VERSION}")

  project_third_party_append_build_shared_lib_var(
    "nghttp3" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_BUILD_OPTIONS BUILD_SHARED_LIBS ENABLE_SHARED_LIB)
  project_third_party_append_build_static_lib_var(
    "nghttp3" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_BUILD_OPTIONS ENABLE_STATIC_LIB)

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_BUILD_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_PATCH_FILE}")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_RESET_SUBMODULE_URLS)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_SUB_MODULES GIT_RESET_SUBMODULE_URLS
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_RESET_SUBMODULE_URLS})
  endif()

  find_configure_package(
    PACKAGE
    nghttp3
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_FIND_ROOT_PATH
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_SRC_DIRECTORY_NAME}"
    PROJECT_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_SRC_DIRECTORY_NAME}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_GIT_URL}"
    GIT_ENABLE_SUBMODULE
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_SUB_MODULES})

  project_third_party_nghttp3_import()
endif()

if(NOT TARGET nghttp3::nghttp3 AND NOT TARGET nghttp3::nghttp3_static)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NGHTTP3_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build nghttp3.")
endif()
