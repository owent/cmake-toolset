# .rst: ProjectBuildTools
# ----------------
#
# build tools
#

include_guard(GLOBAL)

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C
    CMAKE_C_FLAGS
    CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE
    CMAKE_C_FLAGS_RELWITHDEBINFO
    CMAKE_C_FLAGS_MINSIZEREL
    CMAKE_C_COMPILER
    CMAKE_C_COMPILER_TARGET
    CMAKE_C_COMPILER_LAUNCHER
    CMAKE_C_COMPILER_AR
    CMAKE_C_COMPILER_RANLIB
    CMAKE_C_LINK_LIBRARY_SUFFIX
    CMAKE_C_IMPLICIT_LINK_LIBRARIES
    CMAKE_C_STANDARD_INCLUDE_DIRECTORIES
    CMAKE_C_STANDARD_LIBRARIES
    CMAKE_OBJC_EXTENSIONS)

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_CXX_FLAGS_RELWITHDEBINFO
    CMAKE_CXX_FLAGS_MINSIZEREL
    CMAKE_CXX_COMPILER
    CMAKE_CXX_COMPILER_TARGET
    CMAKE_CXX_COMPILER_LAUNCHER
    CMAKE_CXX_COMPILER_AR
    CMAKE_CXX_COMPILER_RANLIB
    CMAKE_CXX_LINK_LIBRARY_SUFFIX
    CMAKE_CXX_IMPLICIT_LINK_LIBRARIES
    ANDROID_CPP_FEATURES
    ANDROID_STL
    CMAKE_ANDROID_STL_TYPE
    CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
    CMAKE_CXX_STANDARD_LIBRARIES
    CMAKE_OBJCXX_EXTENSIONS)

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM
    CMAKE_ASM_FLAGS
    CMAKE_ASM_COMPILER
    CMAKE_ASM_COMPILER_TARGET
    CMAKE_ASM_COMPILER_LAUNCHER
    CMAKE_ASM_COMPILER_AR
    CMAKE_ASM_COMPILER_RANLIB
    CMAKE_ASM_LINK_LIBRARY_SUFFIX)

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON
    CMAKE_EXE_LINKER_FLAGS
    CMAKE_MODULE_LINKER_FLAGS
    CMAKE_SHARED_LINKER_FLAGS
    CMAKE_STATIC_LINKER_FLAGS
    CMAKE_LINK_DIRECTORIES_BEFORE
    CMAKE_INSTALL_RPATH_USE_LINK_PATH
    CMAKE_TOOLCHAIN_FILE
    CMAKE_SYSROOT
    CMAKE_SYSROOT_COMPILE
    CMAKE_SYSROOT_LINK
    CMAKE_SYSTEM_LIBRARY_PATH
    # CMake system
    CMAKE_FIND_USE_CMAKE_SYSTEM_PATH
    CMAKE_FIND_USE_PACKAGE_REGISTRY
    CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY
    CMAKE_FIND_ROOT_PATH_MODE_PROGRAM
    CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
    CMAKE_FIND_ROOT_PATH_MODE_INCLUDE
    CMAKE_FIND_ROOT_PATH_MODE_PACKAGE
    CMAKE_FIND_ROOT_PATH
    # For OSX
    CMAKE_OSX_SYSROOT
    CMAKE_OSX_ARCHITECTURES
    CMAKE_OSX_DEPLOYMENT_TARGET
    CMAKE_MACOSX_RPATH
    # For Android
    ANDROID_TOOLCHAIN
    ANDROID_ABI
    ANDROID_PIE
    ANDROID_PLATFORM
    ANDROID_ALLOW_UNDEFINED_SYMBOLS
    ANDROID_ARM_MODE
    ANDROID_ARM_NEON
    ANDROID_DISABLE_NO_EXECUTE
    ANDROID_DISABLE_RELRO
    ANDROID_DISABLE_FORMAT_STRING_CHECKS
    ANDROID_CCACHE
    ANDROID_NATIVE_API_LEVEL
    ANDROID_TOOLCHAIN
    CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION
    CMAKE_ANDROID_ARCH_ABI
    CMAKE_ANDROID_API
    # For MSVC
    CMAKE_MSVC_RUNTIME_LIBRARY)

if(CMAKE_AR)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_AR)
endif()
if(CMAKE_RANLIB)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_RANLIB)
endif()
if(VCPKG_TOOLCHAIN)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON VCPKG_TOOLCHAIN)
endif()
if(VCPKG_TARGET_TRIPLET)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON VCPKG_TARGET_TRIPLET)
endif()

if(NOT CMAKE_SYSTEM_NAME STREQUAL CMAKE_HOST_SYSTEM_NAME)
  # Set CMAKE_SYSTEM_NAME will cause cmake to set CMAKE_CROSSCOMPILING to TRUE, so we don't set it
  # when not crosscompiling
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_SYSTEM_NAME
       CMAKE_SYSTEM_PROCESSOR CMAKE_SYSTEM_VERSION)
endif()

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS
    ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C}
    ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM})

