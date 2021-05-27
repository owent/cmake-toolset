include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_xxhash_IMPORT)
  if(TARGET xxHash::xxhash)
    message(STATUS "Dependency(${PROJECT_NAME}): xxHash using target xxHash::xxhash")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME xxHash::xxhash)
  endif()
endmacro()

if(NOT TARGET xxHash::xxhash)
  if(VCPKG_TOOLCHAIN)
    find_package(xxHash QUIET)
    project_third_party_xxhash_import()
  endif()

  if(NOT TARGET xxHash::xxhash AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_LINK_NAME)
    project_third_party_port_declare(
      xxHash
      VERSION
      "v0.8.0"
      GIT_URL
      "https://github.com/Cyan4973/xxHash.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
    # =========== third party fmtlib ==================
    if(CMAKE_CROSSCOMPILING)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS "-DXXHASH_BUILD_XXHSUM=OFF")
    endif()
    project_third_party_append_build_shared_lib_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_XXHASH_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      xxHash
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
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
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build xxHash.")
endif()
