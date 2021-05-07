include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LIBUNWIND_IMPORT)
  if(TARGET Libunwind::libunwind)
    message(
      STATUS "Dependency(${PROJECT_NAME}): libunwind found and using target: Libunwind::libunwind")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME Libunwind::libunwind)
  elseif(Libunwind_FOUND)
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): libunwind found and using ${Libunwind_INCLUDE_DIRS}:${Libunwind_LIBRARIES}"
    )
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_INC_DIR ${Libunwind_INCLUDE_DIRS})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME ${Libunwind_LIBRARIES})
  else()
    message(STATUS "libunwind support disabled")
  endif()
endmacro()

# =========== third party libunwind ==================
if(NOT TARGET Libunwind::libunwind AND NOT Libunwind_FOUND)

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION "v1.5")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL
        "https://github.com/libunwind/libunwind.git")
  endif()

  find_package(Libunwind QUIET)
  if(NOT Libunwind_FOUND
     AND EXISTS
         "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}/configure"
  )
    execute_process(
      COMMAND make distclean
      WORKING_DIRECTORY
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}"
        ${PROJECT_BUILD_TOOLS_CMAKE_EXECUTE_PROCESS_OUTPUT_OPTIONS})
  endif()
  find_configure_package(
    PACKAGE
    Libunwind
    BUILD_WITH_CONFIGURE
    AUTOGEN_CONFIGURE
    bash
    "./autogen.sh"
    CONFIGURE_FLAGS
    "--enable-shared=no"
    "--enable-static=yes"
    "--enable-coredump"
    "--enable-ptrace"
    "--enable-debug-frame"
    "--enable-block-signals"
    "--with-pic=yes"
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    # libunwind can not be built on all platforms at a different build directory
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL}")

  if(NOT Libunwind_FOUND)
    echowithcolor(COLOR YELLOW
                  "-- Dependency(${PROJECT_NAME}): Libunwind not found and skip import it.")
  else()
    project_third_party_libunwind_import()
  endif()
else()
  project_third_party_libunwind_import()
endif()
