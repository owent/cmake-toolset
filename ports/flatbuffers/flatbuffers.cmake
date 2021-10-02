# =========== third party flatbuffer ==================
include_guard(GLOBAL)

# =========== third party flatbuffer ==================
macro(PROJECT_THIRD_PARTY_FLATBUFFERS_IMPORT)
  if(TARGET flatbuffers::flatbuffers)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_INC_DIR flatbuffers::flatbuffers
                        INTERFACE_INCLUDE_DIRECTORIES)
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): Flatbuffer found.(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_INC_DIR})")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLAT_BUFFERS_LINK_NAME flatbuffers::flatbuffers)
    project_third_party_libwebsockets_patch_imported_target(flatbuffers::flatbuffers)
  endif()

  if(TARGET flatbuffers::flatc AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_EXECUTABLE)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_EXECUTABLE
                                              flatbuffers::flatc)
  endif()
endmacro()

if(NOT TARGET flatbuffers::flatbuffers)
  if(VCPKG_TOOLCHAIN)
    find_package(Flatbuffers QUIET)
    project_third_party_flatbuffers_import()
  endif()

  if(NOT TARGET flatbuffers::flatbuffers)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION "v2.0.0")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_GIT_URL "https://github.com/google/flatbuffers.git")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_DIR)
      project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_DIR "flatbuffers"
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION})
    endif()

    if(NOT Flatbuffers_ROOT)
      set(Flatbuffers_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS
          -DFLATBUFFERS_CODE_COVERAGE=OFF -DFLATBUFFERS_BUILD_TESTS=OFF -DFLATBUFFERS_INSTALL=ON
          -DFLATBUFFERS_BUILD_FLATLIB=ON -DFLATBUFFERS_BUILD_GRPCTEST=OFF -DFLATBUFFERS_BUILD_SHAREDLIB=OFF)
      if(CMAKE_CROSSCOMPILING)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS "-DFLATBUFFERS_BUILD_FLATC=OFF"
             "-DFLATBUFFERS_BUILD_FLATHASH=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS "-DFLATBUFFERS_BUILD_FLATC=ON"
             "-DFLATBUFFERS_BUILD_FLATHASH=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()
    find_configure_package(
      PACKAGE
      Flatbuffers
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      MSVC_CONFIGURE
      ${CMAKE_BUILD_TYPE}
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFER_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${Flatbuffers_ROOT}"
      SRC_DIRECTORY_NAME
      "flatbuffers-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_GIT_URL}")

    if(NOT TARGET flatbuffers::flatbuffers)
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Flatbuffer is required but not found")
      message(FATAL_ERROR "Flatbuffer not found")
    endif()
    project_third_party_flatbuffers_import()
  endif()
else()
  project_third_party_flatbuffers_import()
endif()
