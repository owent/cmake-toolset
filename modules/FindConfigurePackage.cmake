# .rst: FindConfigurePackage
# ----------------
#
# find package, and try to configure it when not found in system.
#
# FindConfigurePackage(
#   PACKAGE <name>
#   DISABLE_PARALLEL_BUILD
#   BUILD_WITH_CONFIGURE
#   BUILD_WITH_CMAKE
#   BUILD_WITH_SCONS
#   BUILD_WITH_CUSTOM_COMMAND
#   CONFIGURE_FLAGS [configure options...]
#   CMAKE_FLAGS [cmake options...]
#   FIND_PACKAGE_FLAGS [options will be passed into find_package(...)]
#   CMAKE_INHERIT_BUILD_ENV
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_CMAKE_FIND_ROOT_FLAGS
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_CMAKE_TOOLSET_MODULES
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_ASM_FLAGS
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_C_STANDARD
#   CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_STANDARD
#   CMAKE_INHERIT_FIND_ROOT_PATH
#   CMAKE_INHERIT_SYSTEM_LINKS
#   SCONS_FLAGS [scons options...]
#   CUSTOM_BUILD_COMMAND [custom build cmd...]
#   MAKE_FLAGS [make options...]
#   LIST_SEPARATOR <sep>
#   PREBUILD_COMMAND [run cmd before build ...]
#   AFTERBUILD_COMMAND [run cmd after build ...]
#   RESET_FIND_VARS [cmake vars]
#   WORKING_DIRECTORY <work directory>
#   BUILD_DIRECTORY <build directory>
#   PREFIX_DIRECTORY <prefix directory>
#   SRC_DIRECTORY_NAME <source directory name>
#   MSVC_CONFIGURE <Debug/Release/RelWithDebInfo/MinSizeRel>
#   CMAKE_INSTALL_CONFIGURE <Debug/Release/RelWithDebInfo/MinSizeRel>
#   AUTOGEN_CONFIGURE [autogen command and args...]
#   INSTALL_TARGET [install targets...]
#   INSTALL_COMPONENT [install components...]
#   ZIP_URL <zip url>
#   TAR_URL <tar url>
#   SVN_URL <svn url>
#   GIT_URL <git url>
#   GIT_BRANCH <git branch>
#   GIT_COMMIT <git commit sha>
#   GIT_PATCH_FILES [git patch files...]
#   GIT_FETCH_FILTER <filter>
#   GIT_SPARSE_CHECKOUT <path>
# )
#
# ::
#
# <configure options>         - flags added to configure command
# <cmake options>             - flags added to cmake command
# <scons options>             - flags added to scons command
# <custom build cmd>          - custom commands for build
# <make options>              - flags added to make command
# <pre build cmd>             - commands to run before build tool
# <autogen command and args>  - command and arguments to run before configure.(on source directory)
# <work directory>            - work directory
# <build directory>           - where to execute configure and make
# <prefix directory>          - prefix directory(default: <work directory>)
# <source directory name>     - source directory name(default detected by download url)
# <install targets>           - which target(s) used to install package(default: install) <zip url> - from where to download zip when find package failed
# <tar url>                   - from where to download tar.* or tgz when find package failed <svn url>               - from where to svn co when find package failed
# <git url>                   - from where to git clone when find package failed
# <git branch>                - git branch or tag to fetch
# <git commit>                - git commit to fetch, server must support --deepen=<depth>. if both <git branch> and <git commit> is set, we will use <git branch>
# <fetch depth/deepen>        - --deepen or --depth for git fetch depend using <git branch> or <git commit>
# <git patch files>           - git apply [git patch files...]
# <sep>                       - replace ``;`` with ``<sep>`` in the specified command lines.Just like LIST_SEPARATOR in ExternalProject
#

# =============================================================================
# Copyright 2021 atframework.
#
# Distributed under the Apache License Version 2.0 (the "License"); see accompanying file LICENSE for details.

include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/ProjectBuildTools.cmake")

