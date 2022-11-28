include_guard(GLOBAL)

# =========== third party lz4 ==================
# force to use prebuilt when using mingw
macro(PROJECT_THIRD_PARTY_LZ4_IMPORT)
  if(TARGET lz4::lz4_static)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found target lz4::lz4_static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME lz4::lz4_static)
  elseif(TARGET LZ4::lz4_static)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found target LZ4::lz4_static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME LZ4::lz4_static)
  elseif(TARGET lz4::lz4_shared)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found target lz4::lz4_shared")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME lz4::lz4_shared)
  elseif(TARGET LZ4::lz4_shared)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found target LZ4::lz4_shared")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME LZ4::lz4_shared)
  elseif(TARGET lz4::lz4)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found target lz4::lz4")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME lz4::lz4)
  elseif(TARGET LZ4::lz4)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found target LZ4::lz4")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_LINK_NAME LZ4::lz4)
  endif()

  if(TARGET lz4::lz4cli)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_BIN lz4::lz4cli)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found exec: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_BIN}")
  elseif(TARGET LZ4::lz4cli)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_BIN LZ4::lz4cli)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found exec: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_BIN}")
  endif()
  if(TARGET lz4::lz4c)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4C_BIN lz4::lz4c)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found exec: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4C_BIN}")
  elseif(TARGET LZ4::lz4c)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4C_BIN LZ4::lz4c)
    message(STATUS "Dependency(${PROJECT_NAME}): lz4 found exec: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4C_BIN}")
  endif()
endmacro()

if(NOT TARGET lz4::lz4_static
   AND NOT TARGET lz4::lz4_shared
   AND NOT TARGET lz4::lz4
   AND NOT TARGET lz4::lz4cli
   AND NOT TARGET lz4::lz4c
   AND NOT TARGET LZ4::lz4_static
   AND NOT TARGET LZ4::lz4_shared
   AND NOT TARGET LZ4::lz4
   AND NOT TARGET LZ4::lz4cli
   AND NOT TARGET LZ4::lz4c)
  if(VCPKG_TOOLCHAIN)
    find_package(lz4 QUIET)
    project_third_party_lz4_import()
  endif()

  if(NOT TARGET lz4::lz4_static
     AND NOT TARGET lz4::lz4_shared
     AND NOT TARGET lz4::lz4
     AND NOT TARGET lz4::lz4cli
     AND NOT TARGET lz4::lz4c
     AND NOT TARGET LZ4::lz4_static
     AND NOT TARGET LZ4::lz4_shared
     AND NOT TARGET LZ4::lz4
     AND NOT TARGET LZ4::lz4cli
     AND NOT TARGET LZ4::lz4c)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
                                                                              "-DLZ4_POSITION_INDEPENDENT_LIB=ON")

      project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS)

      if(CMAKE_CROSSCOMPILING)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS "-DLZ4_BUILD_CLI=OFF"
             "-DLZ4_BUILD_LEGACY_LZ4C=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS "-DLZ4_BUILD_CLI=ON"
             "-DLZ4_BUILD_LEGACY_LZ4C=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()

    project_third_party_port_declare(
      lz4
      PORT_PREFIX
      "COMPRESSION"
      VERSION
      "v1.9.4"
      GIT_URL
      "https://github.com/lz4/lz4.git")

    if(WIN32 OR MINGW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF"
           "-DBUILD_STATIC_LIBS=ON")
    else()
      project_third_party_append_build_shared_lib_var(
        "lz4" "COMPRESSION" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS BUILD_SHARED_LIBS)
      project_third_party_append_build_static_lib_var(
        "lz4" "COMPRESSION" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS BUILD_STATIC_LIBS)
    endif()

    find_configure_package(
      PACKAGE
      lz4
      PORT_PREFIX
      "COMPRESSION"
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS}
      "-DLZ4_TOP_SOURCE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}/lz4-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION}"
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "lz4-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION}"
      PROJECT_DIRECTORY
      "${CMAKE_CURRENT_LIST_DIR}/lz4-build-script"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_DIR}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_GIT_URL}")

    if(NOT TARGET lz4::lz4_static
       AND NOT TARGET lz4::lz4_shared
       AND NOT TARGET lz4::lz4
       AND NOT TARGET lz4::lz4cli
       AND NOT TARGET lz4::lz4c)
      echowithcolor(COLOR YELLOW "-- Dependency(${PROJECT_NAME}): lz4 not found")
    endif()
    project_third_party_lz4_import()
  endif()
else()
  project_third_party_lz4_import()
endif()

# lz4 can not be built on some version of MSVC 2019 and Windows SDK, Just skip it
if(NOT TARGET lz4::lz4_static
   AND NOT TARGET lz4::lz4_shared
   AND NOT TARGET lz4::lz4)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build lz4.")
endif()
