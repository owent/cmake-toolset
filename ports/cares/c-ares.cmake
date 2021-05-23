# This is c-ares, an asynchronous resolver library.
# https://github.com/c-ares/c-ares.git
# git@github.com:c-ares/c-ares.git
# https://c-ares.haxx.se/

include_guard(GLOBAL)

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
endmacro()

if(NOT TARGET c-ares::cares
   AND NOT TARGET c-ares::cares_static
   AND NOT TARGET c-ares::cares_shared
   AND NOT CARES_FOUND)
  if(VCPKG_TOOLCHAIN)
    find_package(c-ares QUIET)
    project_third_party_cares_import()
  endif()

  if(NOT TARGET c-ares::cares
     AND NOT TARGET c-ares::cares_static
     AND NOT TARGET c-ares::cares_shared
     AND NOT CARES_FOUND)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION "1.17.1")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_GIT_URL "https://github.com/c-ares/c-ares.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
                                                                    "-DCARES_STATIC_PIC=ON")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_DIR)
      project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_DIR "c-ares"
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION})
    endif()

    project_third_party_append_build_shared_lib_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS
                                                    CARES_SHARED BUILD_SHARED_LIBS)
    project_third_party_append_build_static_lib_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_BUILD_OPTIONS
                                                    CARES_STATIC)

    string(REPLACE "." "_" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_DEFAULT_VERSION
                   "cares-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_VERSION}")

    find_configure_package(
      PACKAGE
      c-ares
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHIRT_FIND_ROOT_PATH
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
