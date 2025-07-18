include_guard(DIRECTORY)

# =========== third party snappy ==================
# force to use prebuilt when using mingw
macro(PROJECT_THIRD_PARTY_SNAPPY_IMPORT)
  if(TARGET Snappy::snappy)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_SNAPPY_LINK_NAME Snappy::snappy)
    message(STATUS "Dependency(${PROJECT_NAME}): snappy found target Snappy::snappy")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_SNAPPY_LINK_NAME Snappy::snappy)
    project_build_tools_patch_default_imported_config(Snappy::snappy)
  else()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_SNAPPY_LINK_NAME)
  endif()
endmacro()

if(NOT TARGET Snappy::snappy)
  find_package(snappy QUIET)
  project_third_party_snappy_import()

  if(NOT TARGET Snappy::snappy)
    project_third_party_port_declare(
      snappy
      PORT_PREFIX
      COMPRESSION
      VERSION
      "1.2.2"
      GIT_URL
      "https://github.com/google/snappy.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DBUILD_SHARED_LIBS=OFF"
      "-DSNAPPY_BUILD_TESTS=OFF"
      "-DSNAPPY_BUILD_BENCHMARKS=OFF"
      "-DSNAPPY_FUZZING_BUILD=OFF"
      "-DSNAPPY_INSTALL=ON")

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "snappy"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      Snappy
      PORT_PREFIX
      "COMPRESSION"
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "snappy-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_VERSION}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/snappy-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_VERSION}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_BUILD_DIR}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_GIT_URL}")

    if(NOT TARGET Snappy::snappy)
      echowithcolor(COLOR YELLOW "-- Dependency(${PROJECT_NAME}): snappy not found")
    endif()
    project_third_party_snappy_import()
  endif()
else()
  project_third_party_snappy_import()
endif()

if(NOT TARGET Snappy::snappy)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_SNAPPY_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build snappy.")
endif()
