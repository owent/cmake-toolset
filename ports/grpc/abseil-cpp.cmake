# STL like library
# https://github.com/abseil/abseil-cpp.git
# git@github.com:abseil/abseil-cpp.git

include_guard(GLOBAL)

# =========== third party abseil-cpp ==================
macro(PROJECT_THIRD_PARTY_ABSEIL_IMPORT)
  if(absl_FOUND)
    message(STATUS "Dependency(${PROJECT_NAME}): abseil-cpp found(${PROJECT_NAME})")
  endif()
endmacro()

if(NOT absl_FOUND)
  if(VCPKG_TOOLCHAIN)
    find_package(absl QUIET)
    project_third_party_abseil_import()
  endif()

  if(NOT absl_FOUND)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ABSEIL_DEFAULT_VERSION "20210324.0")

    findconfigurepackage(
      PACKAGE
      absl
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_FLAGS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
      "-DBUILD_TESTING=OFF" # "-DBUILD_SHARED_LIBS=OFF"
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/abseil-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ABSEIL_DEFAULT_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "abseil-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ABSEIL_DEFAULT_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ABSEIL_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/abseil/abseil-cpp.git")

    if(absl_FOUND)
      project_third_party_abseil_import()
    endif()
  endif()
else()
  project_third_party_abseil_import()
endif()
