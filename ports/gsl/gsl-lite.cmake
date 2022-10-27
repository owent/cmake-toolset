# =========== third party gsl-lite ==================
include_guard(GLOBAL)

# =========== third party gsl-lite ==================
macro(PROJECT_THIRD_PARTY_GSL_LITE_IMPORT)
  if(TARGET gsl::gsl-lite-v1)
    message(STATUS "Dependency(${PROJECT_NAME}): gsl::gsl-lite-v1 using target gsl::gsl-lite-v1")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_LINK_NAME gsl::gsl-lite-v1)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LINK_NAME gsl::gsl-lite-v1)
  elseif(TARGET gsl::gsl-lite)
    message(STATUS "Dependency(${PROJECT_NAME}): gsl::gsl-lite using target gsl::gsl-lite")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_LINK_NAME gsl::gsl-lite)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LINK_NAME gsl::gsl-lite)
  endif()
endmacro()

if(NOT TARGET gsl::gsl-lite)
  if(VCPKG_TOOLCHAIN)
    find_package(gsl-lite QUIET)
    project_third_party_gsl_lite_import()
  endif()

  if(NOT TARGET gsl::gsl-lite)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_DEFAULT_OPTIONS
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
        "-DGSL_LITE_OPT_BUILD_TESTS=OFF"
        "-DGSL_LITE_OPT_BUILD_CUDA_TESTS=OFF"
        "-DGSL_LITE_OPT_BUILD_EXAMPLES=OFF"
        "-DGSL_LITE_OPT_BUILD_STATIC_ANALYSIS_DEMOS=OFF"
        "-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF"
        "-DGSL_LITE_OPT_INSTALL_LEGACY_HEADERS=OFF")
    if(NOT TARGET Microsoft.GSL::GSL)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_DEFAULT_OPTIONS
           "-DGSL_LITE_OPT_INSTALL_COMPAT_HEADER=ON")
    endif()
    project_third_party_port_declare(
      gsl-lite
      VERSION
      "v0.40.0"
      GIT_URL
      "https://github.com/gsl-lite/gsl-lite.git"
      BUILD_OPTIONS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_DEFAULT_OPTIONS})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_PATCH_FILE
        "${CMAKE_CURRENT_LIST_DIR}/gsl-lite-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_VERSION}.patch")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      gsl-lite
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_INHERIT_BUILD_ENV_DISABLE_ASM_FLAGS
      MSVC_CONFIGURE
      ${CMAKE_BUILD_TYPE}
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LITE_GIT_URL}")

    if(NOT TARGET gsl::gsl-lite)
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): gsl::gsl-lite is required but not found")
      message(FATAL_ERROR "gsl::gsl-lite not found")
    endif()
    project_third_party_gsl_lite_import()
  endif()
else()
  project_third_party_gsl_lite_import()
endif()
