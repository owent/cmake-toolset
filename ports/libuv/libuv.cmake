include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LIBUV_IMPORT)
  if(TARGET uv_a)
    message(STATUS "libuv using target: uv_a")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME uv_a)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME})
  elseif(TARGET uv)
    message(STATUS "libuv using target: uv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME uv)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME})
  elseif(TARGET libuv)
    message(STATUS "libuv using target: libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME})
  elseif(TARGET libuv::libuv)
    message(STATUS "libuv using target: libuv::libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv::libuv)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME})
  else()
    message(STATUS "Libuv support disabled")
  endif()
endmacro()

# =========== third party libuv ==================
if(NOT TARGET uv_a
   AND NOT TARGET uv
   AND NOT TARGET libuv
   AND NOT Libuv_FOUND
   AND NOT LIBUV_FOUND)
  if(VCPKG_TOOLCHAIN)
    find_package(Libuv QUIET)
    project_third_party_libuv_import()
  endif()

  if(NOT TARGET uv_a
     AND NOT TARGET uv
     AND NOT TARGET libuv
     AND NOT Libuv_FOUND
     AND NOT LIBUV_FOUND)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_DEFAULT_VERSION "1.41.0")

    set(Libuv_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
    findconfigurepackage(
      PACKAGE
      Libuv
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_FLAGS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
      "-DBUILD_SHARED_LIBS=OFF"
      "-DBUILD_TESTING=OFF"
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${CMAKE_CURRENT_BINARY_DIR}/deps/libuv-v${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_DEFAULT_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "libuv-v${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_DEFAULT_VERSION}"
      GIT_BRANCH
      "v${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/libuv/libuv.git")

    if(NOT Libuv_FOUND)
      echowithcolor(
        COLOR
        RED
        "-- Dependency: Libuv is required, we can not find prebuilt for libuv and can not find git to clone the sources"
      )
      message(FATAL_ERROR "Libuv not found")
    endif()

    project_third_party_libuv_import()
  endif()
else()
  project_third_party_libuv_import()
endif()
