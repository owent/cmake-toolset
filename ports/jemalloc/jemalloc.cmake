include_guard(GLOBAL)

# =========== third party jemalloc ==================
if(NOT MSVC
   AND NOT MINGW
   AND (NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_INC_DIR
        OR NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_LIB_DIR))

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_GIT_URL
        "https://github.com/jemalloc/jemalloc.git")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_VERSION 5.2.1)
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE "release")
  endif()

  if("debug" STREQUAL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_MODE}")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_BUILD_OPTIONS "--enable-debug")
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_BUILD_OPTIONS "")
  endif()

  findconfigurepackage(
    PACKAGE
    Jemalloc
    BUILD_WITH_CONFIGURE
    CONFIGURE_FLAGS
    "--enable-static=no"
    "--enable-prof"
    "--enable-valgrind"
    "--enable-lazy-lock"
    "--enable-xmalloc"
    "--enable-mremap"
    "--enable-utrace"
    "--enable-munmap"
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_JEMALLOC_BUILD_OPTIONS}
    INSTALL_TARGET
    "install_bin"
    "install_include"
    "install_lib"
    MAKE_FLAGS
    "-j4"
    PREBUILD_COMMAND
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

  if(Jemalloc_FOUND)
    echowithcolor(COLOR GREEN "-- Dependency: Jemalloc found.(${Jemalloc_LIBRARY_DIRS})")

    if(NOT EXISTS ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
      file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
    endif()

    if(NOT EXISTS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
      file(MAKE_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    endif()

    # Copy dynamic libraries for LD_PRELOAD
    foreach(LIB_PATH ${Jemalloc_LIBRARYIES})
      get_filename_component(LIB_EXT_NAME "${LIB_PATH}" EXT)
      if(LIB_EXT_NAME MATCHES ".*\\.so.*")
        file(
          COPY "${LIB_PATH}"
          DESTINATION "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
          FILE_PERMISSIONS
            OWNER_READ
            OWNER_WRITE
            OWNER_EXECUTE
            GROUP_READ
            GROUP_EXECUTE
            WORLD_READ
            WORLD_EXECUTE)
      elseif(LIB_EXT_NAME MATCHES ".*\\.dll.*")
        file(
          COPY "${LIB_PATH}"
          DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
          FILE_PERMISSIONS
            OWNER_READ
            OWNER_WRITE
            OWNER_EXECUTE
            GROUP_READ
            GROUP_EXECUTE
            WORLD_READ
            WORLD_EXECUTE)
      endif()
    endforeach()
    unset(LIB_EXT_NAME)
  endif()
endif()
