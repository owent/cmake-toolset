include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_XXHASH_IMPORT)
  if(TARGET xxHash::xxhash)
    message(STATUS "Dependency(${PROJECT_NAME}): xxHash using target xxHash::xxhash")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME xxHash::xxhash)
    project_build_tools_patch_default_imported_config(xxHash::xxhash)
  endif()
endmacro()

if(NOT TARGET xxHash::xxhash)
  find_package(xxHash QUIET)
  project_third_party_xxhash_import()

  if(NOT TARGET xxHash::xxhash AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME)
    project_third_party_port_declare(
      xxHash
      VERSION
      "v0.8.1"
      GIT_URL
      "https://github.com/Cyan4973/xxHash.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "xxhash"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_VERSION}")

    if(CMAKE_CROSSCOMPILING)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS "-DXXHASH_BUILD_XXHSUM=OFF")
    endif()
    project_third_party_append_build_shared_lib_var(
      "xxHash" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS BUILD_SHARED_LIBS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      xxHash
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_SRC_DIRECTORY_NAME}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_SRC_DIRECTORY_NAME}/cmake_unofficial"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_GIT_URL}")

    if(TARGET xxHash::xxhash)
      project_third_party_xxhash_import()
    endif()
  endif()
else()
  project_third_party_xxhash_import()
endif()

if(NOT TARGET xxHash::xxhash)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build xxHash.")
endif()
