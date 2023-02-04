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
    message(
      STATUS "Dependency(${PROJECT_NAME}): flatbuffers: flatc=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATC_EXECUTABLE}"
    )
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE)
    if(TARGET flatbuffers::flathash)
      project_build_tools_patch_default_imported_config(flatbuffers::flathash)
      project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE
                                                flatbuffers::flathash)
    else()
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE flathash)
    endif()
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): flatbuffers: flathash=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATHASH_EXECUTABLE}"
    )
  endif()
endmacro()

if(NOT TARGET flatbuffers::flatbuffers)
  if(VCPKG_TOOLCHAIN)
    find_package(flatbuffers QUIET)
    project_third_party_flatbuffers_import()
  endif()

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

    project_third_party_port_declare(
      flatbuffers
      VERSION
      "v23.1.21"
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
      project_third_party_get_host_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_DIR
                                             "flatbuffers" ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_VERSION})
      get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR
                             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_DIR}" DIRECTORY)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}/crosscompiling-flatbuffers-host")
      file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS
          "${CMAKE_COMMAND}" "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-flatbuffers-host")
      message(
        STATUS "Dependency(${PROJECT_NAME}): Try to build flatbuffers fo host architecture when crossing compiling")
      project_build_tools_append_cmake_host_options(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS)
      # Vcpkg
      if(DEFINED VCPKG_HOST_CRT_LINKAGE)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS
             "-DVCPKG_CRT_LINKAGE=${VCPKG_HOST_CRT_LINKAGE}")
      elseif(DEFINED VCPKG_CRT_LINKAGE)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS
             "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}")
      endif()
      # Shared or static
      project_third_party_append_build_shared_lib_var(
        "flatbuffers" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS BUILD_SHARED_LIBS)

      # cmake-toolset
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS
        "-DPROJECT_THIRD_PARTY_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
        "-DPROJECT_THIRD_PARTY_HOST_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
        "-DPROJECT_THIRD_PARTY_PACKAGE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}")
      if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE)
        list(
          APPEND
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS
          "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE}"
        )
      endif()

      foreach(CMD_ARG IN LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS)
        string(REPLACE ";" "\\;" CMD_ARG_UNESCAPE "${CMD_ARG}")
        add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_BUILD_FLAGS_CMD
                                  "\"${CMD_ARG_UNESCAPE}\"")
      endforeach()
      unset(CMD_ARG_UNESCAPE)

      # Build host
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH
         OR CMAKE_HOST_UNIX
         OR MSYS)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-flatbuffers-host/run-build-host.sh.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}/run-build-host.sh" @ONLY
          NEWLINE_STYLE LF)

        # build
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}/run-build-host.sh"
          WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-flatbuffers-host/run-build-host.ps1.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}/run-build-host.ps1" @ONLY
          NEWLINE_STYLE CRLF)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-flatbuffers-host/run-build-host.bat.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}/run-build-host.bat" @ONLY
          NEWLINE_STYLE CRLF)

        # build
        execute_process(
          COMMAND
            "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass -NonInteractive
            -NoLogo -File "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}/run-build-host.ps1"
          WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FLATBUFFERS_HOST_TOOL_BUILD_DIR}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
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
      message(FATAL_ERROR "flatbuffers not found")
    endif()
    project_third_party_flatbuffers_import()
  endif()
else()
  project_third_party_flatbuffers_import()
endif()
