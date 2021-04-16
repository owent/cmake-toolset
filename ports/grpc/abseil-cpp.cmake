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
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION)

      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS
                                                     "4.9.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20200225.3")
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20210324.0")
      endif()

    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_GIT_URL
          "https://github.com/abseil/abseil-cpp.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_DIR)
      project_third_party_get_build_dir(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_DIR "abseil-cpp"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DBUILD_TESTING=OFF")
    endif()
    project_third_party_append_find_root_args(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      absl
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS}
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "abseil-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_GIT_URL}")

    if(absl_FOUND)
      project_third_party_abseil_import()
    endif()
  endif()
else()
  project_third_party_abseil_import()
endif()
