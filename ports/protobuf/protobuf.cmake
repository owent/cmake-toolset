include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_PROTOBUF_IMPORT)
  if(Protobuf_FOUND
     AND Protobuf_INCLUDE_DIRS
     AND Protobuf_LIBRARY
     AND Protobuf_PROTOC_EXECUTABLE)
    if(TARGET protobuf::libprotobuf AND TARGET protobuf::libprotobuf-lite)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME protobuf::libprotobuf)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME protobuf::libprotobuf-lite)
      echowithcolor(
        COLOR GREEN
        "-- Dependency(${PROJECT_NAME}): Protobuf libraries.(${Protobuf_LIBRARY_DEBUG})")
      echowithcolor(
        COLOR GREEN
        "-- Dependency(${PROJECT_NAME}): Protobuf lite libraries.(${Protobuf_LITE_LIBRARY_DEBUG})")
      get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_INC_DIR
                          protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)
    elseif(${CMAKE_BUILD_TYPE} STREQUAL "Debug" AND Protobuf_LIBRARY_DEBUG)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_INC_DIR ${PROTOBUF_INCLUDE_DIRS})
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME ${Protobuf_LIBRARY_DEBUG})
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME
          ${Protobuf_LITE_LIBRARY_DEBUG})
      echowithcolor(
        COLOR GREEN
        "-- Dependency(${PROJECT_NAME}): Protobuf libraries.(${Protobuf_LIBRARY_DEBUG})")
      echowithcolor(
        COLOR GREEN
        "-- Dependency(${PROJECT_NAME}): Protobuf lite libraries.(${Protobuf_LITE_LIBRARY_DEBUG})")
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_INC_DIR ${PROTOBUF_INCLUDE_DIRS})
      if(Protobuf_LIBRARY_RELEASE)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME ${Protobuf_LIBRARY_RELEASE})
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME ${Protobuf_LIBRARY})
      endif()
      if(Protobuf_LITE_LIBRARY_RELEASE)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME
            ${Protobuf_LITE_LIBRARY_RELEASE})
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LITE_LINK_NAME ${Protobuf_LIBRARY})
      endif()
      echowithcolor(COLOR GREEN
                    "-- Dependency(${PROJECT_NAME}): Protobuf libraries.(${Protobuf_LIBRARY})")
      echowithcolor(
        COLOR GREEN
        "-- Dependency(${PROJECT_NAME}): Protobuf lite libraries.(${Protobuf_LITE_LIBRARY})")
    endif()

    if(Protobuf_PROTOC_EXECUTABLE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC ${Protobuf_PROTOC_EXECUTABLE})
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC ${PROTOBUF_PROTOC_EXECUTABLE})
    endif()
    if(UNIX)
      execute_process(COMMAND chmod +x
                              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_INC_DIR)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_INC_DIR})
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME})
    endif()

    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN
         "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/protoc*")
  endif()
endmacro()

