include_guard(DIRECTORY)

# =========== third party mimalloc ==================

macro(PROJECT_THIRD_PARTY_MIMALLOC_IMPORT)
  if(TARGET mimalloc-secure
     OR TARGET mimalloc
     OR TARGET mimalloc-static-secure
     OR TARGET mimalloc-static)

    if(TARGET mimalloc-secure)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_LINK_NAME mimalloc-secure)
    elseif(TARGET mimalloc)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_LINK_NAME mimalloc)

    elseif(TARGET mimalloc-static-secure)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_LINK_NAME mimalloc-static-secure)
    elseif(TARGET mimalloc-static)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_LINK_NAME mimalloc-static)
    endif()

    message(
      STATUS
        "Dependency(${PROJECT_NAME}): mimalloc found(using target ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_LINK_NAME})"
    )
  endif()
endmacro()

if(NOT TARGET mimalloc-secure
   AND NOT TARGET mimalloc
   AND NOT TARGET mimalloc-static-secure
   AND NOT TARGET mimalloc-static)
  if(VCPKG_TOOLCHAIN)
    find_package(mimalloc QUIET)
    project_third_party_mimalloc_import()
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_DEFAULT_VERSION "v2.1.1")
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if(CMAKE_C_COMPILER_VERSION VERSION_LESS "4.9.0")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_DEFAULT_VERSION "v2.0.9")
    endif()
  endif()

  if(NOT TARGET mimalloc-secure
     AND NOT TARGET mimalloc
     AND NOT TARGET mimalloc-static-secure
     AND NOT TARGET mimalloc-static)

    if(NOT COMPILER_OPTIONS_TEST_EXCEPTION)
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build mimalloc require exception support.")
    endif()

    project_third_party_port_declare(
      mimalloc
      VERSION
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/microsoft/mimalloc.git"
      BUILD_OPTIONS
      "-DMI_BUILD_TESTS=OFF"
      "-DMI_OVERRIDE=ON"
      "-DMI_USE_CXX=ON")

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_MODE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_MODE "release")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_SECURE)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_OPTIONS "-DMI_SECURE=ON")
    endif()

    if("debug" STREQUAL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_MODE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_OPTIONS "-DMI_DEBUG_FULL=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_OPTIONS "-DMI_DEBUG_FULL=OFF")
    endif()

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "mimalloc"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_VERSION}")

    # Ending configure options
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_OPTIONS GIT_PATCH_FILES
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_PATCH_FILE})
    endif()

    find_configure_package(
      PACKAGE
      mimalloc
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "mimalloc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_GIT_URL}")

    project_third_party_mimalloc_import()
  endif()
endif()

if(NOT TARGET mimalloc-secure
   AND NOT TARGET mimalloc
   AND NOT TARGET mimalloc-static-secure
   AND NOT TARGET mimalloc-static)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MIMALLOC_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build mimalloc failed")
endif()