macro(project_build_tools_append_cmake_inherit_options OUTVAR)
  list(APPEND ${OUTVAR} "-G" "${CMAKE_GENERATOR}")

  set(project_build_tools_append_cmake_inherit_options_DISABLE_C_FLAGS FALSE)
  set(project_build_tools_append_cmake_inherit_options_DISABLE_CXX_FLAGS FALSE)
  set(project_build_tools_append_cmake_inherit_options_DISABLE_ASM_FLAGS FALSE)
  set(project_build_tools_append_cmake_inherit_options_VARS
      PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON)
  foreach(ARG ${ARGN})
    if("${ARG}" STREQUAL "DISABLE_C_FLAGS")
      set(project_build_tools_append_cmake_inherit_options_DISABLE_C_FLAGS TRUE)
    endif()
    if("${ARG}" STREQUAL "DISABLE_CXX_FLAGS")
      set(project_build_tools_append_cmake_inherit_options_DISABLE_CXX_FLAGS TRUE)
    endif()
    if("${ARG}" STREQUAL "DISABLE_ASM_FLAGS")
      set(project_build_tools_append_cmake_inherit_options_DISABLE_ASM_FLAGS TRUE)
    endif()
  endforeach()

  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_C_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS
         PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C)
  endif()
  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_CXX_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS
         PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX)
  endif()
  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_ASM_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS
         PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM)
  endif()

  foreach(VAR_NAME IN LISTS ${project_build_tools_append_cmake_inherit_options_VARS})
    if(DEFINED ${VAR_NAME})
      set(VAR_VALUE "${${VAR_NAME}}")
      # message("DEBUG============ ${VAR_NAME}=${VAR_VALUE}")
      if(VAR_VALUE)
        list_append_unescape(${OUTVAR} "-D${VAR_NAME}=${VAR_VALUE}")
      endif()
    endif()
  endforeach()
  unset(VAR_VALUE)

  if(CMAKE_GENERATOR_PLATFORM)
    list(APPEND ${OUTVAR} "-A" "${CMAKE_GENERATOR_PLATFORM}")
  endif()

  if(CMAKE_GENERATOR_TOOLSET)
    list(APPEND ${OUTVAR} "-T" "${CMAKE_GENERATOR_TOOLSET}")
  endif()

  # This toolset is not used to build app to RUN on GUI, so just set(CMAKE_MACOSX_BUNDLE OFF).
  if(CMAKE_OSX_ARCHITECTURES AND CMAKE_CROSSCOMPILING)
    list(APPEND ${OUTVAR} "-DCMAKE_MACOSX_BUNDLE=OFF")
  endif()

  # Policy
  unset(project_build_tools_append_cmake_inherit_options_POLICY_VALUE)
  cmake_policy(GET CMP0091 project_build_tools_append_cmake_inherit_options_POLICY_VALUE)
  if(project_build_tools_append_cmake_inherit_options_POLICY_VALUE)
    list(
      APPEND
      ${OUTVAR}
      "-DCMAKE_POLICY_DEFAULT_CMP0091=${project_build_tools_append_cmake_inherit_options_POLICY_VALUE}"
    )
  endif()
  unset(project_build_tools_append_cmake_inherit_options_POLICY_VALUE)

  unset(project_build_tools_append_cmake_inherit_options_DISABLE_C_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_DISABLE_CXX_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_DISABLE_ASM_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_VARS)
endmacro()

macro(project_build_tools_append_cmake_build_type_for_lib OUTVAR)
  if(CMAKE_BUILD_TYPE)
    if(MSVC)
      list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=RelWithDebInfo")
    else()
      list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
    endif()
  endif()
endmacro()

macro(project_build_tools_append_cmake_cxx_standard_options)
  unset(project_build_tools_append_cmake_cxx_standard_options_OUTVAR)
  set(project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS FALSE)
  set(project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS FALSE)
  foreach(ARG ${ARGN})
    if(NOT project_build_tools_append_cmake_cxx_standard_options_OUTVAR)
      set(project_build_tools_append_cmake_cxx_standard_options_OUTVAR ${ARG})
    endif()
    if("${ARG}" STREQUAL "DISABLE_C_FLAGS")
      set(project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS TRUE)
    endif()
    if("${ARG}" STREQUAL "DISABLE_CXX_FLAGS")
      set(project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS TRUE)
    endif()
  endforeach()
  if(CMAKE_C_STANDARD AND NOT project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS)
    list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
         "-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}")
  endif()
  if(CMAKE_OBJC_STANDARD AND NOT
                             project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS)
    list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
         "-DCMAKE_OBJC_STANDARD=${CMAKE_OBJC_STANDARD}")
  endif()
  if(CMAKE_CXX_STANDARD AND NOT
                            project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS)
    list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
         "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}")
  endif()
  if(CMAKE_OBJCXX_STANDARD
     AND NOT project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS)
    list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
         "-DCMAKE_OBJCXX_STANDARD=${CMAKE_OBJCXX_STANDARD}")
  endif()

  unset(project_build_tools_append_cmake_cxx_standard_options_OUTVAR)
  unset(project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS)
  unset(project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS)
endmacro()

