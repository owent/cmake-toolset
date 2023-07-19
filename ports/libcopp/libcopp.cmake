include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_LIBCOPP_IMPORT)
  if(TARGET libcopp::cotask)
    message(STATUS "Dependency(${PROJECT_NAME}): libcopp using target: libcopp::cotask")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_LINK_NAME libcopp::cotask)
    project_build_tools_patch_default_imported_config(libcopp::cotask libcopp::copp)
  elseif(TARGET cotask)
    message(STATUS "Dependency(${PROJECT_NAME}): libcopp using target: cotask")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_LINK_NAME cotask)
    project_build_tools_patch_default_imported_config(cotask copp)
  endif()
endmacro()

if(NOT TARGET libcopp::cotask AND NOT cotask)
  find_package(libcopp QUIET CONFIG)
  project_third_party_libcopp_import()

  if(NOT TARGET libcopp::cotask AND NOT cotask)
    project_third_party_port_declare(
      libcopp
      VERSION
      "v2.2.0"
      GIT_URL
      "https://github.com/owent/libcopp.git"
      BUILD_OPTIONS
      "-DATFRAMEWORK_CMAKE_TOOLSET_DIR=${ATFRAMEWORK_CMAKE_TOOLSET_DIR}"
      "-DPROJECT_ENABLE_UNITTEST=OFF"
      "-DPROJECT_ENABLE_SAMPLE=OFF")

    project_third_party_append_build_shared_lib_var(
      "libcopp" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_OPTIONS LIBCOPP_USE_DYNAMIC_LIBRARY)

    find_configure_package(
      PACKAGE
      libcopp
      FIND_PACKAGE_FLAGS
      CONFIG
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "libcopp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_GIT_URL}")

    project_third_party_libcopp_import()
  endif()
else()
  project_third_party_libcopp_import()
endif()
