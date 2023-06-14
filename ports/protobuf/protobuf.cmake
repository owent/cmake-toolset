include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_PROTOBUF_IMPORT)
  if(TARGET protobuf::protoc
     OR TARGET protobuf::libprotobuf
     OR TARGET protobuf::libprotobuf-lite)
    if(TARGET protobuf::libprotobuf OR TARGET protobuf::libprotobuf-lite)
      if(TARGET protobuf::libprotobuf)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME protobuf::libprotobuf)
        if(NOT COMPILER_OPTIONS_TEST_RTTI)
          target_compile_definitions(protobuf::libprotobuf INTERFACE "GOOGLE_PROTOBUF_NO_RTTI")
        endif()
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME protobuf::libprotobuf-lite)
      endif()

      if(TARGET protobuf::libprotobuf-lite)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME protobuf::libprotobuf-lite)
        if(NOT COMPILER_OPTIONS_TEST_RTTI)
          target_compile_definitions(protobuf::libprotobuf-lite INTERFACE "GOOGLE_PROTOBUF_NO_RTTI")
        endif()
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME protobuf::libprotobuf)
      endif()
    endif()

    # Protobuf_PROTOC_*/PROTOBUF_*/protobuf_generate_* may not set when set(protobuf_MODULE_COMPATIBLE FALSE)
    if(TARGET protobuf::protoc)
      project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC
                                                protobuf::protoc)
    elseif(Protobuf_PROTOC_EXECUTABLE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC ${Protobuf_PROTOC_EXECUTABLE})
    elseif(PROTOBUF_PROTOC_EXECUTABLE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC ${PROTOBUF_PROTOC_EXECUTABLE})
    else()
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC protoc)
    endif()
    project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")

    if(NOT TARGET protobuf::protoc)
      add_executable(protobuf::protoc IMPORTED)
      set_target_properties(
        protobuf::protoc
        PROPERTIES IMPORTED_LOCATION "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_RELEASE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_RELWITHDEBINFO "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_MINSIZEREL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_DEBUG "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_NOCONFIG "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
    endif()
    if(CMAKE_CROSSCOMPILING)
      # Set protoc and libprotoc to hosted targets
      set_target_properties(
        protobuf::protoc
        PROPERTIES IMPORTED_LOCATION "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_RELEASE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_RELWITHDEBINFO "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_MINSIZEREL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_DEBUG "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
                   IMPORTED_LOCATION_NOCONFIG "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): protobuf executable for crosscompiling(Also reset target protobuf::protoc):
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
      )
    endif()
  endif()
endmacro()

# =========== third party protobuf ==================
if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC
   OR NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME)

  set(protobuf_MODULE_COMPATIBLE TRUE)
  if(VCPKG_TOOLCHAIN)
    find_package(Protobuf QUIET CONFIG)
    project_third_party_protobuf_import()
  endif()

  if(NOT TARGET protobuf::protoc
     AND NOT TARGET protobuf::libprotobuf
     AND NOT TARGET protobuf::libprotobuf-lite)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.21.12")
      # gRPC support 22.* after 1.55.0, which is not released yet.
      # set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v23.1")

      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        endif()
      elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "3.3")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0") # With std::to_string
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.13.0")
        endif()
      elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0") # With std::to_string
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.13.0")
        endif()
      elseif(MSVC)
        if(MSVC_VERSION LESS 1900)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        endif()
      endif()
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL "https://github.com/protocolbuffers/protobuf.git")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_DIR)
      project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_DIR "protobuf"
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION})
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_DIR)
      project_third_party_get_host_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_DIR "protobuf"
                                             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION})
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION MATCHES "^v(.*)")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION "${CMAKE_MATCH_1}")
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS
        ON
        CACHE BOOL "Allow build protobuf as dynamic(May cause duplicate symbol[File already exists in database])")

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-Dprotobuf_BUILD_TESTS=OFF" "-Dprotobuf_BUILD_EXAMPLES=OFF")

      project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
      if(CMAKE_DEBUG_POSTFIX)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
             "-Dprotobuf_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}")
      endif()

      if(VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_MSVC_STATIC_RUNTIME=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS)
        project_third_party_append_build_shared_lib_var(
          "protobuf" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS protobuf_BUILD_SHARED_LIBS
          BUILD_SHARED_LIBS)
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_BUILD_SHARED_LIBS=OFF"
             "-DBUILD_SHARED_LIBS=OFF")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION VERSION_GREATER_EQUAL "3.21.0")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_MODULE_COMPATIBLE=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION VERSION_GREATER_EQUAL "3.22.0" AND absl_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_ABSL_PROVIDER=package")
      endif()
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/protobuf-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")

    if(PROTOBUF_HOST_ROOT)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR ${PROTOBUF_HOST_ROOT})
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}")
    endif()

    if(NOT COMPILER_OPTIONS_TEST_RTTI)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS
          "${COMPILER_OPTION_INHERIT_CMAKE_CXX_FLAGS}")
      add_compiler_define_to_var(COMPILER_OPTION_INHERIT_CMAKE_CXX_FLAGS "GOOGLE_PROTOBUF_NO_RTTI")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN)
      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VISIBILITY_HIDDEN
         AND NOT DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VISIBILITY_HIDDEN})
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VISIBILITY_HIDDEN
            ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN})
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VISIBILITY_HIDDEN)
      if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_C_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS}")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS}")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS} -fvisibility=hidden")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
            "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS} -fvisibility=hidden")
      endif()
    endif()
    project_build_tools_append_cmake_options_for_lib(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS)
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VISIBILITY_HIDDEN)
      if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_C_FLAGS)
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_C_FLAGS}")
        else()
          unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS)
        endif()
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS)
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS}")
        else()
          unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS)
        endif()
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_C_FLAGS)
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS)
      endif()
    endif()
    project_third_party_append_find_root_args(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)

    if(NOT COMPILER_OPTIONS_TEST_RTTI)
      set(COMPILER_OPTION_INHERIT_CMAKE_CXX_FLAGS
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS}")
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BACKUP_CMAKE_CXX_FLAGS)
    endif()

    if(CMAKE_CROSSCOMPILING)
      list(APPEND CMAKE_PROGRAM_PATH
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR}/${CMAKE_INSTALL_BINDIR}")
    endif()
    set(Protobuf_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})

    if(CMAKE_VERSION VERSION_LESS "3.14"
       AND EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
       AND NOT EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")
      if(CMAKE_HOST_WIN32)
        execute_process(
          COMMAND mklink /D "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
          WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        execute_process(
          COMMAND ln -s "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib"
          WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
    endif()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FIND_LIB CACHE)
    find_library(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FIND_LIB
      NAMES protobuf libprotobuf protobufd libprotobufd
      PATHS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
      NO_DEFAULT_PATH)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FIND_LIB)
      if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_OPTIONS
            URL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL}" REPO_DIRECTORY
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}" BRANCH
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")

        project_third_party_try_patch_file(
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "protobuf"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_PATCH_FILE
           AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_PATCH_FILE}")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_OPTIONS PATCH_FILES
               "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_PATCH_FILE}")
        endif()
        project_git_clone_repository(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_OPTIONS})
      endif()

      if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/.git")
        echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Build protobuf failed")
        message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Protobuf is required")
      endif()

      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION VERSION_GREATER_EQUAL "3.21.0")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS "${CMAKE_COMMAND}"
             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS "${CMAKE_COMMAND}"
             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/cmake")
      endif()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS "${CMAKE_COMMAND}")
      project_build_tools_append_cmake_host_options(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION VERSION_GREATER_EQUAL "3.21.0")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS
             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}" "-Dprotobuf_BUILD_TESTS=OFF"
             "-Dprotobuf_BUILD_EXAMPLES=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS
             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/cmake" "-Dprotobuf_BUILD_TESTS=OFF"
             "-Dprotobuf_BUILD_EXAMPLES=OFF")
      endif()

      project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
      if(CMAKE_DEBUG_POSTFIX)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS
             "-Dprotobuf_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}")
      endif()

      if(VCPKG_HOST_CRT_LINKAGE STREQUAL "static" OR VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS "-Dprotobuf_MSVC_STATIC_RUNTIME=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS
             "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS)
        project_third_party_append_build_shared_lib_var(
          "protobuf" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS protobuf_BUILD_SHARED_LIBS
          BUILD_SHARED_LIBS)
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS "-Dprotobuf_BUILD_SHARED_LIBS=OFF"
             "-DBUILD_SHARED_LIBS=OFF")
      endif()

      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_DIR}")
      if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR})
        file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR})
      endif()

      foreach(
        CMD_ARG IN
        LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS
              ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS
              ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
        string(REPLACE ";" "\\;" CMD_ARG_UNESCAPE "${CMD_ARG}")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_PWSH)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_PWSH
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_PWSH} \"${CMD_ARG_UNESCAPE}\"")
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_PWSH "\"${CMD_ARG_UNESCAPE}\"")
        endif()
        string(REPLACE "\$" "\\\$" CMD_ARG_UNESCAPE "${CMD_ARG_UNESCAPE}")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_BASH)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_BASH
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_BASH} \"${CMD_ARG_UNESCAPE}\"")
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_BASH "\"${CMD_ARG_UNESCAPE}\"")
        endif()
      endforeach()

      foreach(CMD_ARG IN LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
        string(REPLACE ";" "\\;" CMD_ARG_UNESCAPE "${CMD_ARG}")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_PWSH)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_PWSH
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_PWSH} \"${CMD_ARG_UNESCAPE}\"")
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_PWSH "\"${CMD_ARG_UNESCAPE}\"")
        endif()
        string(REPLACE "\$" "\\\$" CMD_ARG_UNESCAPE "${CMD_ARG_UNESCAPE}")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_BASH)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_BASH
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_BASH} \"${CMD_ARG_UNESCAPE}\"")
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_BASH "\"${CMD_ARG_UNESCAPE}\"")
        endif()
      endforeach()
      unset(CMD_ARG_UNESCAPE)

      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH
         OR CMAKE_HOST_UNIX
         OR MSYS)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/run-build-release.sh.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.sh" @ONLY
          NEWLINE_STYLE LF)

        # build
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.sh"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/run-build-release.ps1.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.ps1" @ONLY
          NEWLINE_STYLE CRLF)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/run-build-release.bat.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.bat" @ONLY
          NEWLINE_STYLE CRLF)

        # build
        execute_process(
          COMMAND
            "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass -NonInteractive
            -NoLogo -File "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.ps1"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS)
    endif()

    # prefer to find protoc from host prebuilt directory
    if(CMAKE_CROSSCOMPILING)
      find_program(
        Protobuf_PROTOC_EXECUTABLE
        NAMES protoc protoc.exe
        PATHS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR}/${CMAKE_INSTALL_BINDIR}"
        NO_DEFAULT_PATH)
      message(STATUS "Cross Compiling: using hosted protoc: ${Protobuf_PROTOC_EXECUTABLE}")
      set(Protobuf_PROTOC_EXECUTABLE
          "${Protobuf_PROTOC_EXECUTABLE}"
          CACHE PATH "host protoc" FORCE)
      set(PROTOBUF_PROTOC_EXECUTABLE
          "${Protobuf_PROTOC_EXECUTABLE}"
          CACHE PATH "host protoc" FORCE)
    endif()

    if($ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_LOCAL})
      find_package(Protobuf)
    else()
      find_package(Protobuf CONFIG)
    endif()
    project_third_party_protobuf_import()
  endif()

  if(TARGET protobuf::protoc
     OR TARGET protobuf::libprotobuf
     OR TARGET protobuf::libprotobuf-lite)
    echowithcolor(
      COLOR GREEN
      "-- Dependency(${PROJECT_NAME}): Protobuf found.(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC})")
    echowithcolor(
      COLOR
      GREEN
      "-- Dependency(${PROJECT_NAME}): Protobuf libraries.(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME})"
    )
  else()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_DIR STREQUAL
         ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_DIR)
        project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_DIR}")
      endif()
      project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_DIR}")
    endif()
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Protobuf is required")
    message(FATAL_ERROR "Protobuf not found")
  endif()
else()
  project_third_party_protobuf_import()
endif()