macro(project_build_tools_append_cmake_options_for_lib OUTVAR)
  project_build_tools_append_cmake_inherit_options(${OUTVAR} ${ARGN})
  project_build_tools_append_cmake_build_type_for_lib(${OUTVAR})
  project_build_tools_append_cmake_cxx_standard_options(${OUTVAR} ${ARGN})
  list(APPEND ${OUTVAR} "-DCMAKE_POLICY_DEFAULT_CMP0075=NEW" "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
endmacro()

function(project_make_executable)
  if(UNIX
     OR MINGW
     OR CYGWIN
     OR APPLE
     OR CMAKE_HOST_APPLE
     OR CMAKE_HOST_UNIX)
    foreach(ARG ${ARGN})
      execute_process(COMMAND chmod -R +x ${ARG})
    endforeach()
  endif()
endfunction()

function(project_make_writable)
  if(CMAKE_HOST_APPLE
     OR APPLE
     OR UNIX
     OR MINGW
     OR MSYS
     OR CYGWIN)
    execute_process(COMMAND chmod -R +w ${ARGN})
  else()
    foreach(arg ${ARGN})
      execute_process(COMMAND attrib -R "${arg}" /S /D /L)
    endforeach()
  endif()
endfunction()

# 如果仅仅是设置环境变量的话可以用 ${CMAKE_COMMAND} -E env M4=/foo/bar 代替
macro(project_expand_list_for_command_line OUTPUT INPUT)
  set(project_expand_list_for_command_line_ENABLE_CONVERT ON)
  foreach(ARG IN LISTS ${INPUT})
    if(ARG STREQUAL "DISABLE_CONVERT")
      set(project_expand_list_for_command_line_ENABLE_CONVERT OFF)
    elseif(ARG STREQUAL "ENABLE_CONVERT")
      set(project_expand_list_for_command_line_ENABLE_CONVERT ON)
    else()
      if(project_expand_list_for_command_line_ENABLE_CONVERT)
        string(REPLACE "\\" "\\\\" project_expand_list_for_command_line_OUT_VAR "${ARG}")
        string(REPLACE "\"" "\\\"" project_expand_list_for_command_line_OUT_VAR
                       "${project_expand_list_for_command_line_OUT_VAR}")
      else()
        set(project_expand_list_for_command_line_OUT_VAR "${ARG}")
      endif()
      set(${OUTPUT} "${${OUTPUT}} \"${project_expand_list_for_command_line_OUT_VAR}\"")
      unset(project_expand_list_for_command_line_OUT_VAR)
    endif()
  endforeach()
  unset(project_expand_list_for_command_line_ENABLE_CONVERT)
endmacro()

function(project_expand_list_for_command_line_to_file)
  unset(project_expand_list_for_command_line_to_file_OUTPUT)
  unset(project_expand_list_for_command_line_to_file_LINE)
  set(project_expand_list_for_command_line_to_file_ENABLE_CONVERT ON)
  foreach(ARG ${ARGN})
    if(ARG STREQUAL "DISABLE_CONVERT")
      set(project_expand_list_for_command_line_to_file_ENABLE_CONVERT OFF)
    elseif(ARG STREQUAL "ENABLE_CONVERT")
      set(project_expand_list_for_command_line_to_file_ENABLE_CONVERT ON)
    elseif(NOT project_expand_list_for_command_line_to_file_OUTPUT)
      set(project_expand_list_for_command_line_to_file_OUTPUT "${ARG}")
    else()
      if(project_expand_list_for_command_line_to_file_ENABLE_CONVERT)
        string(REPLACE "\\" "\\\\" project_expand_list_for_command_line_OUT_VAR "${ARG}")
        string(REPLACE "\"" "\\\"" project_expand_list_for_command_line_OUT_VAR
                       "${project_expand_list_for_command_line_OUT_VAR}")
      else()
        set(project_expand_list_for_command_line_OUT_VAR "${ARG}")
      endif()
      if(project_expand_list_for_command_line_to_file_LINE)
        set(project_expand_list_for_command_line_to_file_LINE
            "${project_expand_list_for_command_line_to_file_LINE} \"${project_expand_list_for_command_line_OUT_VAR}\""
        )
      else()
        set(project_expand_list_for_command_line_to_file_LINE
            "\"${project_expand_list_for_command_line_OUT_VAR}\"")
      endif()
      unset(project_expand_list_for_command_line_OUT_VAR)
    endif()
  endforeach()

  if(project_expand_list_for_command_line_to_file_OUTPUT)
    file(
      APPEND "${project_expand_list_for_command_line_to_file_OUTPUT}"
      "${project_expand_list_for_command_line_to_file_LINE}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()
  unset(project_expand_list_for_command_line_to_file_OUTPUT)
  unset(project_expand_list_for_command_line_to_file_LINE)
  unset(project_expand_list_for_command_line_to_file_ENABLE_CONVERT)
endfunction()

if(CMAKE_HOST_WIN32)
  set(PROJECT_THIRD_PARTY_BUILDTOOLS_EOL "\r\n")
  set(PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL "\n")
elseif(CMAKE_HOST_APPLE OR APPLE)
  set(PROJECT_THIRD_PARTY_BUILDTOOLS_EOL "\r")
  set(PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL "\n")
else()
  set(PROJECT_THIRD_PARTY_BUILDTOOLS_EOL "\n")
  set(PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL "\n")
endif()

function(project_git_clone_repository)
  if(CMAKE_VERSION VERSION_LESS_EQUAL "3.4")
    include(CMakeParseArguments)
  endif()
  set(optionArgs ENABLE_SUBMODULE SUBMODULE_RECURSIVE REQUIRED FORCE_RESET)
  set(oneValueArgs
      URL
      WORKING_DIRECTORY
      REPO_DIRECTORY
      DEPTH
      BRANCH
      COMMIT
      TAG
      CHECK_PATH)
  set(multiValueArgs PATCH_FILES SUBMODULE_PATH)
  cmake_parse_arguments(project_git_clone_repository "${optionArgs}" "${oneValueArgs}"
                        "${multiValueArgs}" ${ARGN})

  if(NOT project_git_clone_repository_URL)
    message(FATAL_ERROR "URL is required")
  endif()
  if(NOT project_git_clone_repository_REPO_DIRECTORY)
    message(FATAL_ERROR "REPO_DIRECTORY is required")
  endif()
  if(NOT project_git_clone_repository_WORKING_DIRECTORY)
    get_filename_component(project_git_clone_repository_WORKING_DIRECTORY
                           ${project_git_clone_repository_REPO_DIRECTORY} DIRECTORY)
  endif()
  if(NOT project_git_clone_repository_CHECK_PATH)
    set(project_git_clone_repository_CHECK_PATH ".git")
  endif()

  if(NOT project_git_clone_repository_DEPTH)
    set(project_git_clone_repository_DEPTH 100)
  endif()

  unset(project_git_clone_repository_GIT_BRANCH)

  if(project_git_clone_repository_TAG)
    set(project_git_clone_repository_GIT_BRANCH ${project_git_clone_repository_TAG})
  elseif(project_git_clone_repository_BRANCH)
    set(project_git_clone_repository_GIT_BRANCH ${project_git_clone_repository_BRANCH})
  endif()

  find_package(Git)
  if(NOT GIT_FOUND AND NOT Git_FOUND)
    message(FATAL_ERROR "git not found")
  endif()

  unset(project_git_clone_repository_EXECUTE_PROCESS_FLAGS)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
    list(APPEND project_git_clone_repository_EXECUTE_PROCESS_FLAGS COMMAND_ECHO STDOUT)
  endif()
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.18")
    list(APPEND project_git_clone_repository_EXECUTE_PROCESS_FLAGS ECHO_OUTPUT_VARIABLE
         ECHO_ERROR_VARIABLE)
  endif()

  if(project_git_clone_repository_FORCE_RESET AND EXISTS
                                                  ${project_git_clone_repository_REPO_DIRECTORY})
    execute_process(
      COMMAND ${GIT_EXECUTABLE} clean -dfx
      COMMAND ${GIT_EXECUTABLE} reset --hard
      WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
      RESULT_VARIABLE LAST_GIT_RESET_RESULT ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})

    if(LAST_GIT_RESET_RESULT AND NOT LAST_GIT_RESET_RESULT EQUAL 0)
      file(REMOVE_RECURSE ${project_git_clone_repository_REPO_DIRECTORY})
    elseif(project_git_clone_repository_ENABLE_SUBMODULE)
      if(project_git_clone_repository_SUBMODULE_RECURSIVE)
        execute_process(
          COMMAND ${GIT_EXECUTABLE} submodule foreach --recursive "git clean -dfx"
          COMMAND ${GIT_EXECUTABLE} submodule foreach --recursive "git reset --hard"
          WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY})
      else()
        execute_process(
          COMMAND ${GIT_EXECUTABLE} submodule foreach "git clean -dfx"
          COMMAND ${GIT_EXECUTABLE} submodule foreach "git reset --hard"
          WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY})
      endif()
      if(project_git_clone_repository_PATCH_FILES)
        execute_process(
          COMMAND ${GIT_EXECUTABLE} config "core.autocrlf" "true"
          COMMAND ${GIT_EXECUTABLE} apply ${project_git_clone_repository_PATCH_FILES}
          WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                            ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
      endif()
    endif()
  endif()

  # Check and cleanup directory if fetch failed before
  if(EXISTS "${project_git_clone_repository_REPO_DIRECTORY}/.git")
    execute_process(
      COMMAND ${GIT_EXECUTABLE} log -n 1 --oneline
      WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
      RESULT_VARIABLE project_git_clone_repository_GIT_CHECK_REPO
      OUTPUT_QUIET ERROR_QUIET)
    if(NOT project_git_clone_repository_GIT_CHECK_REPO EQUAL 0)
      message(
        STATUS
          "${project_git_clone_repository_REPO_DIRECTORY} is not a valid git repository, remove it..."
      )
      file(REMOVE_RECURSE ${project_git_clone_repository_REPO_DIRECTORY})
    endif()
    unset(project_git_clone_repository_GIT_CHECK_REPO)
  endif()

  if(NOT EXISTS
     "${project_git_clone_repository_REPO_DIRECTORY}/${project_git_clone_repository_CHECK_PATH}")
    if(EXISTS ${project_git_clone_repository_REPO_DIRECTORY})
      file(REMOVE_RECURSE ${project_git_clone_repository_REPO_DIRECTORY})
    endif()
  endif()

  if(NOT EXISTS
     "${project_git_clone_repository_REPO_DIRECTORY}/${project_git_clone_repository_CHECK_PATH}")
    if(NOT EXISTS ${project_git_clone_repository_REPO_DIRECTORY})
      file(MAKE_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY})
    endif()

    if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.28.0")
      execute_process(
        COMMAND ${GIT_EXECUTABLE} init -b main
        WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                          ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
    else()
      execute_process(
        COMMAND ${GIT_EXECUTABLE} init
        WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                          ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
    endif()
    execute_process(
      COMMAND ${GIT_EXECUTABLE} remote add origin "${project_git_clone_repository_URL}"
      WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                        ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})

    if(NOT project_git_clone_repository_GIT_BRANCH AND NOT project_git_clone_repository_COMMIT)
      unset(project_git_clone_repository_GIT_CHECK_REPO)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} ls-remote --symref origin HEAD
        RESULT_VARIABLE project_git_clone_repository_GIT_LS_REMOTE_RESULT
        WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
        OUTPUT_VARIABLE project_git_clone_repository_GIT_CHECK_REPO
                        ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
      if(project_git_clone_repository_GIT_CHECK_REPO
         AND project_git_clone_repository_GIT_CHECK_REPO MATCHES
             "ref.*refs/heads/([^ \t]*)[ \t]*HEAD.*")
        set(project_git_clone_repository_GIT_BRANCH "${CMAKE_MATCH_1}")
      else()
        execute_process(
          COMMAND ${GIT_EXECUTABLE} ls-remote origin HEAD
          RESULT_VARIABLE project_git_clone_repository_GIT_LS_REMOTE_RESULT
          WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
          OUTPUT_VARIABLE project_git_clone_repository_GIT_CHECK_REPO
                          ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
        if(project_git_clone_repository_GIT_CHECK_REPO MATCHES "^([a-zA-Z0-9]*)[ \t]*HEAD.*")
          set(project_git_clone_repository_COMMIT "${CMAKE_MATCH_1}")
        endif()
      endif()
      if(NOT project_git_clone_repository_GIT_BRANCH AND NOT project_git_clone_repository_COMMIT)
        if(NOT project_git_clone_repository_GIT_LS_REMOTE_RESULT EQUAL 0
           AND project_git_clone_repository_REQUIRED)
          message(
            FATAL_ERROR
              "git ls-remote --symref origin(${project_git_clone_repository_URL}) HEAD failed")
        endif()
        # Fallback
        set(project_git_clone_repository_GIT_BRANCH main)
      endif()
      unset(project_git_clone_repository_GIT_CHECK_REPO)
      unset(project_git_clone_repository_GIT_LS_REMOTE_RESULT)
    endif()

    if(project_git_clone_repository_GIT_BRANCH)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} fetch "--depth=${project_git_clone_repository_DEPTH}" "-n" origin
                ${project_git_clone_repository_GIT_BRANCH}
        RESULT_VARIABLE project_git_clone_repository_GIT_FETCH_RESULT
        WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                          ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
      if(NOT project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0
         AND project_git_clone_repository_REQUIRED)
        message(
          FATAL_ERROR
            "git fetch origin(${project_git_clone_repository_URL}) ${project_git_clone_repository_GIT_BRANCH} failed"
        )
      endif()
    else()
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.11.0")
        execute_process(
          COMMAND ${GIT_EXECUTABLE} fetch "--deepen=${project_git_clone_repository_DEPTH}" "-n"
                  origin ${project_git_clone_repository_COMMIT}
          RESULT_VARIABLE project_git_clone_repository_GIT_FETCH_RESULT
          WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                            ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
      else()
        message(
          WARNING "It's recommended to use git 2.11.0 or upper to only fetch partly of repository.")
        execute_process(
          COMMAND ${GIT_EXECUTABLE} fetch "-n" origin ${project_git_clone_repository_COMMIT}
          RESULT_VARIABLE project_git_clone_repository_GIT_FETCH_RESULT
          WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                            ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
      endif()
      if(NOT project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0
         AND project_git_clone_repository_REQUIRED)
        message(
          FATAL_ERROR
            "git fetch origin(${project_git_clone_repository_URL}) ${project_git_clone_repository_GIT_BRANCH} failed"
        )
      endif()
    endif()
    unset(project_git_clone_repository_GIT_FETCH_RESULT)
    execute_process(
      COMMAND ${GIT_EXECUTABLE} reset --hard FETCH_HEAD
      WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                        ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
    if(project_git_clone_repository_ENABLE_SUBMODULE)
      set(project_git_clone_repository_submodule_args update --init -f)
      if(project_git_clone_repository_SUBMODULE_RECURSIVE)
        list(APPEND project_git_clone_repository_submodule_args "--recursive")
      endif()
      if(project_git_clone_repository_SUBMODULE_PATH)
        list(APPEND project_git_clone_repository_submodule_args "--"
             ${project_git_clone_repository_SUBMODULE_PATH})
      endif()

      execute_process(
        COMMAND ${GIT_EXECUTABLE} ${project_git_clone_repository_submodule_args}
        WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                          ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
    endif()

    if(project_git_clone_repository_PATCH_FILES)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} config "core.autocrlf" "true"
        COMMAND ${GIT_EXECUTABLE} apply ${project_git_clone_repository_PATCH_FILES}
        WORKING_DIRECTORY ${project_git_clone_repository_REPO_DIRECTORY}
                          ${project_git_clone_repository_EXECUTE_PROCESS_FLAGS})
    endif()
  endif()
endfunction()

if(NOT PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS_SET)
  if(MSVC)
    unset(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS CACHE)
    set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd4244 /wd4251 /wd4267 /wd4309)

    if(MSVC_VERSION GREATER_EQUAL 1922)
      # see
      # https://docs.microsoft.com/en-us/cpp/overview/cpp-conformance-improvements?view=vs-2019#improvements_162
      # for detail
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd5054)
    endif()

    if(MSVC_VERSION GREATER_EQUAL 1925)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd4996)
    endif()

    if(MSVC_VERSION LESS 1910)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd4800)
    endif()
  else()
    unset(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS CACHE)
    set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-type-limits)
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag(-Wno-unused-parameter
                            project_build_tools_patch_protobuf_sources_LINT_NO_UNUSED_PARAMETER)
    if(project_build_tools_patch_protobuf_sources_LINT_NO_UNUSED_PARAMETER)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-unused-parameter)
    endif()
    check_cxx_compiler_flag(
      -Wno-deprecated-declarations
      project_build_tools_patch_protobuf_sources_LINT_NO_DEPRECATED_DECLARATIONS)
    if(project_build_tools_patch_protobuf_sources_LINT_NO_DEPRECATED_DECLARATIONS)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-deprecated-declarations)
    endif()

  endif()
  set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS_SET TRUE)
  set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS
      ${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS}
      CACHE INTERNAL "Options to disable warning of generated protobuf sources" FORCE)