function(FindConfigurePackageDownloadFile from to)
  set(AVAILABLE_HASH_ALGORITHMS MD5 SHA1 SHA256)
  cmake_parse_arguments(FindConfigurePackageDownloadFile "REQUIRED" "${AVAILABLE_HASH_ALGORITHMS}" "" ${ARGN})
  find_program(WGET_FULL_PATH wget)
  if(WGET_FULL_PATH)
    execute_process(
      COMMAND "${WGET_FULL_PATH}" "--no-check-certificate" "-t" "${PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES}" "-v"
              "${from}" "-O" "${to}" ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
  else()
    if(CMAKE_CROSSCOMPILING)
      set(CURL_CROSSING_FIND_PATHS)
      if(PROJECT_THIRD_PARTY_HOST_INSTALL_DIR)
        list(APPEND CURL_CROSSING_FIND_PATHS "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/bin")
      endif()
      if(CMAKE_STAGING_PREFIX)
        list(APPEND CURL_CROSSING_FIND_PATHS "${CMAKE_STAGING_PREFIX}/bin")
      endif()
      if(CMAKE_HOST_PROGRAM_PATH)
        list(APPEND CURL_CROSSING_FIND_PATHS "${CMAKE_HOST_PROGRAM_PATH}")
      endif()
      if(CMAKE_HOST_SYSTEM_PROGRAM_PATH)
        list(APPEND CURL_CROSSING_FIND_PATHS "${CMAKE_HOST_SYSTEM_PROGRAM_PATH}")
      endif()
      find_program(
        CURL_EXECUTABLE
        NAMES curl curl.exe
        PATHS ${CURL_CROSSING_FIND_PATHS} NO_PACKAGE_ROOT_PATH
        NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_FIND_ROOT_PATH)
    else()
      find_program(CURL_FULL_PATH curl)
    endif()
    if(CURL_FULL_PATH)
      execute_process(COMMAND "${CURL_FULL_PATH}" "--insecure" "--retry" "${PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES}"
                              "-L" "${from}" "-o" "${to}" ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    else()
      set(FindConfigurePackageDownloadFile_RETRY_TIMES 0)
      while(FindConfigurePackageDownloadFile_RETRY_TIMES LESS_EQUAL PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES)
        if(FindConfigurePackageDownloadFile_RETRY_TIMES GREATER 0)
          message(
            STATUS
              "Retry to download file from ${from} for the ${FindConfigurePackageDownloadFile_RETRY_TIMES} time(s).")
        endif()
        math(EXPR FindConfigurePackageDownloadFile_RETRY_TIMES "${FindConfigurePackageDownloadFile_RETRY_TIMES} + 1"
             OUTPUT_FORMAT DECIMAL)
        file(
          DOWNLOAD "${from}" "${to}"
          SHOW_PROGRESS
          TLS_VERIFY OFF)
        if(EXISTS "${to}")
          break()
        endif()
      endwhile()
    endif()
  endif()

  if(EXISTS "${to}")
    foreach(TEST_HASH_ALGORITHM IN LISTS AVAILABLE_HASH_ALGORITHMS)
      if(FindConfigurePackageDownloadFile_${TEST_HASH_ALGORITHM})
        file(${TEST_HASH_ALGORITHM} "${to}" FindConfigurePackageDownloadFile_CHECK_HASH)
        string(TOLOWER "${FindConfigurePackageDownloadFile_${TEST_HASH_ALGORITHM}}" HASH_EXCEPT)
        string(TOLOWER "${FindConfigurePackageDownloadFile_CHECK_HASH}" HASH_REAL)
        if(NOT HASH_EXCEPT STREQUAL HASH_REAL)
          if(FindConfigurePackageDownloadFile_REQUIRED)
            message(
              FATAL_ERROR
                "Hash(${TEST_HASH_ALGORITHM}) of ${to} mismatched.\n\tExcept: ${HASH_EXCEPT}\n\tReal: ${HASH_REAL}")
          else()
            message(
              WARNING
                "Hash(${TEST_HASH_ALGORITHM}) of ${to} mismatched.\n\tExcept: ${HASH_EXCEPT}\n\tReal: ${HASH_REAL}\n\t We will remove it."
            )
            file(REMOVE "${to}")
          endif()
        endif()
      endif()
    endforeach()
  endif()
endfunction()

function(FindConfigurePackageUnzip src work_dir)
  if(CMAKE_HOST_UNIX)
    find_program(FindConfigurePackage_UNZIP_BIN unzip)
    if(FindConfigurePackage_UNZIP_BIN)
      execute_process(COMMAND ${FindConfigurePackage_UNZIP_BIN} -uo ${src}
                      WORKING_DIRECTORY ${work_dir} ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      return()
    endif()
  endif()
  # fallback
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${src}
                  WORKING_DIRECTORY ${work_dir} ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
endfunction()

function(FindConfigurePackageTarXV src work_dir)
  if(CMAKE_HOST_UNIX)
    find_program(FindConfigurePackage_TAR_BIN tar)
    if(FindConfigurePackage_TAR_BIN)
      execute_process(COMMAND ${FindConfigurePackage_TAR_BIN} -xvf ${src}
                      WORKING_DIRECTORY ${work_dir} ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      return()
    endif()
  endif()
  # fallback
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${src}
                  WORKING_DIRECTORY ${work_dir} ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
endfunction()

function(FindConfigurePackageRemoveEmptyDir DIR)
  if(EXISTS ${DIR})
    file(GLOB RESULT "${DIR}/*")
    list(LENGTH RESULT RES_LEN)
    if(${RES_LEN} EQUAL 0)
      file(REMOVE_RECURSE ${DIR})
    endif()
  endif()
endfunction()

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12")
  set(FindConfigurePackageCMakeBuildMultiJobs
      "--parallel"
      CACHE INTERNAL "Build options for multi-jobs")
  unset(CPU_CORE_NUM)
elseif(
  (CMAKE_MAKE_PROGRAM STREQUAL "make")
  OR (CMAKE_MAKE_PROGRAM STREQUAL "gmake")
  OR (CMAKE_MAKE_PROGRAM STREQUAL "ninja"))
  cmake_host_system_information(RESULT CPU_CORE_NUM QUERY NUMBER_OF_PHYSICAL_CORES)
  set(FindConfigurePackageCMakeBuildMultiJobs
      "--" "-j${CPU_CORE_NUM}"
      CACHE INTERNAL "Build options for multi-jobs")
  unset(CPU_CORE_NUM)
elseif(CMAKE_MAKE_PROGRAM STREQUAL "xcodebuild")
  cmake_host_system_information(RESULT CPU_CORE_NUM QUERY NUMBER_OF_PHYSICAL_CORES)
  set(FindConfigurePackageCMakeBuildMultiJobs
      "--" "-jobs" ${CPU_CORE_NUM}
      CACHE INTERNAL "Build options for multi-jobs")
  unset(CPU_CORE_NUM)
elseif(CMAKE_VS_MSBUILD_COMMAND)
  set(FindConfigurePackageCMakeBuildMultiJobs
      "--" "/m"
      CACHE INTERNAL "Build options for multi-jobs")
endif()

if(NOT FindConfigurePackageGitFetchDepth)
  set(FindConfigurePackageGitFetchDepth
      100
      CACHE STRING "Defalut depth of git clone/fetch")
endif()

macro(FindConfigurePackage)
  set(optionArgs
      DISABLE_PARALLEL_BUILD
      BUILD_WITH_CONFIGURE
      BUILD_WITH_CMAKE
      BUILD_WITH_SCONS
      BUILD_WITH_CUSTOM_COMMAND
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CMAKE_FIND_ROOT_FLAGS
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CMAKE_TOOLSET_MODULES
      CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHERIT_BUILD_ENV_DISABLE_ASM_FLAGS
      CMAKE_INHERIT_BUILD_ENV_DISABLE_C_STANDARD
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_STANDARD
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_SYSTEM_LINKS
      GIT_ENABLE_SUBMODULE
      GIT_SUBMODULE_RECURSIVE
      GIT_FORCE_RESET
      GIT_ALWAYS_UPDATE_REMOTE)
  set(oneValueArgs
      PACKAGE
      PORT_PREFIX
      WORKING_DIRECTORY
      BUILD_DIRECTORY
      PREFIX_DIRECTORY
      SRC_DIRECTORY_NAME
      PROJECT_DIRECTORY
      MSVC_CONFIGURE
      CMAKE_INSTALL_CONFIGURE
      LIST_SEPARATOR
      ZIP_URL
      TAR_URL
      SVN_URL
      GIT_URL
      GIT_BRANCH
      GIT_COMMIT
      GIT_FETCH_DEPTH
      GIT_SPARSE_CHECKOUT)
  set(multiValueArgs
      AUTOGEN_CONFIGURE
      CONFIGURE_CMD
      CONFIGURE_FLAGS
      CMAKE_FLAGS
      FIND_PACKAGE_FLAGS
      RESET_FIND_VARS
      SCONS_FLAGS
      MAKE_FLAGS
      CUSTOM_BUILD_COMMAND
      PREBUILD_COMMAND
      AFTERBUILD_COMMAND
      INSTALL_TARGET
      INSTALL_COMPONENT
      GIT_PATCH_FILES
      GIT_SUBMODULE_PATHS
      GIT_RESET_SUBMODULE_URLS
      GIT_FETCH_FILTER)
  foreach(RESTORE_VAR IN LISTS optionArgs oneValueArgs multiValueArgs)
    unset(FindConfigurePackage_${RESTORE_VAR})
  endforeach()

  cmake_parse_arguments(FindConfigurePackage "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # some module is not match standard, using upper case but package name
  string(TOUPPER "${FindConfigurePackage_PACKAGE}_FOUND" FIND_CONFIGURE_PACKAGE_UPPER_NAME)

  unset(FindConfigurePackage_BACKUP_CMAKE_FIND_ROOT_PATH)
  unset(FindConfigurePackage_BACKUP_CMAKE_PREFIX_PATH)

  if(FindConfigurePackage_PORT_PREFIX AND NOT "${FindConfigurePackage_PORT_PREFIX}" STREQUAL "")
    string(
      TOUPPER
        "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_PORT_PREFIX}_${FindConfigurePackage_PACKAGE}"
        FindConfigurePackage_FULL_PORT_NAME)
  else()
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_PACKAGE}"
                   FindConfigurePackage_FULL_PORT_NAME)
  endif()

  # step 1. find using standard method
  find_package(${FindConfigurePackage_PACKAGE} QUIET ${FindConfigurePackage_FIND_PACKAGE_FLAGS})
  if(NOT ${FindConfigurePackage_PACKAGE}_FOUND AND NOT ${FIND_CONFIGURE_PACKAGE_UPPER_NAME})
    if(NOT FindConfigurePackage_PREFIX_DIRECTORY)
      # prefix
      set(FindConfigurePackage_PREFIX_DIRECTORY ${FindConfigurePackage_WORK_DIRECTORY})
    endif()

    if(NOT "${FindConfigurePackage_PREFIX_DIRECTORY}" IN_LIST CMAKE_FIND_ROOT_PATH)
      set(FindConfigurePackage_BACKUP_CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH})
      list(APPEND CMAKE_FIND_ROOT_PATH ${FindConfigurePackage_PREFIX_DIRECTORY})
    endif()
    if(NOT "${FindConfigurePackage_PREFIX_DIRECTORY}" IN_LIST CMAKE_PREFIX_PATH)
      set(FindConfigurePackage_BACKUP_CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH})
      list(APPEND CMAKE_PREFIX_PATH ${FindConfigurePackage_PREFIX_DIRECTORY})
    endif()

    # step 2. find in prefix
    find_package(${FindConfigurePackage_PACKAGE} QUIET ${FindConfigurePackage_FIND_PACKAGE_FLAGS})

    # step 3. build
    if(NOT ${FindConfigurePackage_PACKAGE}_FOUND AND NOT ${FIND_CONFIGURE_PACKAGE_UPPER_NAME})
      set(FindConfigurePackage_UNPACK_SOURCE NO)

      # tar package
      if(NOT FindConfigurePackage_UNPACK_SOURCE AND FindConfigurePackage_TAR_URL)
        get_filename_component(DOWNLOAD_FILENAME "${FindConfigurePackage_TAR_URL}" NAME)
        if(NOT FindConfigurePackage_SRC_DIRECTORY_NAME)
          string(REGEX REPLACE "\\.tar\\.[A-Za-z0-9]+$" "" FindConfigurePackage_SRC_DIRECTORY_NAME
                               "${DOWNLOAD_FILENAME}")
        endif()
        set(FindConfigurePackage_DOWNLOAD_SOURCE_DIR
            "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}")
        findconfigurepackageremoveemptydir(${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})

        if(NOT EXISTS "${FindConfigurePackage_WORKING_DIRECTORY}/${DOWNLOAD_FILENAME}")
          message(STATUS "start to download ${DOWNLOAD_FILENAME} from ${FindConfigurePackage_TAR_URL}")
          findconfigurepackagedownloadfile("${FindConfigurePackage_TAR_URL}"
                                           "${FindConfigurePackage_WORKING_DIRECTORY}/${DOWNLOAD_FILENAME}")
        endif()

        findconfigurepackagetarxv("${FindConfigurePackage_WORKING_DIRECTORY}/${DOWNLOAD_FILENAME}"
                                  ${FindConfigurePackage_WORKING_DIRECTORY})

        if(EXISTS ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
          set(FindConfigurePackage_UNPACK_SOURCE YES)
        endif()
      endif()

      # zip package
      if(NOT FindConfigurePackage_UNPACK_SOURCE AND FindConfigurePackage_ZIP_URL)
        get_filename_component(DOWNLOAD_FILENAME "${FindConfigurePackage_ZIP_URL}" NAME)
        if(NOT FindConfigurePackage_SRC_DIRECTORY_NAME)
          string(REGEX REPLACE "\\.zip$" "" FindConfigurePackage_SRC_DIRECTORY_NAME "${DOWNLOAD_FILENAME}")
        endif()
        set(FindConfigurePackage_DOWNLOAD_SOURCE_DIR
            "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}")
        findconfigurepackageremoveemptydir(${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})

        if(NOT EXISTS "${FindConfigurePackage_WORKING_DIRECTORY}/${DOWNLOAD_FILENAME}")
          message(STATUS "start to download ${DOWNLOAD_FILENAME} from ${FindConfigurePackage_ZIP_URL}")
          findconfigurepackagedownloadfile("${FindConfigurePackage_ZIP_URL}"
                                           "${FindConfigurePackage_WORKING_DIRECTORY}/${DOWNLOAD_FILENAME}")
        endif()

        if(NOT EXISTS ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
          findconfigurepackageunzip("${FindConfigurePackage_WORKING_DIRECTORY}/${DOWNLOAD_FILENAME}"
                                    ${FindConfigurePackage_WORKING_DIRECTORY})
        endif()

        if(EXISTS ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
          set(FindConfigurePackage_UNPACK_SOURCE YES)
        endif()
      endif()

      # git package
      if(NOT FindConfigurePackage_UNPACK_SOURCE AND FindConfigurePackage_GIT_URL)
        get_filename_component(DOWNLOAD_FILENAME "${FindConfigurePackage_GIT_URL}" NAME)
        if(NOT FindConfigurePackage_SRC_DIRECTORY_NAME)
          get_filename_component(FindConfigurePackage_SRC_DIRECTORY_FULL_NAME "${DOWNLOAD_FILENAME}" NAME)
          string(REGEX REPLACE "\\.git$" "" FindConfigurePackage_SRC_DIRECTORY_NAME
                               "${FindConfigurePackage_SRC_DIRECTORY_FULL_NAME}")
        endif()
        set(FindConfigurePackage_DOWNLOAD_SOURCE_DIR
            "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}")
        if(NOT FindConfigurePackage_GIT_FETCH_DEPTH)
          set(FindConfigurePackage_GIT_FETCH_DEPTH ${FindConfigurePackageGitFetchDepth})
        endif()
        set(FindConfigurePackage_GIT_CLONE_ARGS
            URL "${FindConfigurePackage_GIT_URL}" REPO_DIRECTORY "${FindConfigurePackage_DOWNLOAD_SOURCE_DIR}" DEPTH
            ${FindConfigurePackage_GIT_FETCH_DEPTH})
        if(FindConfigurePackage_GIT_BRANCH)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS BRANCH "${FindConfigurePackage_GIT_BRANCH}")
        elseif(FindConfigurePackage_GIT_COMMIT)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS COMMIT "${FindConfigurePackage_GIT_FETCH_DEPTH}")
        endif()
        if(FindConfigurePackage_GIT_ENABLE_SUBMODULE)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS ENABLE_SUBMODULE)
        endif()
        if(FindConfigurePackage_GIT_SUBMODULE_RECURSIVE)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS SUBMODULE_RECURSIVE)
        endif()
        if(FindConfigurePackage_GIT_SUBMODULE_PATHS)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS SUBMODULE_PATH "${FindConfigurePackage_GIT_SUBMODULE_PATHS}")
        endif()
        if(FindConfigurePackage_GIT_RESET_SUBMODULE_URLS)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS RESET_SUBMODULE_URLS
               "${FindConfigurePackage_GIT_RESET_SUBMODULE_URLS}")
        endif()
        if(FindConfigurePackage_GIT_FORCE_RESET)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS FORCE_RESET)
        endif()
        if(FindConfigurePackage_GIT_ALWAYS_UPDATE_REMOTE)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS ALWAYS_UPDATE_REMOTE)
        endif()
        if(FindConfigurePackage_GIT_PATCH_FILES)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS PATCH_FILES "${FindConfigurePackage_GIT_PATCH_FILES}")
        endif()
        if(NOT FindConfigurePackage_GIT_FETCH_FILTER)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS FETCH_FILTER "${FindConfigurePackage_GIT_FETCH_FILTER}")
        endif()
        if(NOT FindConfigurePackage_GIT_SPARSE_CHECKOUT)
          list(APPEND FindConfigurePackage_GIT_CLONE_ARGS SPARSE_CHECKOUT "${FindConfigurePackage_GIT_SPARSE_CHECKOUT}")
        endif()

        project_git_clone_repository(${FindConfigurePackage_GIT_CLONE_ARGS})
        unset(FindConfigurePackage_GIT_CLONE_ARGS)

        if(EXISTS ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
          set(FindConfigurePackage_UNPACK_SOURCE YES)
        endif()
      endif()

      # svn package
      if(NOT FindConfigurePackage_UNPACK_SOURCE AND FindConfigurePackage_SVN_URL)
        get_filename_component(DOWNLOAD_FILENAME "${FindConfigurePackage_SVN_URL}" NAME)
        if(NOT FindConfigurePackage_SRC_DIRECTORY_NAME)
          get_filename_component(FindConfigurePackage_SRC_DIRECTORY_NAME "${DOWNLOAD_FILENAME}" NAME)
        endif()
        set(FindConfigurePackage_DOWNLOAD_SOURCE_DIR
            "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}")
        findconfigurepackageremoveemptydir(${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})

        if(NOT EXISTS ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
          find_package(Subversion)
          if(SUBVERSION_FOUND)
            execute_process(
              COMMAND ${Subversion_SVN_EXECUTABLE} co "${FindConfigurePackage_SVN_URL}"
                      "${FindConfigurePackage_SRC_DIRECTORY_NAME}"
              WORKING_DIRECTORY "${FindConfigurePackage_WORKING_DIRECTORY}"
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
          else()
            message(STATUS "svn not found, skip ${FindConfigurePackage_SVN_URL}")
          endif()
        endif()

        if(EXISTS ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
          set(FindConfigurePackage_UNPACK_SOURCE YES)
        endif()
      endif()

      if(NOT FindConfigurePackage_UNPACK_SOURCE)
        message(FATAL_ERROR "Can not download source for ${FindConfigurePackage_PACKAGE}")
      endif()

      # init build dir
      if(NOT FindConfigurePackage_BUILD_DIRECTORY)
        set(FindConfigurePackage_BUILD_DIRECTORY ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
      endif()
      if(NOT EXISTS ${FindConfigurePackage_BUILD_DIRECTORY})
        file(MAKE_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY})
      endif()

      # prebuild commands
      if(FindConfigurePackage_PREBUILD_COMMAND)
        execute_process(
          COMMAND ${FindConfigurePackage_PREBUILD_COMMAND}
          WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN)
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN
           AND NOT DEFINED
               CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN})
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN
              ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN})
        endif()
      endif()

      # build using configure and make
      if(FindConfigurePackage_BUILD_WITH_CONFIGURE)
        if(FindConfigurePackage_PROJECT_DIRECTORY)
          file(RELATIVE_PATH CONFIGURE_EXEC_FILE ${FindConfigurePackage_BUILD_DIRECTORY}
               "${FindConfigurePackage_PROJECT_DIRECTORY}/configure")
          set(FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN
              "${FindConfigurePackage_PROJECT_DIRECTORY}/load-envs-run.sh")
          project_build_tools_generate_load_env_bash("${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}"
                "export CFLAGS=\"\$CFLAGS -fvisibility=hidden -fvisibility-inlines-hidden\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()
          file(APPEND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}" "\"$@\"")
          if(FindConfigurePackage_AUTOGEN_CONFIGURE)
            execute_process(
              COMMAND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}"
                      ${FindConfigurePackage_AUTOGEN_CONFIGURE}
              WORKING_DIRECTORY "${FindConfigurePackage_PROJECT_DIRECTORY}"
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
          endif()
        else()
          file(RELATIVE_PATH CONFIGURE_EXEC_FILE ${FindConfigurePackage_BUILD_DIRECTORY}
               "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}/configure")
          set(FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN
              "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}/load-envs-run.sh")
          project_build_tools_generate_load_env_bash("${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}"
                "export CFLAGS=\"\$CFLAGS -fvisibility=hidden -fvisibility-inlines-hidden\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()
          file(APPEND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}" "\"$@\"")
          if(FindConfigurePackage_AUTOGEN_CONFIGURE)
            execute_process(
              COMMAND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}"
                      ${FindConfigurePackage_AUTOGEN_CONFIGURE}
              WORKING_DIRECTORY "${FindConfigurePackage_WORKING_DIRECTORY}/${FindConfigurePackage_SRC_DIRECTORY_NAME}"
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
          endif()
        endif()
        if(${CONFIGURE_EXEC_FILE} STREQUAL "configure")
          set(CONFIGURE_EXEC_FILE "./configure")
        endif()
        if(FindConfigurePackage_LIST_SEPARATOR)
          string(REPLACE "${FindConfigurePackage_LIST_SEPARATOR}" "\\;" FindConfigurePackage_CONFIGURE_FLAGS
                         "${FindConfigurePackage_CONFIGURE_FLAGS}")
        endif()
        execute_process(
          COMMAND "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}" "${CONFIGURE_EXEC_FILE}"
                  "--prefix=${FindConfigurePackage_PREFIX_DIRECTORY}" ${FindConfigurePackage_CONFIGURE_FLAGS}
          WORKING_DIRECTORY "${FindConfigurePackage_BUILD_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

        if(FindConfigurePackage_DISABLE_PARALLEL_BUILD)
          unset(FindConfigurePackageCMakeBuildParallelFlags)
        elseif(PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD)
          set(FindConfigurePackageCMakeBuildParallelFlags "-j${PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD}")
        else()
          set(FindConfigurePackageCMakeBuildParallelFlags "-j${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PARALLEL_JOBS}")
        endif()
        project_build_tools_find_make_program(FindConfigurePackage_BUILD_WITH_CONFIGURE_MAKE)
        if(NOT FindConfigurePackage_INSTALL_TARGET)
          set(FindConfigurePackage_INSTALL_TARGET "install")
        endif()
        if(FindConfigurePackage_LIST_SEPARATOR)
          string(REPLACE "${FindConfigurePackage_LIST_SEPARATOR}" "\\;" FindConfigurePackage_MAKE_FLAGS
                         "${FindConfigurePackage_MAKE_FLAGS}")
        endif()
        execute_process(
          COMMAND
            "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}"
            "${FindConfigurePackage_BUILD_WITH_CONFIGURE_MAKE}" "O=\$\$O" ${FindConfigurePackage_MAKE_FLAGS}
            ${FindConfigurePackage_INSTALL_TARGET} ${FindConfigurePackageCMakeBuildParallelFlags}
          WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
          RESULT_VARIABLE RUN_MAKE_RESULT)
        if(NOT RUN_MAKE_RESULT EQUAL 0 AND FindConfigurePackageCMakeBuildParallelFlags)
          execute_process(
            COMMAND
              "${FindConfigurePackage_BUILD_WITH_CONFIGURE_LOAD_ENVS_RUN}"
              "${FindConfigurePackage_BUILD_WITH_CONFIGURE_MAKE}" "O=\$\$O" ${FindConfigurePackage_MAKE_FLAGS}
              ${FindConfigurePackage_INSTALL_TARGET}
            WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
            RESULT_VARIABLE RUN_MAKE_RESULT)
        endif()
        unset(FindConfigurePackage_BUILD_WITH_CONFIGURE_MAKE)
        unset(FindConfigurePackageCMakeBuildParallelFlags)
        unset(RUN_MAKE_RESULT)

        # build using cmake
      elseif(FindConfigurePackage_BUILD_WITH_CMAKE)
        if(FindConfigurePackage_PROJECT_DIRECTORY)
          file(RELATIVE_PATH BUILD_WITH_CMAKE_PROJECT_DIR ${FindConfigurePackage_BUILD_DIRECTORY}
               ${FindConfigurePackage_PROJECT_DIRECTORY})
        else()
          file(RELATIVE_PATH BUILD_WITH_CMAKE_PROJECT_DIR ${FindConfigurePackage_BUILD_DIRECTORY}
               ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
        endif()
        if(NOT BUILD_WITH_CMAKE_PROJECT_DIR)
          set(BUILD_WITH_CMAKE_PROJECT_DIR ".")
        endif()

        set(FindConfigurePackage_BUILD_WITH_CMAKE_GENERATOR
            -Wno-dev "-DCMAKE_INSTALL_PREFIX=${FindConfigurePackage_PREFIX_DIRECTORY}")

        if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV)
          set(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV OFF)
          set(project_build_tools_append_cmake_inherit_options_CALL_VARS
              FindConfigurePackage_BUILD_WITH_CMAKE_GENERATOR)
          if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_C_FLAGS)
          endif()
          if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_CXX_FLAGS)
          endif()
          if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_ASM_FLAGS)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_ASM_FLAGS)
          endif()
          if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_C_STANDARD)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_C_STANDARD)
          endif()
          if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_STANDARD)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_CXX_STANDARD)
          endif()
          # When with CMAKE_INHERIT_FIND_ROOT_PATH, some variables will be append by
          # project_build_tools_append_cmake_options_for_lib() below.
          if(FindConfigurePackage_CMAKE_INHERIT_FIND_ROOT_PATH
             OR FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_CMAKE_FIND_ROOT_FLAGS)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_CMAKE_FIND_ROOT_FLAGS)
          endif()
          if(FindConfigurePackage_CMAKE_INHERIT_BUILD_ENV_DISABLE_CMAKE_TOOLSET_MODULES)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS DISABLE_CMAKE_TOOLSET_MODULES)
          endif()

          if(FindConfigurePackage_CMAKE_INHERIT_SYSTEM_LINKS)
            list(APPEND project_build_tools_append_cmake_inherit_options_CALL_VARS APPEND_SYSTEM_LINKS)
          endif()

          # project_build_tools_append_cmake_inherit_options(
          # ${project_build_tools_append_cmake_inherit_options_CALL_VARS})
          # project_build_tools_append_cmake_cxx_standard_options(
          # ${project_build_tools_append_cmake_inherit_options_CALL_VARS}) Special patchs
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              list(APPEND FindConfigurePackage_BUILD_WITH_CMAKE_GENERATOR "-DCMAKE_C_VISIBILITY_PRESET=hidden"
                   "-DCMAKE_CXX_VISIBILITY_PRESET=hidden" "-DCMAKE_VISIBILITY_INLINES_HIDDEN=ON")
            endif()
          endif()

          project_build_tools_append_cmake_options_for_lib(
            ${project_build_tools_append_cmake_inherit_options_CALL_VARS})
          unset(project_build_tools_append_cmake_inherit_options_CALL_VARS)

        endif()
        if(FindConfigurePackage_CMAKE_INHERIT_FIND_ROOT_PATH)
          project_third_party_append_find_root_args(FindConfigurePackage_BUILD_WITH_CMAKE_GENERATOR)
        endif()

        if(EXISTS "${FindConfigurePackage_BUILD_DIRECTORY}/CMakeCache.txt")
          file(REMOVE "${FindConfigurePackage_BUILD_DIRECTORY}/CMakeCache.txt")
        endif()
        if(FindConfigurePackage_LIST_SEPARATOR)
          string(REPLACE "${FindConfigurePackage_LIST_SEPARATOR}" "\\;" FindConfigurePackage_CMAKE_FLAGS
                         "${FindConfigurePackage_CMAKE_FLAGS}")
        endif()

        execute_process(
          COMMAND "${CMAKE_COMMAND}" "${BUILD_WITH_CMAKE_PROJECT_DIR}"
                  ${FindConfigurePackage_BUILD_WITH_CMAKE_GENERATOR} ${FindConfigurePackage_CMAKE_FLAGS}
          WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        unset(FindConfigurePackage_CMAKE_CONCAT_FLAGS)

        # cmake --build and install
        if(FindConfigurePackage_DISABLE_PARALLEL_BUILD)
          unset(FindConfigurePackageCMakeBuildParallelFlags)
        elseif(PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD)
          set(FindConfigurePackageCMakeBuildParallelFlags "-j${PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD}")
        else()
          set(FindConfigurePackageCMakeBuildParallelFlags "-j${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PARALLEL_JOBS}")
        endif()
        if(FindConfigurePackage_INSTALL_TARGET)
          set(FindConfigurePackage_CMAKE_INSTALL_OPTIONS --build . --target "${FindConfigurePackage_INSTALL_TARGET}"
                                                         ${FindConfigurePackageCMakeBuildParallelFlags})
        else()
          set(FindConfigurePackage_CMAKE_INSTALL_OPTIONS --install . --prefix
                                                         "${FindConfigurePackage_PREFIX_DIRECTORY}")
        endif()
        if(MSVC)
          if(FindConfigurePackage_MSVC_CONFIGURE)
            execute_process(
              COMMAND "${CMAKE_COMMAND}" --build . ${FindConfigurePackageCMakeBuildParallelFlags} --config
                      ${FindConfigurePackage_MSVC_CONFIGURE}
              WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
              RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
            if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0 AND FindConfigurePackageCMakeBuildParallelFlags)
              execute_process(
                COMMAND "${CMAKE_COMMAND}" --build . --config ${FindConfigurePackage_MSVC_CONFIGURE}
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
            endif()
            if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0)
              execute_process(
                COMMAND "${CMAKE_COMMAND}" --build . --verbose --config ${FindConfigurePackage_MSVC_CONFIGURE}
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
            endif()
            if(RUN_CMAKE_BUILD_RESULT EQUAL 0)
              if(NOT FindConfigurePackage_INSTALL_TARGET AND FindConfigurePackage_INSTALL_COMPONENT)
                foreach(_FindConfigurePackage_INSTALL_COMPONENT_ITEM ${FindConfigurePackage_INSTALL_COMPONENT})
                  execute_process(
                    COMMAND
                      "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config
                      ${FindConfigurePackage_MSVC_CONFIGURE} --component
                      "${_FindConfigurePackage_INSTALL_COMPONENT_ITEM}"
                    WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
                endforeach()
              else()
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config
                          ${FindConfigurePackage_MSVC_CONFIGURE}
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
              endif()
            endif()
          else()
            if(FindConfigurePackage_CMAKE_INSTALL_CONFIGURE)
              set(FindConfigurePackageFinalBuildType "${FindConfigurePackage_CMAKE_INSTALL_CONFIGURE}")
            else()
              project_build_tools_get_cmake_build_type_for_lib(FindConfigurePackageFinalBuildType)
            endif()
            if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE AND NOT FindConfigurePackageFinalBuildType STREQUAL
                                                                     "Debug")
              execute_process(
                COMMAND "${CMAKE_COMMAND}" --build . ${FindConfigurePackageCMakeBuildParallelFlags} --config Debug
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
              if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0 AND FindConfigurePackageCMakeBuildParallelFlags)
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" --build . --config Debug
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                  RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
              endif()
              if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0)
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" --build . --verbose --config Debug
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                  RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
              endif()
              if(RUN_CMAKE_BUILD_RESULT EQUAL 0)
                if(NOT FindConfigurePackage_INSTALL_TARGET AND FindConfigurePackage_INSTALL_COMPONENT)
                  foreach(_FindConfigurePackage_INSTALL_COMPONENT_ITEM ${FindConfigurePackage_INSTALL_COMPONENT})
                    execute_process(
                      COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config Debug
                              --component "${_FindConfigurePackage_INSTALL_COMPONENT_ITEM}"
                      WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
                  endforeach()
                else()
                  execute_process(
                    COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config Debug
                    WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
                endif()
              endif()
            endif()
            if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE AND NOT FindConfigurePackageFinalBuildType STREQUAL
                                                                     "Release")
              execute_process(
                COMMAND "${CMAKE_COMMAND}" --build . ${FindConfigurePackageCMakeBuildParallelFlags} --config Release
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
              if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0 AND FindConfigurePackageCMakeBuildParallelFlags)
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" --build . --config Release
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                  RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
              endif()
              if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0)
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" --build . --verbose --config Release
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                  RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
              endif()
              if(RUN_CMAKE_BUILD_RESULT EQUAL 0)
                if(NOT FindConfigurePackage_INSTALL_TARGET AND FindConfigurePackage_INSTALL_COMPONENT)
                  foreach(_FindConfigurePackage_INSTALL_COMPONENT_ITEM ${FindConfigurePackage_INSTALL_COMPONENT})
                    execute_process(
                      COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config Release
                              --component "${_FindConfigurePackage_INSTALL_COMPONENT_ITEM}"
                      WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
                  endforeach()
                else()
                  execute_process(
                    COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config Release
                    WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
                endif()
              endif()
            endif()

            execute_process(
              COMMAND "${CMAKE_COMMAND}" --build . ${FindConfigurePackageCMakeBuildParallelFlags} --config
                      ${FindConfigurePackageFinalBuildType}
              WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
              RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
            if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0 AND FindConfigurePackageCMakeBuildParallelFlags)
              execute_process(
                COMMAND "${CMAKE_COMMAND}" --build . --config ${FindConfigurePackageFinalBuildType}
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
            endif()
            if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0)
              execute_process(
                COMMAND "${CMAKE_COMMAND}" --build . --verbose --config ${FindConfigurePackageFinalBuildType}
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
                RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
            endif()
            if(RUN_CMAKE_BUILD_RESULT EQUAL 0)
              if(NOT FindConfigurePackage_INSTALL_TARGET AND FindConfigurePackage_INSTALL_COMPONENT)
                foreach(_FindConfigurePackage_INSTALL_COMPONENT_ITEM ${FindConfigurePackage_INSTALL_COMPONENT})
                  execute_process(
                    COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config --component
                            "${_FindConfigurePackage_INSTALL_COMPONENT_ITEM}" ${FindConfigurePackageFinalBuildType}
                    WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
                endforeach()
              else()
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --config
                          ${FindConfigurePackageFinalBuildType}
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
              endif()
            endif()
          endif()
        else()
          if(FindConfigurePackage_CMAKE_INSTALL_CONFIGURE)
            set(FindConfigurePackageFinalBuildType "${FindConfigurePackage_CMAKE_INSTALL_CONFIGURE}")
          else()
            project_build_tools_get_cmake_build_type_for_lib(FindConfigurePackageFinalBuildType)
          endif()
          # We can not set --config when do not build specific target, or some cmake versions have BUG and will not
          # install exported target files.
          if(FindConfigurePackageConfigBuildType AND FindConfigurePackage_INSTALL_TARGET)
            set(FindConfigurePackageConfigBuildType --config "${FindConfigurePackageConfigBuildType}")
          else()
            unset(FindConfigurePackageConfigBuildType)
          endif()

          execute_process(
            COMMAND "${CMAKE_COMMAND}" --build . ${FindConfigurePackageConfigBuildType}
                    ${FindConfigurePackageCMakeBuildParallelFlags}
            WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
            RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
          if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0 AND FindConfigurePackageCMakeBuildParallelFlags)
            execute_process(
              COMMAND "${CMAKE_COMMAND}" --build . ${FindConfigurePackageConfigBuildType}
              WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
              RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
          endif()
          if(NOT RUN_CMAKE_BUILD_RESULT EQUAL 0)
            execute_process(
              COMMAND "${CMAKE_COMMAND}" --build . --verbose ${FindConfigurePackageConfigBuildType}
              WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
              RESULT_VARIABLE RUN_CMAKE_BUILD_RESULT)
          endif()
          if(RUN_CMAKE_BUILD_RESULT EQUAL 0)
            if(NOT FindConfigurePackage_INSTALL_TARGET AND FindConfigurePackage_INSTALL_COMPONENT)
              foreach(_FindConfigurePackage_INSTALL_COMPONENT_ITEM ${FindConfigurePackage_INSTALL_COMPONENT})
                execute_process(
                  COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS} --component
                          "${_FindConfigurePackage_INSTALL_COMPONENT_ITEM}" ${FindConfigurePackageConfigBuildType}
                  WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                    ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
              endforeach()
            else()
              execute_process(
                COMMAND "${CMAKE_COMMAND}" ${FindConfigurePackage_CMAKE_INSTALL_OPTIONS}
                        ${FindConfigurePackageConfigBuildType}
                WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
            endif()
          endif()
        endif()
        unset(_FindConfigurePackage_INSTALL_COMPONENT_ITEM)
        unset(FindConfigurePackage_INSTALL_COMPONENT)
        unset(FindConfigurePackage_CMAKE_INSTALL_OPTIONS)
        unset(FindConfigurePackageCMakeBuildParallelFlags)
        unset(RUN_CMAKE_BUILD_RESULT)

        # adaptor for new cmake module
        set("${FindConfigurePackage_PACKAGE}_ROOT" ${FindConfigurePackage_PREFIX_DIRECTORY})

        # build using scons
      elseif(FindConfigurePackage_BUILD_WITH_SCONS)
        if(FindConfigurePackage_PROJECT_DIRECTORY)
          file(RELATIVE_PATH BUILD_WITH_SCONS_PROJECT_DIR ${FindConfigurePackage_BUILD_DIRECTORY}
               ${FindConfigurePackage_PROJECT_DIRECTORY})
        else()
          file(RELATIVE_PATH BUILD_WITH_SCONS_PROJECT_DIR ${FindConfigurePackage_BUILD_DIRECTORY}
               ${FindConfigurePackage_DOWNLOAD_SOURCE_DIR})
        endif()
        if(NOT BUILD_WITH_SCONS_PROJECT_DIR)
          set(BUILD_WITH_SCONS_PROJECT_DIR ".")
        endif()

        set(OLD_ENV_PREFIX $ENV{prefix})
        set(ENV{prefix} ${FindConfigurePackage_PREFIX_DIRECTORY})
        if(FindConfigurePackage_LIST_SEPARATOR)
          string(REPLACE "${FindConfigurePackage_LIST_SEPARATOR}" "\\;" FindConfigurePackage_SCONS_FLAGS
                         "${FindConfigurePackage_SCONS_FLAGS}")
        endif()

        if(CMAKE_HOST_UNIX
           OR MSYS
           OR CYGWIN
           OR NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          set(FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT
              "${FindConfigurePackage_BUILD_DIRECTORY}/scons-build-run.sh")
          project_build_tools_generate_load_env_bash("${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
                "export CFLAGS=\"\$CFLAGS -fvisibility=hidden -fvisibility-inlines-hidden\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()
          file(
            APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
            "export CCFLAGS=\"\$CFLAGS\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export LINK=\"\$LD\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "export LINKFLAGS=\"\$LDFLAGS\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          if(MSVC)
            if(DEFINED CACHE{CMAKE_SYSTEM_VERSION})
              file(APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
                   "export MSVC_SDK_VERSION=\"${CMAKE_SYSTEM_VERSION}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
            endif()
            if(CMAKE_VS_PLATFORM_TOOLSET_VERSION)
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
                "export MSVC_TOOLSET_VERSION=\"$CMAKE_VS_PLATFORM_TOOLSET_VERSION\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()

          project_expand_list_for_command_line_to_file(
            BASH "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}" "scons" ${FindConfigurePackage_SCONS_FLAGS}
            ${BUILD_WITH_SCONS_PROJECT_DIR})
          execute_process(
            COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}" "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
            WORKING_DIRECTORY "${FindConfigurePackage_BUILD_DIRECTORY}"
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        else()
          set(FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT
              "${FindConfigurePackage_BUILD_DIRECTORY}/scons-build-run.ps1")
          project_build_tool_generate_load_env_powershell("${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
                "$ENV:CFLAGS=$ENV:CFLAGS + \" -fvisibility=hidden -fvisibility-inlines-hidden\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()
          file(
            APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
            "$ENV:CCFLAGS=$ENV:CFLAGS${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "$ENV:LINK=$ENV:LD${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
            "$ENV:LINKFLAGS=$ENV:LDFLAGS${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          if(MSVC)
            if(DEFINED CACHE{CMAKE_SYSTEM_VERSION})
              file(APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
                   "$ENV:MSVC_SDK_VERSION=\"${CMAKE_SYSTEM_VERSION}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
            endif()
            if(CMAKE_VS_PLATFORM_TOOLSET_VERSION)
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
                "$ENV:MSVC_TOOLSET_VERSION=\"$CMAKE_VS_PLATFORM_TOOLSET_VERSION\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()

          project_expand_list_for_command_line_to_file(
            PWSH "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}" "scons" ${FindConfigurePackage_SCONS_FLAGS}
            ${BUILD_WITH_SCONS_PROJECT_DIR})
          execute_process(
            COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass
                    -NonInteractive -NoLogo -File "${FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT}"
            WORKING_DIRECTORY "${FindConfigurePackage_BUILD_DIRECTORY}"
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        endif()
        set(ENV{prefix} ${OLD_ENV_PREFIX})
        unset(FindConfigurePackage_BUILD_WITH_SCONS_RUN_SCRIPT)

        # build using custom commands(such as gyp)
      elseif(FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND)
        if(CMAKE_HOST_UNIX
           OR MSYS
           OR CYGWIN
           OR NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          set(FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT
              "${FindConfigurePackage_BUILD_DIRECTORY}/custom-command-build-run.sh")
          project_build_tools_generate_load_env_bash("${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}"
                "export CFLAGS=\"\$CFLAGS -fvisibility=hidden -fvisibility-inlines-hidden\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()

          foreach(cmd ${FindConfigurePackage_CUSTOM_BUILD_COMMAND})
            unset(FindConfigurePackage_CUSTOM_COMMAND_FLAGS)
            if(FindConfigurePackage_LIST_SEPARATOR)
              string(REPLACE "${FindConfigurePackage_LIST_SEPARATOR}" "\\;" FindConfigurePackage_CUSTOM_COMMAND_FLAGS
                             "${cmd}")
            else()
              set(FindConfigurePackage_CUSTOM_COMMAND_FLAGS "${cmd}")
            endif()
            project_expand_list_for_command_line_to_file(
              BASH "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}"
              ${FindConfigurePackage_CUSTOM_COMMAND_FLAGS})
          endforeach()
          execute_process(
            COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}" "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}"
            WORKING_DIRECTORY "${FindConfigurePackage_BUILD_DIRECTORY}"
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        else()
          set(FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT
              "${FindConfigurePackage_BUILD_DIRECTORY}/custom-command-build-run.ps1")
          project_build_tool_generate_load_env_powershell(
            "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${FindConfigurePackage_FULL_PORT_NAME}_VISIBILITY_HIDDEN)
            if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
              file(
                APPEND "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}"
                "$ENV:CFLAGS= $ENV:CFLAGS + \" -fvisibility=hidden -fvisibility-inlines-hidden\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
              )
            endif()
          endif()
          foreach(cmd ${FindConfigurePackage_CUSTOM_BUILD_COMMAND})
            unset(FindConfigurePackage_CUSTOM_COMMAND_FLAGS)
            if(FindConfigurePackage_LIST_SEPARATOR)
              string(REPLACE "${FindConfigurePackage_LIST_SEPARATOR}" "\\;" FindConfigurePackage_CUSTOM_COMMAND_FLAGS
                             "${cmd}")
            else()
              set(FindConfigurePackage_CUSTOM_COMMAND_FLAGS "${cmd}")
            endif()
            project_expand_list_for_command_line_to_file(
              PWSH "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}"
              ${FindConfigurePackage_CUSTOM_COMMAND_FLAGS})
          endforeach()
          execute_process(
            COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass
                    -NonInteractive -NoLogo -File "${FindConfigurePackage_BUILD_WITH_CUSTOM_COMMAND_RUN_SCRIPT}"
            WORKING_DIRECTORY "${FindConfigurePackage_BUILD_DIRECTORY}"
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        endif()
      else()
        message(FATAL_ERROR "Build type is required")
      endif()

      # afterbuild commands
      if(FindConfigurePackage_AFTERBUILD_COMMAND)
        execute_process(
          COMMAND ${FindConfigurePackage_AFTERBUILD_COMMAND}
          WORKING_DIRECTORY ${FindConfigurePackage_BUILD_DIRECTORY}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()

      # reset vars before retry to find package
      foreach(RESET_VAR ${FindConfigurePackage_RESET_FIND_VARS})
        unset(${RESET_VAR} CACHE)
        unset(${RESET_VAR})
      endforeach()
      unset(${FindConfigurePackage_PACKAGE}_FOUND CACHE)
      unset(${FindConfigurePackage_PACKAGE}_FOUND)
      find_package(${FindConfigurePackage_PACKAGE} ${FindConfigurePackage_FIND_PACKAGE_FLAGS})
    endif()
  endif()

  # Cleanup vars
  unset(FindConfigurePackage_INSTALL_TARGET)
  if(DEFINED FindConfigurePackage_BACKUP_CMAKE_FIND_ROOT_PATH)
    set(CMAKE_FIND_ROOT_PATH ${FindConfigurePackage_BACKUP_CMAKE_FIND_ROOT_PATH})
    unset(FindConfigurePackage_BACKUP_CMAKE_FIND_ROOT_PATH)
  endif()
  if(DEFINED FindConfigurePackage_BACKUP_CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH ${FindConfigurePackage_BACKUP_CMAKE_PREFIX_PATH})
    unset(FindConfigurePackage_BACKUP_CMAKE_PREFIX_PATH)
  endif()
endmacro(FindConfigurePackage)

macro(FIND_CONFIGURE_PACKAGE)
  findconfigurepackage(${ARGN})
endmacro(FIND_CONFIGURE_PACKAGE)
