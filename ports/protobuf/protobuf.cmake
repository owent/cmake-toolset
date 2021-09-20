include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_PROTOBUF_IMPORT)
  if(TARGET protobuf::protoc
     OR TARGET protobuf::libprotobuf
     OR TARGET protobuf::libprotobuf-lite)
    if(TARGET protobuf::libprotobuf OR TARGET protobuf::libprotobuf-lite)
      if(TARGET protobuf::libprotobuf)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME protobuf::libprotobuf)
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME protobuf::libprotobuf-lite)
      endif()

      if(TARGET protobuf::libprotobuf)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME protobuf::libprotobuf-lite)
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
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC ${PROTOBUF_PROTOC_EXECUTABLE})
    endif()
    project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
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
      # set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.17.3")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.18.0")

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
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS
        OFF
        CACHE
          BOOL
          "Allow build protobuf as dynamic(May cause duplicate symbol in global data base[File already exists in database])"
    )

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
          "-Dprotobuf_BUILD_TESTS=OFF" "-Dprotobuf_BUILD_EXAMPLES=OFF" "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")

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
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/protobuf-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")

    if(PROTOBUF_HOST_ROOT)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR ${PROTOBUF_HOST_ROOT})
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}")
    endif()

    project_build_tools_append_cmake_options_for_lib(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS)
    project_third_party_append_find_root_args(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)

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
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/protobuf-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}.patch")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_OPTIONS PATCH_FILES
               "${CMAKE_CURRENT_LIST_DIR}/protobuf-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}.patch")
        endif()
        project_git_clone_repository(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_OPTIONS})
      endif()

      if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/.git")
        echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Build protobuf failed")
        message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Protobuf is required")
      endif()

      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS "${CMAKE_COMMAND}"
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/cmake")
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS
        "${CMAKE_COMMAND}"
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/cmake"
        "-Dprotobuf_BUILD_TESTS=OFF"
        "-Dprotobuf_BUILD_EXAMPLES=OFF"
        "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")

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
        add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_CMD "\"${CMD_ARG}\"")
      endforeach()

      foreach(CMD_ARG IN LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
        add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_CMD "\"${CMD_ARG}\"")
      endforeach()

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

        if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          echowithcolor(
            COLOR RED "-- Dependency(${PROJECT_NAME}): powershell-core or powershell is required to configure protobuf")
          message(FATAL_ERROR "powershell-core or powershell is required")
        endif()
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

    if($ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_LOCAL})
      find_package(Protobuf)
    else()
      find_package(Protobuf CONFIG)
    endif()
    # prefer to find protoc from host prebuilt directory
    if(CMAKE_CROSSCOMPILING)
      find_program(
        Protobuf_PROTOC_EXECUTABLE_HOST
        NAMES protoc protoc.exe
        PATHS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR}/${CMAKE_INSTALL_BINDIR}"
        NO_DEFAULT_PATH)
      message(STATUS "Cross Compiling: using hosted protoc: ${Protobuf_PROTOC_EXECUTABLE_HOST}")
      if(DEFINED Protobuf_PROTOC_EXECUTABLE)
        set(Protobuf_PROTOC_EXECUTABLE "${Protobuf_PROTOC_EXECUTABLE_HOST}")
      endif()
      if(DEFINED CACHE{Protobuf_PROTOC_EXECUTABLE})
        set(Protobuf_PROTOC_EXECUTABLE
            "${Protobuf_PROTOC_EXECUTABLE_HOST}"
            CACHE PATH "host protoc" FORCE)
      endif()
      if(DEFINED PROTOBUF_PROTOC_EXECUTABLE)
        set(PROTOBUF_PROTOC_EXECUTABLE "${Protobuf_PROTOC_EXECUTABLE_HOST}")
      endif()
      if(DEFINED CACHE{PROTOBUF_PROTOC_EXECUTABLE})
        set(PROTOBUF_PROTOC_EXECUTABLE
            "${Protobuf_PROTOC_EXECUTABLE_HOST}"
            CACHE PATH "host protoc" FORCE)
      endif()

      # Set protoc and libprotoc to hosted targets
      if(NOT TARGET protobuf::protoc)
        add_executable(protobuf::protoc IMPORTED)
      endif()
      set_target_properties(
        protobuf::protoc
        PROPERTIES IMPORTED_LOCATION "${Protobuf_PROTOC_EXECUTABLE_HOST}"
                   IMPORTED_LOCATION_RELEASE "${Protobuf_PROTOC_EXECUTABLE_HOST}"
                   IMPORTED_LOCATION_RELWITHDEBINFO "${Protobuf_PROTOC_EXECUTABLE_HOST}"
                   IMPORTED_LOCATION_MINSIZEREL "${Protobuf_PROTOC_EXECUTABLE_HOST}"
                   IMPORTED_LOCATION_DEBUG "${Protobuf_PROTOC_EXECUTABLE_HOST}"
                   IMPORTED_LOCATION_NOCONFIG "${Protobuf_PROTOC_EXECUTABLE_HOST}")
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
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Protobuf is required")
    message(FATAL_ERROR "Protobuf not found")
  endif()
else()
  project_third_party_protobuf_import()
endif()
