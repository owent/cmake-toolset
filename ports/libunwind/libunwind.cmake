include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LIBUNWIND_IMPORT)
  if(TARGET Libunwind::libunwind)
    message(STATUS "Libunwind found and using target: Libunwind::libunwind")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME Libunwind::libunwind)
    # list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
    # ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME})
  elseif(Libunwind_FOUND)
    message(STATUS "Libunwind found and using ${Libunwind_INCLUDE_DIRS}:${Libunwind_LIBRARIES}")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_INC_DIR ${Libunwind_INCLUDE_DIRS})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME ${Libunwind_LIBRARIES})

    # if (ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_INC_DIR) list(APPEND
    # ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS
    # ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_INC_DIR}) endif () list(APPEND
    # ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
    # ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME})
  else()
    message(STATUS "libunwind support disabled")
  endif()
endmacro()

# =========== third party libunwind ==================
if(NOT TARGET Libunwind::libunwind AND NOT Libunwind_FOUND)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_DEFAULT_VERSION "v1.5")

  if(PROJECT_GIT_REMOTE_ORIGIN_USE_SSH AND NOT PROJECT_GIT_CLONE_REMOTE_ORIGIN_DISABLE_SSH)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_REPO_URL
        "git@github.com:libunwind/libunwind.git")
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_REPO_URL
        "https://github.com/libunwind/libunwind.git")
  endif()

  findconfigurepackage(
    PACKAGE
    Libunwind
    BUILD_WITH_CONFIGURE
    PREBUILD_COMMAND
    "../autogen.sh"
    CONFIGURE_FLAGS
    "--enable-shared=no"
    "--enable-static=yes"
    "--enable-coredump"
    "--enable-ptrace"
    "--enable-debug-frame"
    "--enable-block-signals"
    "--with-pic=yes"
    WORKING_DIRECTORY
    ${PROJECT_THIRD_PARTY_PACKAGE_DIR}
    BUILD_DIRECTORY
    "${CMAKE_CURRENT_BINARY_DIR}/deps/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_DEFAULT_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
    PREFIX_DIRECTORY
    ${PROJECT_THIRD_PARTY_INSTALL_DIR}
    SRC_DIRECTORY_NAME
    "libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_DEFAULT_VERSION}"
    GIT_BRANCH
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_DEFAULT_VERSION}
    GIT_URL
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_REPO_URL})

  if(NOT Libunwind_FOUND)
    echowithcolor(COLOR YELLOW "-- Dependency: Libunwind not found and skip import it.")
  else()
    project_third_party_libunwind_import()
  endif()
else()
  project_third_party_libunwind_import()
endif()
