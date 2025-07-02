include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_LIBUNWIND_IMPORT)
  if(TARGET Libunwind::libunwind)
    message(STATUS "Dependency(${PROJECT_NAME}): libunwind found and using target: Libunwind::libunwind")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME Libunwind::libunwind)
  elseif(Libunwind_FOUND)
    message(STATUS "Dependency(${PROJECT_NAME}): libunwind found and using
--   - ${Libunwind_INCLUDE_DIRS}
--   - ${Libunwind_LIBRARIES}")
    if(TARGET PkgConfig::Libunwind)
      add_library(Libunwind::libunwind ALIAS PkgConfig::Libunwind)
      message(STATUS "Dependency(${PROJECT_NAME}): Libunwind::libunwind alias to PkgConfig::Libunwind")
    else()
      if(Libunwind_LIBRARIES)
        add_library(Libunwind::libunwind UNKNOWN IMPORTED)
      else()
        add_library(Libunwind::libunwind INTERFACE IMPORTED)
      endif()
      set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${Libunwind_INCLUDE_DIRS}")
      # if(Libunwind_LIBRARY_DIRS) set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_LINK_DIRECTORIES
      # "${Libunwind_LIBRARY_DIRS}") endif()

      if(Libunwind_LIBRARIES)
        list(GET Libunwind_LIBRARIES 0 Libunwind_LIBRARIES_LOCATION)
        set_target_properties(Libunwind::libunwind PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                                                              IMPORTED_LOCATION "${Libunwind_LIBRARIES_LOCATION}")
        list(LENGTH Libunwind_LIBRARIES Libunwind_LIBRARIES_LENGTH)
        if(Libunwind_LIBRARIES_LENGTH GREATER 1)
          set(Libunwind_LIBRARIES_LOCATION ${Libunwind_LIBRARIES})
          list(REMOVE_AT Libunwind_LIBRARIES_LOCATION 0)
          set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_LINK_LIBRARIES
                                                                "${Libunwind_LIBRARIES_LOCATION}")
        endif()
        unset(Libunwind_LIBRARIES_LOCATION)
        unset(Libunwind_LIBRARIES_LENGTH)
      endif()
      if(Libunwind_LDFLAGS)
        set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_LINK_OPTIONS "${Libunwind_LDFLAGS}")
      endif()
      if(Libunwind_CFLAGS)
        set_target_properties(Libunwind::libunwind PROPERTIES INTERFACE_COMPILE_OPTIONS "${Libunwind_CFLAGS}")
      endif()
      message(STATUS "Dependency(${PROJECT_NAME}): Create imported target Libunwind::libunwind")
    endif()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_LINK_NAME Libunwind::libunwind)
  else()
    message(STATUS "libunwind support disabled")
  endif()
endmacro()

# =========== third party libunwind ==================
if(NOT TARGET Libunwind::libunwind AND NOT Libunwind_FOUND)
  find_package(Libunwind QUIET)
endif()
if(NOT TARGET Libunwind::libunwind AND NOT Libunwind_FOUND)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION "v1.8.2")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_GIT_URL "https://github.com/libunwind/libunwind.git")
  endif()

  project_build_tools_find_make_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBUNWIND_MAKE)
  if(NOT Libunwind_FOUND
     AND EXISTS
         "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}/configure"
  )
    execute_process(
      COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_LIBUNWIND_MAKE}" distclean
      WORKING_DIRECTORY
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}"
        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
  endif()
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_CONFIGURE_OPTIONS
      "--enable-coredump"
      "--enable-ptrace"
      "--enable-debug-frame"
      "--enable-block-signals"
      "--with-pic=yes"
      "--disable-tests"
      "--disable-documentation"
      "--disable-minidebuginfo" # This will use liblzma(7-Zip) on system and may cause linking error. We can enable this
                                # after add liblzma into compression ports
  )
  project_third_party_check_build_shared_lib("Libunwind" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_USE_SHARED)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_USE_SHARED)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_CONFIGURE_OPTIONS "--enable-shared=yes"
         "--enable-static=no")
  else()
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_CONFIGURE_OPTIONS "--enable-shared=no"
         "--enable-static=yes")
  endif()
  if(NOT TARGET ZLIB::ZLIB)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_CONFIGURE_OPTIONS "--disable-zlibdebuginfo")
  endif()

  find_configure_package(
    PACKAGE
    Libunwind
    BUILD_WITH_CONFIGURE
    AUTOGEN_CONFIGURE
    "autoreconf"
    "-i"
    CONFIGURE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_CONFIGURE_OPTIONS}
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
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
      project_build_tools_print_configure_log(
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libunwind-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUNWIND_VERSION}")
    endif()
    echowithcolor(COLOR YELLOW "-- Dependency(${PROJECT_NAME}): Libunwind not found and skip import it.")
  else()
    project_third_party_libunwind_import()
  endif()
else()
  project_third_party_libunwind_import()
endif()
