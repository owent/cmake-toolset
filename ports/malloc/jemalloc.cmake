include_guard(DIRECTORY)

# =========== third party jemalloc ==================

macro(PROJECT_THIRD_PARTY_JEMALLOC_IMPORT)
  if(TARGET jemalloc)
    message(STATUS "Dependency(${PROJECT_NAME}): jemalloc found(using target jemalloc)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_LINK_NAME jemalloc)
  endif()
endmacro()

if(NOT TARGET jemalloc)
  find_package(jemalloc QUIET)
  project_third_party_jemalloc_import()

  if(NOT MSVC
     AND NOT MINGW
     AND NOT TARGET jemalloc)

    if(NOT COMPILER_OPTIONS_TEST_EXCEPTION)
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build jemalloc require exception support.")
    endif()

    project_third_party_port_declare(
      jemalloc
      VERSION
      "5.3.0"
      GIT_URL
      "https://github.com/jemalloc/jemalloc.git"
      BUILD_OPTIONS
      "--enable-static=no"
      "--enable-prof"
      # "--enable-lazy-lock" # This option may trigger https://github.com/jemalloc/jemalloc/issues/514 even with
      # --enable-tls, just ignore it
      "--enable-xmalloc"
      "--enable-utrace")

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE "release")
    endif()

    if("debug" STREQUAL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_BUILD_OPTIONS "--enable-debug")
    endif()

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "jemalloc"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION}")

    # Ending configure options
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_BUILD_OPTIONS GIT_PATCH_FILES
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_PATCH_FILE})
    endif()

    find_configure_package(
      PACKAGE
      Jemalloc
      BUILD_WITH_CONFIGURE
      CONFIGURE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_BUILD_OPTIONS}
      INSTALL_TARGET
      "install_bin"
      "install_include"
      "install_lib"
      MAKE_FLAGS
      "-j${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PARALLEL_JOBS}"
      AUTOGEN_CONFIGURE
      bash
      "./autogen.sh"
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/jemalloc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION}"
      PREFIX_DIRECTORY
      ${PROJECT_THIRD_PARTY_INSTALL_DIR}
      SRC_DIRECTORY_NAME
      "jemalloc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_GIT_URL}")

    project_third_party_jemalloc_import()
  endif()
endif()

if(NOT MSVC
   AND NOT MINGW
   AND NOT TARGET jemalloc)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log(
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/jemalloc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build jemalloc failed")
endif()