# =========== third party protobuf ==================
if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC
   OR (NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_LINK_NAME
       AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_INC_DIR))

  if(VCPKG_TOOLCHAIN)
    find_package(Protobuf QUIET CONFIG)
    project_third_party_protobuf_import()
  endif()

  if(NOT Protobuf_FOUND
     OR NOT Protobuf_PROTOC_EXECUTABLE
     OR NOT Protobuf_INCLUDE_DIRS
     OR NOT Protobuf_LIBRARY)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.15.8")

      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        endif()
      elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "3.3")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        endif()
      elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        endif()
      elseif(MSVC)
        if(MSVC_VERSION LESS 1900)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION "v3.5.1")
        endif()
      endif()
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL
          "https://github.com/protocolbuffers/protobuf.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
          "-Dprotobuf_BUILD_TESTS=OFF" "-Dprotobuf_BUILD_EXAMPLES=OFF"
          "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")

      if(defined BUILD_SHARED_LIBS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
             "-Dprotobuf_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}")
      elseif(defined ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
             "-Dprotobuf_BUILD_SHARED_LIBS=${ATFRAMEWORK_USE_DYNAMIC_LIBRARY}")
      endif()
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/protobuf-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}"
    )

    if(PROTOBUF_HOST_ROOT)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR ${PROTOBUF_HOST_ROOT})
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR
          "${PROJECT_THIRD_PARTY_INSTALL_DIR}/../${PROJECT_PREBUILT_HOST_PLATFORM_NAME}")
    endif()

    project_build_tools_append_cmake_options_for_lib(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS)

    if(NOT PROJECT_PREBUILT_PLATFORM_NAME STREQUAL PROJECT_PREBUILT_HOST_PLATFORM_NAME)
      list(
        APPEND CMAKE_PROGRAM_PATH
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR}/${CMAKE_INSTALL_BINDIR}")
    endif()
    set(Protobuf_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})

    if(CMAKE_VERSION VERSION_LESS "3.14"
       AND EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
       AND NOT EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")
      if(CMAKE_HOST_WIN32)
        execute_process(
          COMMAND mklink /D "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib"
                  "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
          WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR})
      else()
        execute_process(
          COMMAND ln -s "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
                  "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib"
          WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR})
      endif()
    endif()

    set(Protobuf_USE_STATIC_LIBS ON)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FIND_LIB CACHE)
    find_library(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FIND_LIB
      NAMES protobuf libprotobuf protobufd libprotobufd
      PATHS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
      NO_DEFAULT_PATH)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FIND_LIB)
      if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}")
        project_git_clone_repository(
          URL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_GIT_URL}" REPO_DIRECTORY
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}" BRANCH
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")
      endif()

      if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/.git")
        echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Build protobuf failed")
        message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Protobuf is required")
      endif()

      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS)
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS
        ${CMAKE_COMMAND}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/cmake"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS}
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS}
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SHARED_LIBS})
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS ${CMAKE_COMMAND}
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR}/cmake"
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS})

      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR
          "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/protobuf-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}"
      )
      if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR})
        file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR})
      endif()

      if(PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_MULTI_CORE
            ${FindConfigurePackageCMakeBuildMultiJobs})
      else()
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_MULTI_CORE)
      endif()

      string(REGEX
             REPLACE ";" "\" \"" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_CMD
                     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_CMD
          "\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_FLAGS_CMD}\"")
      string(
        REGEX
        REPLACE ";" "\" \"" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_CMD
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_CMD
          "\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_FLAGS_CMD}\"")

      if(CMAKE_HOST_UNIX OR MSYS)
        message(
          STATUS
            "@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR} Run: run-build-release.sh"
        )
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/run-build-release.sh.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.sh"
          @ONLY NEWLINE_STYLE LF)

        # build
        execute_process(
          COMMAND
            bash
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.sh"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR})
      else()
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/run-build-release.ps1.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.ps1"
          @ONLY NEWLINE_STYLE CRLF)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/run-build-release.bat.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.bat"
          @ONLY NEWLINE_STYLE CRLF)

        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_POWERSHELL_BIN NAMES pwsh
                                                                                         pwsh.exe)
        if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_POWERSHELL_BIN)
          find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_POWERSHELL_BIN
                       NAMES powershell powershell.exe)
        endif()
        if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_POWERSHELL_BIN)
          echowithcolor(
            COLOR
            RED
            "-- Dependency(${PROJECT_NAME}): powershell-core or powershell is required to configure protobuf"
          )
          message(FATAL_ERROR "powershell-core or powershell is required")
        endif()
        # build
        message(
          STATUS
            "@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR} Run: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_POWERSHELL_BIN} -NoProfile -InputFormat None -ExecutionPolicy Bypass -NonInteractive -NoLogo -File run-build-release.ps1"
        )
        execute_process(
          COMMAND
            ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_POWERSHELL_BIN} -NoProfile -InputFormat
            None -ExecutionPolicy Bypass -NonInteractive -NoLogo -File
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR}/run-build-release.ps1"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_SCRIPT_DIR})
      endif()
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_MULTI_CORE)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_FLAG_OPTIONS)
    endif()

    # prefer to find protoc from host prebuilt directory
    if(NOT PROJECT_PREBUILT_PLATFORM_NAME STREQUAL PROJECT_PREBUILT_HOST_PLATFORM_NAME)
      find_program(
        Protobuf_PROTOC_EXECUTABLE
        NAMES protoc protoc.exe
        PATHS
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR}/${CMAKE_INSTALL_BINDIR}"
        NO_DEFAULT_PATH)
    endif()
    find_package(Protobuf QUIET CONFIG)
    project_third_party_protobuf_import()
  endif()

  # try again, cached vars will cause find failed.
  if(NOT Protobuf_FOUND
     OR NOT Protobuf_PROTOC_EXECUTABLE
     OR NOT Protobuf_INCLUDE_DIRS
     OR NOT Protobuf_LIBRARY)
    if(CMAKE_VERSION VERSION_LESS "3.14"
       AND EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
       AND NOT EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")
      if(CMAKE_HOST_WIN32)
        execute_process(
          COMMAND mklink /D "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib"
                  "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
          WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR})
      else()
        execute_process(
          COMMAND ln -s "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
                  "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib"
          WORKING_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR})
      endif()
    endif()
    echowithcolor(COLOR YELLOW
                  "-- Dependency(${PROJECT_NAME}): Try to find protobuf libraries again")
    unset(Protobuf_FOUND)
    unset(Protobuf_FOUND CACHE)
    unset(PROTOBUF_FOUND)
    unset(PROTOBUF_FOUND CACHE)
    if(NOT Protobuf_PROTOC_EXECUTABLE)
      unset(Protobuf_PROTOC_EXECUTABLE)
      unset(Protobuf_PROTOC_EXECUTABLE CACHE)
      unset(PROTOBUF_PROTOC_EXECUTABLE)
      unset(PROTOBUF_PROTOC_EXECUTABLE CACHE)
    endif()
    unset(Protobuf_LIBRARY)
    unset(Protobuf_LIBRARY CACHE)
    unset(Protobuf_PROTOC_LIBRARY)
    unset(Protobuf_PROTOC_LIBRARY CACHE)
    unset(Protobuf_INCLUDE_DIR)
    unset(Protobuf_INCLUDE_DIR CACHE)
    unset(Protobuf_LIBRARY_DEBUG)
    unset(Protobuf_LIBRARY_DEBUG CACHE)
    unset(Protobuf_PROTOC_LIBRARY_DEBUG)
    unset(Protobuf_PROTOC_LIBRARY_DEBUG CACHE)
    unset(Protobuf_LITE_LIBRARY)
    unset(Protobuf_LITE_LIBRARY CACHE)
    unset(Protobuf_LITE_LIBRARY_DEBUG)
    unset(Protobuf_LITE_LIBRARY_DEBUG CACHE)
    unset(Protobuf_VERSION)
    unset(Protobuf_VERSION CACHE)
    unset(Protobuf_INCLUDE_DIRS)
    unset(Protobuf_INCLUDE_DIRS CACHE)
    unset(Protobuf_LIBRARIES)
    unset(Protobuf_LIBRARIES CACHE)
    unset(Protobuf_PROTOC_LIBRARIES)
    unset(Protobuf_PROTOC_LIBRARIES CACHE)
    unset(Protobuf_LITE_LIBRARIES)
    unset(Protobuf_LITE_LIBRARIES CACHE)
    unset(Protobuf::protoc)
    find_package(Protobuf)
    project_third_party_protobuf_import()
  endif()

  if(Protobuf_FOUND AND Protobuf_LIBRARY)
    echowithcolor(COLOR GREEN
                  "-- Dependency(${PROJECT_NAME}): Protobuf found.(${Protobuf_PROTOC_EXECUTABLE})")
    echowithcolor(COLOR GREEN
                  "-- Dependency(${PROJECT_NAME}): Protobuf include.(${Protobuf_INCLUDE_DIRS})")
  else()
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): Protobuf is required")
    message(FATAL_ERROR "Protobuf not found")
  endif()
else()
  project_third_party_protobuf_import()
endif()
