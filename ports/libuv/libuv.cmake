include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LIBUV_IMPORT)
  if(TARGET uv_a)
    message(STATUS "Dependency(${PROJECT_NAME}): libuv using target: uv_a")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME uv_a)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS uv_a INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES uv_a)
  elseif(TARGET uv)
    message(STATUS "Dependency(${PROJECT_NAME}): libuv using target: uv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME uv)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS uv INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES uv)
  elseif(TARGET libuv)
    message(STATUS "Dependency(${PROJECT_NAME}): libuv using target: libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS libuv INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES libuv)
  elseif(TARGET libuv::libuv)
    message(STATUS "Dependency(${PROJECT_NAME}): libuv using target: libuv::libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv::libuv)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS libuv::libuv
                        INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES libuv::libuv)
  else()
    message(STATUS "Dependency(${PROJECT_NAME}): Libuv support disabled")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS AND Libuv_INCLUDE_DIRS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS "${Libuv_INCLUDE_DIRS}")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES AND Libuv_LIBRARIES)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES "${Libuv_LIBRARIES}")
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

    project_third_party_port_declare(
      libuv
      VERSION
      "v1.43.0"
      GIT_URL
      "https://github.com/libuv/libuv.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DBUILD_TESTING=OFF"
      "-DCMAKE_DEBUG_POSTFIX=d")

    project_third_party_append_build_shared_lib_var(
      "libuv" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS BUILD_SHARED_LIBS)

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE
        "${CMAKE_CURRENT_LIST_DIR}/libuv-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION}.patch")
    if(EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS GIT_PATCH_FILES
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE})
    endif()

    set(Libuv_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
    find_configure_package(
      PACKAGE
      Libuv
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "libuv-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_GIT_URL}")

    if(NOT Libuv_FOUND)
      echowithcolor(
        COLOR
        RED
        "-- Dependency(${PROJECT_NAME}): Libuv is required, we can not find prebuilt for libuv and can not find git to clone the sources"
      )
      message(FATAL_ERROR "Libuv not found")
    endif()

    project_third_party_libuv_import()
  endif()
else()
  project_third_party_libuv_import()
endif()
