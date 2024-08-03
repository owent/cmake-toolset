# A regular expression library.
# https://github.com/google/re2.git
# git@github.com:google/re2.git

include_guard(DIRECTORY)

# =========== third party re2 ==================
macro(PROJECT_THIRD_PARTY_RE2_IMPORT)
  if(TARGET re2::re2)
    message(STATUS "Dependency(${PROJECT_NAME}): re2 using target re2::re2")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_LINK_NAME re2::re2)
  endif()
endmacro()

if(NOT TARGET re2::re2)
  find_package(re2 QUIET)
  project_third_party_re2_import()

  if(NOT TARGET re2::re2)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION "2024-07-02")
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION VERSION_LESS_EQUAL "20240116.2")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION "2024-04-01")
    endif()
    project_third_party_port_declare(
      re2
      VERSION
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/google/re2.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DRE2_BUILD_TESTING=OFF")

    project_third_party_append_build_shared_lib_var("re2" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)
    project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_BUILD_OPTIONS)

    # Patch for the BUG of cmake
    set(PACKAGE_PREFIX_DIR "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
    find_configure_package(
      PACKAGE
      re2
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "re2-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_RE2_GIT_URL}")
    unset(PACKAGE_PREFIX_DIR)

    if(TARGET re2::re2)
      project_third_party_re2_import()
    endif()
  endif()
else()
  project_third_party_re2_import()
endif()