endif()

function(project_build_tools_patch_protobuf_sources)
  if(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS)
    foreach(PROTO_SRC ${ARGN})
      unset(PROTO_SRC_OPTIONS)
      get_source_file_property(PROTO_SRC_OPTIONS ${PROTO_SRC} COMPILE_OPTIONS)
      if(PROTO_SRC_OPTIONS)
        list(APPEND PROTO_SRC_OPTIONS ${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS})
      else()
        set(PROTO_SRC_OPTIONS ${PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS})
      endif()

      set_source_files_properties(${PROTO_SRC} PROPERTIES COMPILE_OPTIONS "${PROTO_SRC_OPTIONS}")
    endforeach()
    unset(PROTO_SRC)
    unset(PROTO_SRC_OPTIONS)
  endif()
endfunction()

function(project_build_tools_patch_imported_link_interface_libraries TARGET_NAME)
  if(CMAKE_VERSION VERSION_LESS_EQUAL "3.4")
    include(CMakeParseArguments)
  endif()
  set(multiValueArgs ADD_LIBRARIES REMOVE_LIBRARIES)
  cmake_parse_arguments(PATCH_OPTIONS "" "" "${multiValueArgs}" ${ARGN})

  get_target_property(OLD_LINK_LIBRARIES ${TARGET_NAME} INTERFACE_LINK_LIBRARIES)
  set(PROPERTY_NAME "")
  if(OLD_LINK_LIBRARIES)
    set(PROPERTY_NAME "INTERFACE_LINK_LIBRARIES")
  endif()
  if(NOT PROPERTY_NAME)
    get_target_property(OLD_LINK_LIBRARIES ${TARGET_NAME} IMPORTED_LINK_INTERFACE_LIBRARIES)
    if(OLD_LINK_LIBRARIES)
      set(PROPERTY_NAME "IMPORTED_LINK_INTERFACE_LIBRARIES")
    endif()
  endif()
  if(NOT PROPERTY_NAME)
    get_target_property(OLD_IMPORTED_CONFIGURATIONS ${TARGET_NAME} IMPORTED_CONFIGURATIONS)
    get_target_property(OLD_LINK_LIBRARIES ${TARGET_NAME}
                        "IMPORTED_LINK_INTERFACE_LIBRARIES_${OLD_IMPORTED_CONFIGURATIONS}")
    if(OLD_LINK_LIBRARIES)
      set(PROPERTY_NAME "IMPORTED_LINK_INTERFACE_LIBRARIES_${OLD_IMPORTED_CONFIGURATIONS}")
    endif()
  endif()
  if(NOT PROPERTY_NAME)
    set(PROPERTY_NAME "INTERFACE_LINK_LIBRARIES")
  endif()

  if(NOT OLD_LINK_LIBRARIES)
    set(OLD_LINK_LIBRARIES "") # Reset NOTFOUND
  endif()
  unset(PATCH_INNER_LIBS)
  if(OLD_LINK_LIBRARIES AND PATCH_OPTIONS_REMOVE_LIBRARIES)
    foreach(DEP_PATH IN LISTS OLD_LINK_LIBRARIES)
      set(MATCH_ANY_RULES FALSE)
      foreach(MATCH_RULE IN LISTS PATCH_OPTIONS_REMOVE_LIBRARIES)
        if(DEP_PATH MATCHES ${MATCH_RULE})
          set(MATCH_ANY_RULES TRUE)
          break()
        endif()
      endforeach()

      if(NOT MATCH_ANY_RULES)
        list(APPEND PATCH_INNER_LIBS ${DEP_PATH})
      endif()
    endforeach()
    if(PATCH_OPTIONS_ADD_LIBRARIES)
      list(APPEND PATCH_INNER_LIBS ${PATCH_OPTIONS_ADD_LIBRARIES})
    endif()
  elseif(OLD_LINK_LIBRARIES)
    set(PATCH_INNER_LIBS ${OLD_LINK_LIBRARIES})
    if(PATCH_OPTIONS_ADD_LIBRARIES)
      list(APPEND PATCH_INNER_LIBS ${PATCH_OPTIONS_ADD_LIBRARIES})
    endif()
  elseif(PATCH_OPTIONS_ADD_LIBRARIES)
    set(PATCH_INNER_LIBS ${PATCH_OPTIONS_ADD_LIBRARIES})
  else()
    set(PATCH_INNER_LIBS "")
  endif()

  if(PATCH_INNER_LIBS)
    list(REMOVE_DUPLICATES PATCH_INNER_LIBS)
  endif()

  if(NOT OLD_LINK_LIBRARIES STREQUAL PATCH_INNER_LIBS)
    set_target_properties(${TARGET_NAME} PROPERTIES ${PROPERTY_NAME} "${PATCH_INNER_LIBS}")
    message(
      STATUS
        "Patch: ${PROPERTY_NAME} of ${TARGET_NAME} from \"${OLD_LINK_LIBRARIES}\" to \"${PATCH_INNER_LIBS}\""
    )
  endif()
