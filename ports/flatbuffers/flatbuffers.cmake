# =========== third party flatbuffers ==================
include_guard(DIRECTORY)

# =========== third party flatbuffers ==================
macro(PROJECT_THIRD_PARTY_FLATBUFFERS_IMPORT)
  if(TARGET flatbuffers::flatbuffers)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_INC_DIR flatbuffers::flatbuffers
                        INTERFACE_INCLUDE_DIRECTORIES)
    message(STATUS "Dependency(${PROJECT_NAME}): flatbuffers found.(target: flatbuffers::flatbuffers)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_LINK_NAME flatbuffers::flatbuffers)
  elseif(TARGET flatbuffers::flatbuffers_shared)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_INC_DIR flatbuffers::flatbuffers_shared
                        INTERFACE_INCLUDE_DIRECTORIES)
    message(STATUS "Dependency(${PROJECT_NAME}): flatbuffers found.(target: flatbuffers::flatbuffers_shared)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_LINK_NAME flatbuffers::flatbuffers_shared)
  elseif(FLATBUFFERS_INCLUDE_DIR)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_INC_DIR "${FLATBUFFERS_INCLUDE_DIR}")
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): flatbuffers found.(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_INC_DIR})")
    if(NOT TARGET flatbuffers::flatbuffers-interface)
      add_library(flatbuffers::flatbuffers-interface INTERFACE)
      target_include_directories(flatbuffers::flatbuffers-interface
                                 INTERFACE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_INC_DIR}")
    endif()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_LINK_NAME flatbuffers::flatbuffers-interface)
  endif()

  if(TARGET flatbuffers::flatbuffers)
    project_build_tools_patch_default_imported_config(flatbuffers::flatbuffers)
  endif()
  if(TARGET flatbuffers::flatbuffers_shared)
    project_build_tools_patch_default_imported_config(flatbuffers::flatbuffers_shared)
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE)
    if(TARGET flatbuffers::flatc)
      project_build_tools_patch_default_imported_config(flatbuffers::flatc)
      project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE
                                                flatbuffers::flatc)
    elseif(FLATBUFFERS_FLATC_EXECUTABLE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE "${FLATBUFFERS_FLATC_EXECUTABLE}")
    else()
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE flatc)
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE)
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): flatbuffers: flatc=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE}")
    endif()
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE)
    if(TARGET flatbuffers::flathash)
      project_build_tools_patch_default_imported_config(flatbuffers::flathash)
      project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE
                                                flatbuffers::flathash)
    else()
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE flathash)
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE)
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): flatbuffers: flathash=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE}"
      )
    endif()
  endif()
endmacro()

if(NOT TARGET flatbuffers::flatbuffers)
  find_package(flatbuffers QUIET)
  project_third_party_flatbuffers_import()

  if(NOT TARGET flatbuffers::flatbuffers)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS
          -DFLATBUFFERS_CODE_COVERAGE=OFF
          -DFLATBUFFERS_BUILD_TESTS=OFF
          -DFLATBUFFERS_BUILD_BENCHMARKS=OFF
          -DFLATBUFFERS_INSTALL=ON
          -DFLATBUFFERS_BUILD_FLATLIB=ON
          -DFLATBUFFERS_BUILD_GRPCTEST=OFF
          -DFLATBUFFERS_STRICT_MOD=OFF)
      # Shared or static
      project_third_party_append_build_shared_lib_var(
        "flatbuffers" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS
        FLATBUFFERS_BUILD_SHAREDLIB)
      if(CMAKE_CROSSCOMPILING)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS
             "-DFLATBUFFERS_BUILD_FLATC=OFF" "-DFLATBUFFERS_BUILD_FLATHASH=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS
             "-DFLATBUFFERS_BUILD_FLATC=ON" "-DFLATBUFFERS_BUILD_FLATHASH=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_VERSION "v25.2.10")
    # GCC before 4.9 requires a space in `operator"" _a` which is invalid in later compiler versions.
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      if(CMAKE_C_COMPILER_VERSION VERSION_LESS "4.9.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_VERSION "v24.12.23")
      endif()
    endif()

    project_third_party_port_declare(
      flatbuffers
      VERSION
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/google/flatbuffers.git"
      BUILD_OPTIONS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_DEFAULT_BUILD_OPTIONS})

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "flatbuffers"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_PATCH_FILE}")
    endif()

    # Build host architecture flatc first
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING AND CMAKE_CROSSCOMPILING)
      project_third_party_crosscompiling_host(
        "flatbuffers"
        "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-host"
        RESULT_VARIABLE
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_RESULT
        TEST_PATH
        "bin/flatc"
        "bin/flatc.exe")
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_RESULT EQUAL 0)
        message(FATAL_ERROR "Build host architecture flatbuffers failed")
      endif()
    endif()

    find_configure_package(
      PACKAGE
      flatbuffers
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      MSVC_CONFIGURE
      ${CMAKE_BUILD_TYPE}
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "flatbuffers-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_GIT_URL}")

    if(NOT TARGET flatbuffers::flatbuffers)
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): flatbuffers is required but not found")
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
        project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_BUILD_DIR}")
      endif()
      message(FATAL_ERROR "flatbuffers not found")
    endif()
    project_third_party_flatbuffers_import()
  endif()
else()
  project_third_party_flatbuffers_import()
endif()
