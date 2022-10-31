# =========== third party Microsoft.GSL ==================
include_guard(GLOBAL)

# =========== third party Microsoft.GSL ==================
macro(PROJECT_THIRD_PARTY_MICROSOFT_GSL_IMPORT)
  if(TARGET Microsoft.GSL::GSL)
    message(STATUS "Dependency(${PROJECT_NAME}): Microsoft.GSL using target Microsoft.GSL::GSL")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_LINK_NAME Microsoft.GSL::GSL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LINK_NAME Microsoft.GSL::GSL)
  endif()
endmacro()

if(NOT TARGET Microsoft.GSL::GSL)
  if(VCPKG_TOOLCHAIN)
    find_package(Microsoft.GSL QUIET)
    project_third_party_microsoft_gsl_import()
  endif()

  if(NOT TARGET Microsoft.GSL::GSL)
    project_third_party_port_declare(
      Microsoft.GSL
      VERSION
      "v4.0.0"
      GIT_URL
      "https://github.com/microsoft/GSL.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DGSL_TEST=OFF"
      "-DGSL_INSTALL=ON")

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "Microsoft.GSL"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      Microsoft.GSL
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_INHERIT_BUILD_ENV_DISABLE_ASM_FLAGS
      MSVC_CONFIGURE
      ${CMAKE_BUILD_TYPE}
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_GIT_URL}")

    if(NOT TARGET Microsoft.GSL::GSL)
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Microsoft.GSL is required but not found")
      message(FATAL_ERROR "Microsoft.GSL not found")
    endif()
    project_third_party_microsoft_gsl_import()
  endif()
else()
  project_third_party_microsoft_gsl_import()
endif()
