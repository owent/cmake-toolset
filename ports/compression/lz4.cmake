include_guard(GLOBAL)

# =========== third party lz4 ==================
# force to use prebuilt when using mingw
macro(PROJECT_THIRD_PARTY_LZ4_IMPORT)
  if(TARGET lz4::lz4_static)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): lz4 found target lz4::lz4_static")
    # list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES lz4::lz4_static)
  elseif(TARGET lz4::lz4_shared)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): lz4 found target lz4::lz4_shared")
    # list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES lz4::lz4_shared)
  endif()

  if(TARGET lz4::lz4cli)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_BIN
                                              lz4::lz4cli)
    echowithcolor(
      COLOR
      GREEN
      "-- Dependency(${PROJECT_NAME}): lz4 found exec: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4_BIN}"
    )
  endif()
  if(TARGET lz4::lz4c)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4C_BIN
                                              lz4::lz4c)
    echowithcolor(
      COLOR
      GREEN
      "-- Dependency(${PROJECT_NAME}): lz4 found exec: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LZ4C_BIN}"
    )
  endif()

  if(TARGET lz4::lz4cli OR TARGET lz4::lz4c)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN
         "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/lz4*")
  endif()
endmacro()

if(NOT TARGET lz4::lz4_static
   AND NOT TARGET lz4::lz4_shared
   AND NOT TARGET lz4::lz4cli
   AND NOT TARGET lz4::lz4c)
  if(VCPKG_TOOLCHAIN)
    find_package(lz4 QUIET)
    project_third_party_lz4_import()
  endif()

  if(NOT TARGET lz4::lz4_static
     AND NOT TARGET lz4::lz4_shared
     AND NOT TARGET lz4::lz4cli
     AND NOT TARGET lz4::lz4c)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION "v1.9.3")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_GIT_URL
          "https://github.com/lz4/lz4.git")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DLZ4_POSITION_INDEPENDENT_LIB=ON"
          "-DCMAKE_DEBUG_POSTFIX=d")

      if(CMAKE_CROSSCOMPILING)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS
             "-DLZ4_BUILD_CLI=OFF" "-DLZ4_BUILD_LEGACY_LZ4C=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS
             "-DLZ4_BUILD_CLI=ON" "-DLZ4_BUILD_LEGACY_LZ4C=ON")
      endif()
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_DIR)
      project_third_party_get_build_dir(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_DIR "lz4"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_VERSION})
    endif()

    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS BUILD_SHARED_LIBS)
    project_third_party_append_build_static_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_BUILD_OPTIONS BUILD_STATIC_LIBS)

    find_configure_package(
      PACKAGE
      lz4
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHIRT_FIND_ROOT_PATH
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
       AND NOT TARGET lz4::lz4cli
       AND NOT TARGET lz4::lz4c)
      echowithcolor(COLOR YELLOW "-- Dependency(${PROJECT_NAME}): lz4 not found")
    endif()
    project_third_party_lz4_import()
  endif()
else()
  project_third_party_lz4_import()
endif()

if(NOT TARGET lz4::lz4_static AND NOT TARGET lz4::lz4_shared)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build lz4.")
endif()
