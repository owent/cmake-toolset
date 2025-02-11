# This is c-ares, an asynchronous resolver library.
# https://github.com/c-ares/c-ares.git
# git@github.com:c-ares/c-ares.git
# https://c-ares.haxx.se/

include_guard(DIRECTORY)

# =========== third party c-ares ==================
macro(PROJECT_THIRD_PARTY_CARES_IMPORT)
  if(TARGET c-ares::cares)
    message(STATUS "Dependency(${PROJECT_NAME}): c-ares using target c-ares::cares")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME c-ares::cares)
  elseif(TARGET c-ares::cares_static)
    message(STATUS "Dependency(${PROJECT_NAME}): c-ares using target c-ares::cares_static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME c-ares::cares_static)
  elseif(TARGET c-ares::cares_shared)
    message(STATUS "Dependency(${PROJECT_NAME}): c-ares using target c-ares::cares_shared")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME c-ares::cares_shared)
  elseif(CARES_FOUND AND CARES_LIBRARIES)
    message(STATUS "Dependency(${PROJECT_NAME}): c-ares support enabled")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME ${CARES_LIBRARIES})
  else()
    message(STATUS "Dependency(${PROJECT_NAME}): c-ares support disabled")
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME)
    project_build_tools_patch_default_imported_config(c-ares::cares c-ares::cares_static c-ares::cares_shared)
  endif()
endmacro()

if(NOT TARGET c-ares::cares
   AND NOT TARGET c-ares::cares_static
   AND NOT TARGET c-ares::cares_shared
   AND NOT CARES_FOUND)
  find_package(c-ares QUIET)
  project_third_party_cares_import()

  if(NOT TARGET c-ares::cares
     AND NOT TARGET c-ares::cares_static
     AND NOT TARGET c-ares::cares_shared
     AND NOT CARES_FOUND)

    project_third_party_port_declare(
      cares
      VERSION
      "1.34.4"
      GIT_URL
      "https://github.com/c-ares/c-ares.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DCARES_STATIC_PIC=ON")

    project_third_party_append_build_shared_lib_var(
      "cares" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS CARES_SHARED BUILD_SHARED_LIBS)
    project_third_party_append_build_static_lib_var(
      "cares" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS CARES_STATIC)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION VERSION_GREATER_EQUAL "1.30.0")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_DEFAULT_VERSION
          "v${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION}")
    else()
      string(REPLACE "." "_" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_DEFAULT_VERSION
                     "cares-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION}")
    endif()

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "cares"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      c-ares
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS}
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "c-ares-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_DEFAULT_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_GIT_URL}")

    if(TARGET c-ares::cares
       OR TARGET c-ares::cares_static
       OR TARGET c-ares::cares_shared
       OR CARES_FOUND)
      project_third_party_cares_import()
    endif()
  endif()
else()
  project_third_party_cares_import()
endif()
