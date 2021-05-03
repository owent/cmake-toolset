include_guard(GLOBAL)

# =========== third party zlib ==================
# force to use prebuilt when using mingw
macro(PROJECT_THIRD_PARTY_ZLIB_IMPORT)
  if(TARGET ZLIB::ZLIB)
    # find static library first
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): zlib found.(${ZLIB_LIBRARIES})")

    if(ZLIB_INCLUDE_DIRS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS ${ZLIB_INCLUDE_DIRS})
    endif()

    if(ZLIB_LIBRARIES)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES ${ZLIB_LIBRARIES})
    endif()
  endif()
endmacro()

if(NOT TARGET ZLIB::ZLIB)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION "v1.2.11")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_GIT_URL
        "https://github.com/madler/zlib.git")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_OPTIONS
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_TESTING=OFF")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_DIR)
    project_third_party_get_build_dir(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_DIR "zlib"
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_VERSION})
  endif()

  project_third_party_append_build_shared_lib_var(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_BUILD_OPTIONS BUILD_SHARED_LIBS)

  set(ZLIB_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})

  find_configure_package(
    PACKAGE
    ZLIB
    BUILD_WITH_CMAKE
    CMAKE_INHIRT_BUILD_ENV
    CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
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
