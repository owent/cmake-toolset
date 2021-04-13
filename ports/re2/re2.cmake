# A regular expression library.
# https://github.com/google/re2.git
# git@github.com:google/re2.git

include_guard(GLOBAL)

# =========== third party re2 ==================
macro(PROJECT_THIRD_PARTY_RE2_IMPORT)
  if(TARGET re2::re2)
    message(STATUS "Dependency(${PROJECT_NAME}): re2 using target re2::re2")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_LINK_NAME re2::re2)
  endif()
endmacro()

if(NOT TARGET re2::re2)
  if(VCPKG_TOOLCHAIN)
    find_package(re2 QUIET)
    project_third_party_re2_import()
  endif()

  if(NOT TARGET re2::re2)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_VERSION "2021-04-01")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_GIT_URL
          "https://github.com/google/re2.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DRE2_BUILD_TESTING=OFF")
    endif()
    project_third_party_append_find_root_args(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_BUILD_OPTIONS BUILD_SHARED_LIBS)

    findconfigurepackage(
      PACKAGE
      re2
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_BUILD_OPTIONS}
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/re2-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "re2-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RE2_GIT_URL}")

    if(TARGET re2::re2)
      project_third_party_re2_import()
    endif()
  endif()
else()
  project_third_party_re2_import()
endif()
