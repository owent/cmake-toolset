if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.10")
  include_guard(GLOBAL)
endif()

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
  set(PROJECT_THIRD_PARTY_ZLIB_DEFAULT_VERSION "v1.2.11")
  set(ZLIB_ROOT ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR})

  findconfigurepackage(
    PACKAGE
    ZLIB
    BUILD_WITH_CMAKE
    CMAKE_INHIRT_BUILD_ENV
    CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_FLAGS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
    "-DBUILD_SHARED_LIBS=OFF"
    WORKING_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR}"
    PREFIX_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "zlib-${PROJECT_THIRD_PARTY_ZLIB_DEFAULT_VERSION}"
    # PROJECT_DIRECTORY
    # "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR}/zlib-${PROJECT_THIRD_PARTY_ZLIB_DEFAULT_VERSION}"
    BUILD_DIRECTORY
    "${CMAKE_CURRENT_BINARY_DIR}/deps/zlib-${PROJECT_THIRD_PARTY_ZLIB_DEFAULT_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
    GIT_BRANCH
    "${PROJECT_THIRD_PARTY_ZLIB_DEFAULT_VERSION}"
    GIT_URL
    "https://github.com/madler/zlib.git")

  if(NOT TARGET ZLIB::ZLIB)
    echowithcolor(COLOR RED "-- Dependency: zlib is required")
    message(FATAL_ERROR "zlib not found")
  endif()
  project_third_party_zlib_import()
else()
  project_third_party_zlib_import()
endif()
