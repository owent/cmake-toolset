include_guard(GLOBAL)

# =========== third party zlib ==================
# force to use prebuilt when using mingw
macro(PROJECT_THIRD_PARTY_ZLIB_IMPORT)
  if(TARGET ZLIB::ZLIB)
    # find static library first
    message(STATUS "Dependency(${PROJECT_NAME}): zlib found.(${ZLIB_LIBRARIES})")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_NAME ZLIB::ZLIB)

    if(ZLIB_INCLUDE_DIRS)
      get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR "${ZLIB_INCLUDE_DIRS}"
                             DIRECTORY CACHE)
    else()
      get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_INCLUDE_DIR ZLIB::ZLIB
                          INTERFACE_INCLUDE_DIRECTORIES)
      get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR
                             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_INCLUDE_DIR}" DIRECTORY CACHE)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_INCLUDE_DIR)
    endif()
    mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR)
  endif()
endmacro()

if(NOT TARGET ZLIB::ZLIB)
  project_third_party_port_declare(
    zlib
    PORT_PREFIX
    "COMPRESSION"
    VERSION
    "v1.2.11"
    GIT_URL
    "https://github.com/madler/zlib.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DBUILD_TESTING=OFF")

  project_third_party_append_build_shared_lib_var(
    "zlib" "COMPRESSION" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_OPTIONS BUILD_SHARED_LIBS)

  set(ZLIB_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})

  find_configure_package(
    PACKAGE
    ZLIB
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "zlib-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_DIR}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_GIT_URL}")

  if(NOT TARGET ZLIB::ZLIB)
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): zlib is required")
    message(FATAL_ERROR "zlib not found")
  endif()
  project_third_party_zlib_import()
else()
  project_third_party_zlib_import()
endif()

if(NOT TARGET ZLIB::ZLIB)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build zlib.")
endif()
