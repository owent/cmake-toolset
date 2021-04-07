# A regular expression library.
# https://github.com/google/re2.git
# git@github.com:google/re2.git

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.10")
  include_guard(GLOBAL)
endif()

# =========== third party re2 ==================
macro(PROJECT_THIRD_PARTY_RE2_IMPORT)
  if(TARGET re2::re2)
    message(STATUS "re2 using target(${PROJECT_NAME}): re2::re2")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_LINK_NAME re2::re2)
  endif()
endmacro()

if(NOT TARGET re2::re2)
  if(VCPKG_TOOLCHAIN)
    find_package(re2 QUIET)
    project_third_party_re2_import()
  endif()

  if(NOT TARGET re2::re2)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION "2021-02-02")

    findconfigurepackage(
      PACKAGE
      re2
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_FLAGS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
      "-DRE2_BUILD_TESTING=OFF" # "-DBUILD_SHARED_LIBS=OFF"
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${CMAKE_CURRENT_BINARY_DIR}/deps/re2-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
      PREFIX_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "re2-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/google/re2.git")

    if(TARGET re2::re2)
      project_third_party_re2_import()
    endif()
  endif()
else()
  project_third_party_re2_import()
endif()