endfunction()

macro(project_build_tools_get_imported_location OUTPUT_VAR_NAME TARGET_NAME)
  get_target_property(${OUTPUT_VAR_NAME} ${TARGET_NAME} IMPORTED_LOCATION)
  if(NOT ${OUTPUT_VAR_NAME})
    unset(project_build_tools_get_imported_location_IMPORTED_CONFIGURATIONS)
    get_target_property(project_build_tools_get_imported_location_IMPORTED_CONFIGURATIONS
                        ${TARGET_NAME} IMPORTED_CONFIGURATIONS)
    foreach(project_build_tools_get_imported_location_IMPORTED_CONFIGURATION IN
            LISTS project_build_tools_get_imported_location_IMPORTED_CONFIGURATIONS)
      get_target_property(
        ${OUTPUT_VAR_NAME} ${TARGET_NAME}
        "IMPORTED_LOCATION_${project_build_tools_get_imported_location_IMPORTED_CONFIGURATION}")
      if(${OUTPUT_VAR_NAME})
        break()
      endif()
    endforeach()
    unset(project_build_tools_get_imported_location_IMPORTED_CONFIGURATIONS)
    unset(project_build_tools_get_imported_location_IMPORTED_CONFIGURATION)
  endif()
endmacro()

function(project_build_tools_patch_default_imported_config)
  set(PATCH_VARS
      IMPORTED_IMPLIB
      IMPORTED_LIBNAME
      IMPORTED_LINK_DEPENDENT_LIBRARIES
      IMPORTED_LINK_INTERFACE_LANGUAGES
      IMPORTED_LINK_INTERFACE_LIBRARIES
      IMPORTED_LINK_INTERFACE_MULTIPLICITY
      IMPORTED_LOCATION
      IMPORTED_NO_SONAME
      IMPORTED_OBJECTS
      IMPORTED_SONAME)
  foreach(TARGET_NAME ${ARGN})
    if(TARGET ${TARGET_NAME})
      get_target_property(DO_NOT_OVERWRITE ${TARGET_NAME} IMPORTED_LOCATION)
      if(DO_NOT_OVERWRITE)
        continue()
      endif()

      # MSVC's STL and debug level must match the target, so we can only move out
      # IMPORTED_LOCATION_NOCONFIG
      if(MSVC)
        set(PATCH_IMPORTED_CONFIGURATION "NOCONFIG")
      else()
        get_target_property(PATCH_IMPORTED_CONFIGURATION ${TARGET_NAME} IMPORTED_CONFIGURATIONS)
      endif()

      get_target_property(PATCH_TARGET_LOCATION ${TARGET_NAME}
                          "IMPORTED_LOCATION_${PATCH_IMPORTED_CONFIGURATION}")
      if(NOT PATCH_TARGET_LOCATION)
        continue()
      endif()

      foreach(PATCH_IMPORTED_KEY IN LISTS PATCH_VARS)
        get_target_property(PATCH_IMPORTED_VALUE ${TARGET_NAME}
                            "${PATCH_IMPORTED_KEY}_${PATCH_IMPORTED_CONFIGURATION}")
        if(PATCH_IMPORTED_VALUE)
          set_target_properties(${TARGET_NAME} PROPERTIES "${PATCH_IMPORTED_KEY}"
                                                          "${PATCH_IMPORTED_VALUE}")
        endif()
      endforeach()
    endif()
  endforeach()
