include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_TBB_IMPORT)
  if(TARGET TBB::tbb)
    message(STATUS "Dependency(${PROJECT_NAME}): tbb using target TBB::tbb")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_NAME TBB::tbb)
  endif()
endmacro()

if(NOT TARGET TBB::tbb)
  if(VCPKG_TOOLCHAIN)
    find_package(TBB QUIET)
    project_third_party_tbb_import()
  endif()

  if(NOT TARGET TBB::tbb AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_NAME)
    project_third_party_port_declare(
      TBB
      VERSION
      "v2021.6.0"
      GIT_URL
      "https://github.com/oneapi-src/oneTBB.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DTBB_TEST=OFF"
      "-DTBB_EXAMPLES=OFF"
      "-DTBB_STRICT=OFF"
      "-DCMAKE_MSVC_RUNTIME_LIBRARY=${CMAKE_MSVC_RUNTIME_LIBRARY}")
    project_third_party_try_patch_file(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}"
                                       "tbb" "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION}")

    project_third_party_append_build_shared_lib_var("TBB" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      TBB
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_GIT_URL}")

    if(TARGET TBB::tbb)
      project_third_party_tbb_import()
    endif()
  endif()
else()
  project_third_party_tbb_import()
endif()

if(NOT TARGET TBB::tbb)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build tbb.")
endif()
