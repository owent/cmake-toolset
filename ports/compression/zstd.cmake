include_guard(DIRECTORY)

# =========== third party zstd ==================
# force to use prebuilt when using mingw
macro(PROJECT_THIRD_PARTY_ZSTD_IMPORT)
  if(TARGET zstd::libzstd_shared)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME zstd::libzstd_shared)
    message(STATUS "Dependency(${PROJECT_NAME}): zstd found target zstd::libzstd_shared")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME zstd::libzstd_shared)
  elseif(TARGET zstd::libzstd_static)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME zstd::libzstd_static)
    message(STATUS "Dependency(${PROJECT_NAME}): zstd found target zstd::libzstd_static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME zstd::libzstd_static)
  elseif(TARGET zstd::libzstd)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME zstd::libzstd)
    message(STATUS "Dependency(${PROJECT_NAME}): zstd found target zstd::libzstd")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME zstd::libzstd)
  else()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME)
  endif()
  if(zstd::zstd OR ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME)
    project_build_tools_patch_default_imported_config(zstd::zstd zstd::libzstd_shared zstd::libzstd_static
                                                      zstd::libzstd)
  endif()
  if(TARGET zstd::zstd)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_BIN zstd::zstd)
    message(
      STATUS "Dependency(${PROJECT_NAME}): zstd found executable: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_BIN}")
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME)
    # Maybe zstd executable not exported, find it by library target
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAMES
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME} zstd::libzstd_shared zstd::libzstd_static zstd::libzstd)
    foreach(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAME IN
            LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAMES)
      if(NOT TARGET ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAME})
        continue()
      endif()
      project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LIB_PATH
                                                ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAME})
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LIB_PATH)
        break()
      endif()
    endforeach()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAMES)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_TEST_LINK_NAME)
    message(
      STATUS "Dependency(${PROJECT_NAME}): Try to find zstd from ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LIB_PATH}"
    )
    get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LIB_DIR
                           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LIB_PATH} DIRECTORY)
    get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_ROOT_DIR
                           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LIB_DIR} DIRECTORY)
    find_program(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_BIN
      NAMES zstd
      NO_DEFAULT_PATH
      PATHS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_ROOT_DIR}
      PATH_SUFFIXES "." "bin")
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_BIN)
      echowithcolor(
        COLOR GREEN
        "-- Dependency(${PROJECT_NAME}): zstd found executable: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_BIN}")
    endif()
  endif()
endmacro()

if(NOT TARGET zstd::libzstd_shared
   AND NOT TARGET zstd::libzstd_static
   AND NOT TARGET zstd::libzstd
   AND NOT TARGET zstd::zstd)
  find_package(zstd QUIET)
  project_third_party_zstd_import()

  if(NOT TARGET zstd::libzstd_shared
     AND NOT TARGET zstd::libzstd_static
     AND NOT TARGET zstd::libzstd
     AND NOT TARGET zstd::zstd)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DZSTD_BUILD_TESTS=OFF" "-DZSTD_BUILD_CONTRIB=0"
          "-DZSTD_MULTITHREAD_SUPPORT=ON")

      project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS)

      if(CMAKE_CROSSCOMPILING)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS "-DZSTD_BUILD_PROGRAMS=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS "-DZSTD_BUILD_PROGRAMS=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()
    project_third_party_port_declare(
      zstd
      PORT_PREFIX
      "COMPRESSION"
      VERSION
      "v1.5.7"
      GIT_URL
      "https://github.com/facebook/zstd.git")

    if(MSVC)
      # Some versions of zstd has linking problem for MSVC So we always use static library when using MSVC
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF"
           "-DZSTD_BUILD_SHARED=OFF" "-DZSTD_PROGRAMS_LINK_SHARED=OFF")
    else()
      project_third_party_append_build_shared_lib_var(
        "zstd" "COMPRESSION" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS BUILD_SHARED_LIBS
        ZSTD_BUILD_SHARED ZSTD_PROGRAMS_LINK_SHARED)
      project_third_party_append_build_static_lib_var(
        "zstd" "COMPRESSION" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS ZSTD_BUILD_STATIC)
    endif()

    if(TARGET lz4::lz4_static)
      get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_INCLUDE_DIR lz4::lz4_static
                          INTERFACE_INCLUDE_DIRECTORIES)
    elseif(TARGET lz4::lz4_shared)
      get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_INCLUDE_DIR lz4::lz4_shared
                          INTERFACE_INCLUDE_DIRECTORIES)
    elseif(TARGET lz4::lz4)
      get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_INCLUDE_DIR lz4::lz4
                          INTERFACE_INCLUDE_DIRECTORIES)
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_INCLUDE_DIR)
      get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_ROOT_DIR
                             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_INCLUDE_DIR}" DIRECTORY)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS "-DZSTD_LZ4_SUPPORT=ON"
           "-DLZ4_ROOT_DIR=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_LZ4_ROOT_DIR}")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS "-DZSTD_ZLIB_SUPPORT=ON"
           "-DZLIB_ROOT=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR}")
    endif()

    find_configure_package(
      PACKAGE
      zstd
      PORT_PREFIX
      "COMPRESSION"
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "zstd-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_VERSION}"
      PROJECT_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/zstd-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_VERSION}/build/cmake"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_DIR}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_GIT_URL}")

    if(NOT TARGET zstd::libzstd_shared
       AND NOT TARGET zstd::libzstd_static
       AND NOT TARGET zstd::libzstd
       AND NOT TARGET zstd::zstd)
      echowithcolor(COLOR YELLOW "-- Dependency(${PROJECT_NAME}): zstd not found")
    endif()
    project_third_party_zstd_import()
  endif()
else()
  project_third_party_zstd_import()
endif()

if(NOT TARGET zstd::libzstd_shared
   AND NOT TARGET zstd::libzstd_static
   AND NOT TARGET zstd::libzstd
   AND NOT TARGET zstd::zstd)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZSTD_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build zstd.")
endif()