endfunction()

function(project_build_tools_generate_load_env_bash OUTPUT_FILE)
  file(WRITE "${OUTPUT_FILE}" "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  project_make_executable("${OUTPUT_FILE}")

  file(APPEND "${OUTPUT_FILE}"
       "export CC=\"${CMAKE_C_COMPILER}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  file(APPEND "${OUTPUT_FILE}"
       "export CXX=\"${CMAKE_CXX_COMPILER}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  if(CMAKE_AR)
    file(APPEND "${OUTPUT_FILE}"
         "export AR=\"${CMAKE_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  unset(FINAL_CFLAGS)
  unset(FINAL_CXXFLAGS)
  add_compiler_flags_to_var(FINAL_CFLAGS ${CMAKE_C_FLAGS})
  add_compiler_flags_to_var(FINAL_CXXFLAGS ${CMAKE_CXX_FLAGS})
  if(CMAKE_OSX_ARCHITECTURES)
    if(CMAKE_OSX_SYSROOT)
      add_compiler_flags_to_var(FINAL_CFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
    endif()

    if(CMAKE_OSX_DEPLOYMENT_TARGET)
      add_compiler_flags_to_var(FINAL_CFLAGS
                                "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS
                                "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()

    add_compiler_flags_to_var(FINAL_CFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
    add_compiler_flags_to_var(FINAL_CXXFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
  endif()

  if(FINAL_CFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "export CFLAGS=\"${FINAL_CFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CFLAGS)

  if(FINAL_CXXFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "export CXXFLAGS=\"${FINAL_CXXFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CXXFLAGS)

  if(ENV{LD})
    file(APPEND "${OUTPUT_FILE}" "export LD=\"$ENV{LD}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{AS})
    file(APPEND "${OUTPUT_FILE}" "export AS=\"$ENV{AS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{STRIP})
    file(APPEND "${OUTPUT_FILE}"
         "export STRIP=\"$ENV{STRIP}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{NM})
    file(APPEND "${OUTPUT_FILE}" "export NM=\"$ENV{NM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  if(CMAKE_ASM_FLAGS OR CMAKE_ASM_FLAGS_RELEASE)
    file(
      APPEND "${OUTPUT_FILE}"
      "export ASFLAGS=\"${CMAKE_ASM_FLAGS} ${CMAKE_ASM_FLAGS_RELEASE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()

  if(CMAKE_EXE_LINKER_FLAGS OR CMAKE_STATIC_LINKER_FLAGS)
    file(
      APPEND "${OUTPUT_FILE}"
      "export LDFLAGS=\"${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()

  if(CMAKE_RANLIB)
    file(APPEND "${OUTPUT_FILE}"
         "export RANLIB=\"${CMAKE_RANLIB}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_OSX_SYSROOT)
    file(APPEND "${OUTPUT_FILE}"
         "export OSX_SYSROOT=\"${CMAKE_OSX_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_OSX_ARCHITECTURES)
    file(
      APPEND "${OUTPUT_FILE}"
      "export OSX_ARCHITECTURES=\"${CMAKE_OSX_ARCHITECTURES}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()
  if(ANDROID)
    file(
      APPEND "${OUTPUT_FILE}"
      "export ANDROID_NDK=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_NDK_HOME=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_NDK_ROOT=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_NDK_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_SYSTEM_LIBRARY_PATH=\"${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_NATIVE_API_LEVEL=\"${ANDROID_PLATFORM_LEVEL}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_PLATFORM_LEVEL=\"${ANDROID_PLATFORM_LEVEL}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_ABI=\"${ANDROID_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_SYSROOT_ABI=\"${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_TOOLCHAIN_NAME=\"${ANDROID_TOOLCHAIN_NAME}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_TOOLCHAIN_ROOT=\"${ANDROID_TOOLCHAIN_ROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_TOOLCHAIN_PREFIX=\"${ANDROID_TOOLCHAIN_PREFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_TOOLCHAIN_SUFFIX=\"${ANDROID_TOOLCHAIN_SUFFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export PATH=\"${ANDROID_TOOLCHAIN_ROOT}/bin:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()
endfunction()

function(project_build_tool_generate_load_env_powershell OUTPUT_FILE)
  file(WRITE "${OUTPUT_FILE}" "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  project_make_executable("${OUTPUT_FILE}")

  file(
    APPEND "${OUTPUT_FILE}"
    "$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  file(
    APPEND "${OUTPUT_FILE}"
    "$OutputEncoding = [System.Text.UTF8Encoding]::new()${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  if(CMAKE_AR)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:AR=\"${CMAKE_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  unset(FINAL_CFLAGS)
  unset(FINAL_CXXFLAGS)
  add_compiler_flags_to_var(FINAL_CFLAGS ${CMAKE_C_FLAGS})
  add_compiler_flags_to_var(FINAL_CXXFLAGS ${CMAKE_CXX_FLAGS})
  if(ANDROID)
    if(ANDROID_PLATFORM_LEVEL)
      add_compiler_flags_to_var(FINAL_CFLAGS "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}")
    endif()
  else()
    if(CMAKE_OSX_SYSROOT)
      add_compiler_flags_to_var(FINAL_CFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
    endif()

    if(CMAKE_OSX_DEPLOYMENT_TARGET)
      add_compiler_flags_to_var(FINAL_CFLAGS
                                "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS
                                "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()

    if(CMAKE_OSX_ARCHITECTURES)
      add_compiler_flags_to_var(FINAL_CFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
    endif()
  endif()

  if(FINAL_CFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:CFLAGS=\"${FINAL_CFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CFLAGS)

  if(FINAL_CXXFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:CXXFLAGS=\"${FINAL_CXXFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CXXFLAGS)

  if(ENV{LD})
    file(APPEND "${OUTPUT_FILE}" "$ENV:LD=\"$ENV{LD}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{AS})
    file(APPEND "${OUTPUT_FILE}" "$ENV:AS=\"$ENV{AS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{STRIP})
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:STRIP=\"$ENV{STRIP}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{NM})
    file(APPEND "${OUTPUT_FILE}" "$ENV:NM=\"$ENV{NM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  if(CMAKE_ASM_FLAGS OR CMAKE_ASM_FLAGS_RELEASE)
    file(
      APPEND "${OUTPUT_FILE}"
      "$ENV:ASFLAGS=\"${CMAKE_ASM_FLAGS} ${CMAKE_ASM_FLAGS_RELEASE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()

  if(CMAKE_EXE_LINKER_FLAGS OR CMAKE_STATIC_LINKER_FLAGS)
    file(
      APPEND "${OUTPUT_FILE}"
      "$ENV:LDFLAGS=\"${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_STATIC_LINKER_FLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()

  if(CMAKE_RANLIB)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:RANLIB=\"${CMAKE_RANLIB}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_OSX_SYSROOT)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:OSX_SYSROOT=\"${CMAKE_OSX_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_OSX_ARCHITECTURES)
    file(
      APPEND "${OUTPUT_FILE}"
      "$ENV:OSX_ARCHITECTURES=\"${CMAKE_OSX_ARCHITECTURES}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()
  if(ANDROID)
    file(
      APPEND "${OUTPUT_FILE}"
      "$ENV:ANDROID_NDK=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_NDK_HOME=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_NDK_ROOT=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_NDK_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_SYSTEM_LIBRARY_PATH=\"${ANDROID_NDK}/platforms/${ANDROID_PLATFORM}/arch-${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_NATIVE_API_LEVEL=\"${ANDROID_PLATFORM_LEVEL}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_PLATFORM_LEVEL=\"${ANDROID_PLATFORM_LEVEL}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_ABI=\"${ANDROID_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_SYSROOT_ABI=\"${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_TOOLCHAIN_NAME=\"${ANDROID_TOOLCHAIN_NAME}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_TOOLCHAIN_ROOT=\"${ANDROID_TOOLCHAIN_ROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_TOOLCHAIN_PREFIX=\"${ANDROID_TOOLCHAIN_PREFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_TOOLCHAIN_SUFFIX=\"${ANDROID_TOOLCHAIN_SUFFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:PATH=\"${ANDROID_TOOLCHAIN_ROOT}/bin\" + [IO.Path]::PathSeparator + \"\$ENV:PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()
endfunction()
