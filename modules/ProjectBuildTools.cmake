# .rst: ProjectBuildTools
# ----------------
#
# build tools
#

include_guard(GLOBAL)

include(GNUInstallDirs)
include("${CMAKE_CURRENT_LIST_DIR}/AtframeworkToolsetCommonDefinitions.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/AtframeworkToolsetAutoInheritOptions.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ProjectSanitizerTools.cmake")

unset(ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
  list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS COMMAND_ECHO STDOUT)
endif()
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.18")
  list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS ECHO_OUTPUT_VARIABLE ECHO_ERROR_VARIABLE)
endif()

if(NOT PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES)
  set(PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES 3)
endif()

function(project_build_tools_append_space_one_flag_to_var VARNAME)
  if(${VARNAME})
    set(${VARNAME}
        "${${VARNAME}} ${ARGN}"
        PARENT_SCOPE)
  else()
    set(${VARNAME}
        "${ARGN}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_append_space_one_flag_to_var_unique VARNAME)
  if(${VARNAME})
    if(NOT "${${VARNAME}}" STREQUAL "${ARGN}")
      string(FIND "${${VARNAME}}" "${ARGN} " add_compiler_flags_to_var_unique_FIND_POSL)
      string(FIND "${${VARNAME}}" " ${ARGN}" add_compiler_flags_to_var_unique_FIND_POSR)
      if(add_compiler_flags_to_var_unique_FIND_POSL LESS 0 AND add_compiler_flags_to_var_unique_FIND_POSR LESS 0)
        set(${VARNAME}
            "${${VARNAME}} ${ARGN}"
            PARENT_SCOPE)
      endif()
    endif()
  else()
    set(${VARNAME}
        "${ARGN}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_append_space_flags_to_var VARNAME)
  set(FINAL_VALUE "${${VARNAME}}")
  foreach(def ${ARGN})
    if(FINAL_VALUE)
      set(FINAL_VALUE "${FINAL_VALUE} ${def}")
    else()
      set(FINAL_VALUE "${def}")
    endif()
  endforeach()
  set(${VARNAME}
      "${FINAL_VALUE}"
      PARENT_SCOPE)
endfunction()

function(project_build_tools_append_space_flags_to_var_unique VARNAME)
  set(FINAL_VALUE "${${VARNAME}}")
  foreach(def ${ARGN})
    if(FINAL_VALUE)
      if(FINAL_VALUE STREQUAL "${def}")
        break()
      else()
        string(FIND "${FINAL_VALUE}" "${def} " add_compiler_flags_to_var_unique_FIND_POSL)
        string(FIND "${FINAL_VALUE}" " ${def}" add_compiler_flags_to_var_unique_FIND_POSR)
        if(add_compiler_flags_to_var_unique_FIND_POSL LESS 0 AND add_compiler_flags_to_var_unique_FIND_POSR LESS 0)
          set(FINAL_VALUE "${FINAL_VALUE} ${def}")
        endif()
      endif()
    else()
      set(FINAL_VALUE "${def}")
    endif()
  endforeach()
  set(${VARNAME}
      "${FINAL_VALUE}"
      PARENT_SCOPE)
endfunction()

macro(project_build_tools_append_cmake_inherit_policy OUTVAR)
  # Policy
  unset(project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
  cmake_policy(GET CMP0091 project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
  if(project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
    list(APPEND ${OUTVAR}
         "-DCMAKE_POLICY_DEFAULT_CMP0091=${project_build_tools_append_cmake_inherit_policy_POLICY_VALUE}")
  endif()
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.20.0")
    unset(project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
    cmake_policy(GET CMP0117 project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
    if(project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
      list(APPEND ${OUTVAR}
           "-DCMAKE_POLICY_DEFAULT_CMP0117=${project_build_tools_append_cmake_inherit_policy_POLICY_VALUE}")
    endif()
  endif()
  unset(project_build_tools_append_cmake_inherit_policy_POLICY_VALUE)
endmacro()

macro(project_build_tools_append_cmake_inherit_options OUTVAR)
  cmake_parse_arguments(
    project_build_tools_append_cmake_inherit_options
    "DISABLE_C_FLAGS;DISABLE_CXX_FLAGS;DISABLE_ASM_FLAGS;DISABLE_TOOLCHAIN_FILE;DISABLE_CMAKE_FIND_ROOT_FLAGS;APPEND_SYSTEM_LINKS"
    ""
    ""
    ${ARGN})
  list(APPEND ${OUTVAR} "-G" "${CMAKE_GENERATOR}")
  if(DEFINED CACHE{CMAKE_MAKE_PROGRAM})
    list(APPEND ${OUTVAR} "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
  endif()

  set(project_build_tools_append_cmake_inherit_options_VARS PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON)
  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_CMAKE_FIND_ROOT_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS PROJECT_BUILD_TOOLS_CMAKE_FIND_ROOT_VARS)
  endif()
  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_C_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C)
  endif()
  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_CXX_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX)
  endif()
  if(NOT project_build_tools_append_cmake_inherit_options_DISABLE_ASM_FLAGS)
    list(APPEND project_build_tools_append_cmake_inherit_options_VARS PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM)
  endif()

  if(CMAKE_TOOLCHAIN_FILE AND NOT project_build_tools_append_cmake_inherit_options_DISABLE_TOOLCHAIN_FILE)
    list(APPEND ${OUTVAR} "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}")
  endif()

  foreach(VAR_NAME IN LISTS ${project_build_tools_append_cmake_inherit_options_VARS})
    unset(project_build_tools_append_cmake_inherit_VAR_VALUE)
    if(DEFINED COMPILER_OPTION_INHERIT_${VAR_NAME}
       OR DEFINED PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME}
       OR DEFINED PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_${VAR_NAME})
      if(DEFINED PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_${VAR_NAME})
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_${VAR_NAME}}")
      elseif(DEFINED COMPILER_OPTION_INHERIT_${VAR_NAME} AND DEFINED
                                                             PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME})
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${COMPILER_OPTION_INHERIT_${VAR_NAME}}${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME}}")
      elseif(DEFINED COMPILER_OPTION_INHERIT_${VAR_NAME})
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${COMPILER_OPTION_INHERIT_${VAR_NAME}}")
      else()
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME}}")
      endif()

      if(project_build_tools_append_cmake_inherit_options_APPEND_SYSTEM_LINKS
         AND ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS
         AND VAR_NAME MATCHES "^CMAKE_[A-Za-z0-9]+_STANDARD_LIBRARIES$")
        project_build_tools_append_space_flags_to_var_unique(project_build_tools_append_cmake_inherit_VAR_VALUE
                                                             "${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS}")
      endif()
      if(VAR_NAME MATCHES "_LIBRARIES|_INCLUDE_DIRECTORIES|_PATH$")
        list(REMOVE_DUPLICATES project_build_tools_append_cmake_inherit_VAR_VALUE)
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${project_build_tools_append_cmake_inherit_VAR_VALUE}")
      endif()
    elseif(ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS) # Add system links into standard libraries even not set
      if(project_build_tools_append_cmake_inherit_options_APPEND_SYSTEM_LINKS
         AND VAR_NAME MATCHES "^CMAKE_[A-Za-z0-9]+_STANDARD_LIBRARIES$")
        project_build_tools_append_space_flags_to_var_unique(project_build_tools_append_cmake_inherit_VAR_VALUE
                                                             "${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS}")
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${project_build_tools_append_cmake_inherit_VAR_VALUE}")
      endif()
    endif()
    if(DEFINED project_build_tools_append_cmake_inherit_VAR_VALUE)
      # Patch for some version of cmake, the compiler testing will fail on some environments.
      if(MSVC AND VAR_NAME MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
        list(APPEND ${OUTVAR} "-D${VAR_NAME}= ${project_build_tools_append_cmake_inherit_VAR_VALUE}")
      else()
        list(APPEND ${OUTVAR} "-D${VAR_NAME}=${project_build_tools_append_cmake_inherit_VAR_VALUE}")
      endif()
    endif()
  endforeach()
  unset(project_build_tools_append_cmake_inherit_VAR_VALUE)

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
  project_build_tools_append_cmake_inherit_policy(${OUTVAR})

  unset(project_build_tools_append_cmake_inherit_options_DISABLE_C_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_DISABLE_CXX_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_DISABLE_ASM_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_DISABLE_TOOLCHAIN_FILE)
  unset(project_build_tools_append_cmake_inherit_options_DISABLE_CMAKE_FIND_ROOT_FLAGS)
  unset(project_build_tools_append_cmake_inherit_options_VARS)
endmacro()

function(project_build_tools_combine_space_flags_unique OUTPUT_VARNAME)
  unset(FINAL_VALUE)
  foreach(SOURCE_VARNAME ${ARGN})
    if(${SOURCE_VARNAME})
      set(FINAL_VALUE "${FINAL_VALUE} ${${SOURCE_VARNAME}}")
    endif()
  endforeach()
  separate_arguments(FINAL_VALUE)
  list(REMOVE_DUPLICATES FINAL_VALUE)
  string(REPLACE ";" " " FINAL_VALUE "${FINAL_VALUE}")
  set(${OUTPUT_VARNAME}
      "${FINAL_VALUE}"
      PARENT_SCOPE)
endfunction()

macro(project_build_tools_append_cmake_host_options OUTVAR)
  cmake_parse_arguments(
    project_build_tools_append_cmake_host_options
    "DISABLE_C_FLAGS;DISABLE_CXX_FLAGS;DISABLE_ASM_FLAGS;DISABLE_TOOLCHAIN_FILE;APPEND_SYSTEM_LINKS" "" "" ${ARGN})
  if(CMAKE_HOST_GENERATOR)
    list(APPEND ${OUTVAR} "-G" "${CMAKE_HOST_GENERATOR}")
  elseif(MSVC)
    list(APPEND ${OUTVAR} "-G" "${CMAKE_GENERATOR}")
  endif()
  if(DEFINED CACHE{CMAKE_HOST_MAKE_PROGRAM})
    list(APPEND ${OUTVAR} "-DCMAKE_MAKE_PROGRAM=${CMAKE_HOST_MAKE_PROGRAM}")
  endif()

  if(PROJECT_PREBUILT_HOST_PLATFORM_NAME)
    list(APPEND ${OUTVAR} "-DPROJECT_PREBUILT_PLATFORM_NAME=${PROJECT_PREBUILT_HOST_PLATFORM_NAME}")
  endif()

  set(project_build_tools_append_cmake_host_options_VARS PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_COMMON
                                                         PROJECT_BUILD_TOOLS_CMAKE_HOST_INHERIT_VARS_COMMON)
  if(PROJECT_BUILD_TOOLS_CMAKE_HOST_PASSTHROUGH)
    list(APPEND project_build_tools_append_cmake_host_options_VARS PROJECT_BUILD_TOOLS_CMAKE_HOST_PASSTHROUGH)
  endif()

  if(NOT project_build_tools_append_cmake_host_options_DISABLE_C_FLAGS)
    list(APPEND project_build_tools_append_cmake_host_options_VARS PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_C)
  endif()
  if(NOT project_build_tools_append_cmake_host_options_DISABLE_CXX_FLAGS)
    list(APPEND project_build_tools_append_cmake_host_options_VARS PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_CXX)
  endif()
  if(NOT project_build_tools_append_cmake_host_options_DISABLE_ASM_FLAGS)
    list(APPEND project_build_tools_append_cmake_host_options_VARS PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_ASM)
  endif()

  if(CMAKE_HOST_TOOLCHAIN_FILE AND NOT project_build_tools_append_cmake_host_options_DISABLE_TOOLCHAIN_FILE)
    list(APPEND ${OUTVAR} "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_HOST_TOOLCHAIN_FILE}")
  endif()

  unset(project_build_tools_append_cmake_inherit_HAS_CMAKE_FIND_ROOT_PATH)
  unset(project_build_tools_append_cmake_inherit_HAS_CMAKE_PREFIX_PATH)
  foreach(VAR_NAME IN LISTS ${project_build_tools_append_cmake_host_options_VARS})
    unset(project_build_tools_append_cmake_inherit_VAR_VALUE)
    if(DEFINED COMPILER_OPTION_INHERIT_${VAR_NAME}
       OR DEFINED PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME}
       OR DEFINED PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_${VAR_NAME})
      if(DEFINED PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_${VAR_NAME})
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_${VAR_NAME}}")
      elseif(DEFINED COMPILER_OPTION_INHERIT_${VAR_NAME} AND DEFINED
                                                             PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME})
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${COMPILER_OPTION_INHERIT_${VAR_NAME}}${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME}}")
      elseif(DEFINED COMPILER_OPTION_INHERIT_${VAR_NAME})
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${COMPILER_OPTION_INHERIT_${VAR_NAME}}")
      else()
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_${VAR_NAME}}")
      endif()

      if(project_build_tools_append_cmake_host_options_APPEND_SYSTEM_LINKS
         AND ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS
         AND VAR_NAME MATCHES "^CMAKE_[A-Za-z0-9]+_STANDARD_LIBRARIES$")
        project_build_tools_append_space_flags_to_var_unique(project_build_tools_append_cmake_inherit_VAR_VALUE
                                                             "${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS}")
      endif()
      if(VAR_NAME MATCHES "_LIBRARIES|_INCLUDE_DIRECTORIES|_PATH$")
        list(REMOVE_DUPLICATES project_build_tools_append_cmake_inherit_VAR_VALUE)
      endif()
    elseif(ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS) # Add system links into standard libraries even not set
      if(project_build_tools_append_cmake_host_options_APPEND_SYSTEM_LINKS
         AND VAR_NAME MATCHES "^CMAKE_[A-Za-z0-9]+_STANDARD_LIBRARIES$")
        project_build_tools_append_space_flags_to_var_unique(project_build_tools_append_cmake_inherit_VAR_VALUE
                                                             "${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS}")
        string(REPLACE ";" "\\;" project_build_tools_append_cmake_inherit_VAR_VALUE
                       "${project_build_tools_append_cmake_inherit_VAR_VALUE}")
      endif()
    endif()
    if(project_build_tools_append_cmake_inherit_VAR_VALUE)
      if(VAR_NAME MATCHES "^CMAKE_HOST_(.+)")
        set(project_build_tools_append_cmake_inherit_VAR_NAME "CMAKE_${CMAKE_MATCH_1}")
      else()
        set(project_build_tools_append_cmake_inherit_VAR_NAME "${VAR_NAME}")
      endif()
      # Patch for some version of cmake, the compiler testing will fail on some environments.
      if(MSVC AND VAR_NAME MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
        list(
          APPEND
          ${OUTVAR}
          "-D${project_build_tools_append_cmake_inherit_VAR_NAME}= ${project_build_tools_append_cmake_inherit_VAR_VALUE}"
        )
      else()
        if(project_build_tools_append_cmake_inherit_VAR_NAME STREQUAL "CMAKE_FIND_ROOT_PATH")
          list(
            APPEND
            ${OUTVAR}
            "-DCMAKE_FIND_ROOT_PATH=${project_build_tools_append_cmake_inherit_VAR_VALUE}\;${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
          )
          set(project_build_tools_append_cmake_inherit_HAS_CMAKE_FIND_ROOT_PATH TRUE)
        elseif(project_build_tools_append_cmake_inherit_VAR_NAME STREQUAL "CMAKE_PREFIX_PATH")
          list(
            APPEND
            ${OUTVAR}
            "-DCMAKE_PREFIX_PATH=${project_build_tools_append_cmake_inherit_VAR_VALUE}\;${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
          )
          set(project_build_tools_append_cmake_inherit_HAS_CMAKE_PREFIX_PATH TRUE)
        else()
          list(
            APPEND
            ${OUTVAR}
            "-D${project_build_tools_append_cmake_inherit_VAR_NAME}=${project_build_tools_append_cmake_inherit_VAR_VALUE}"
          )
        endif()
      endif()
    endif()
  endforeach()
  unset(project_build_tools_append_cmake_inherit_VAR_NAME)
  unset(project_build_tools_append_cmake_inherit_VAR_VALUE)

  if(NOT project_build_tools_append_cmake_inherit_HAS_CMAKE_FIND_ROOT_PATH)
    list(APPEND ${OUTVAR} "-DCMAKE_FIND_ROOT_PATH=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}")
  endif()
  if(NOT project_build_tools_append_cmake_inherit_HAS_CMAKE_PREFIX_PATH)
    list(APPEND ${OUTVAR} "-DCMAKE_PREFIX_PATH=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}")
  endif()

  # vcpkg
  if(VCPKG_HOST_TRIPLET)
    list(APPEND ${OUTVAR} "-DVCPKG_TARGET_TRIPLET=${VCPKG_HOST_TRIPLET}")
  endif()

  if(CMAKE_HOST_GENERATOR_PLATFORM)
    list(APPEND ${OUTVAR} "-A" "${CMAKE_HOST_GENERATOR_PLATFORM}")
  elseif(MSVC AND CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE)
    list(APPEND ${OUTVAR} "-A" "${CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE}")
  endif()

  if(CMAKE_HOST_GENERATOR_TOOLSET)
    list(APPEND ${OUTVAR} "-T" "${CMAKE_HOST_GENERATOR_TOOLSET}")
  endif()

  # Policy
  project_build_tools_append_cmake_inherit_policy(${OUTVAR})

  unset(project_build_tools_append_cmake_inherit_HAS_CMAKE_FIND_ROOT_PATH)
  unset(project_build_tools_append_cmake_inherit_HAS_CMAKE_PREFIX_PATH)
  unset(project_build_tools_append_cmake_host_options_DISABLE_C_FLAGS)
  unset(project_build_tools_append_cmake_host_options_DISABLE_CXX_FLAGS)
  unset(project_build_tools_append_cmake_host_options_DISABLE_ASM_FLAGS)
  unset(project_build_tools_append_cmake_host_options_DISABLE_TOOLCHAIN_FILE)
  unset(project_build_tools_append_cmake_host_options_VARS)
endmacro()

macro(project_build_tools_get_cmake_build_type_for_lib OUTVAR)
  if(CMAKE_BUILD_TYPE)
    if(MSVC)
      set(${OUTVAR} "${CMAKE_BUILD_TYPE}")
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
      set(${OUTVAR} "RelWithDebInfo")
    else()
      set(${OUTVAR} "${CMAKE_BUILD_TYPE}")
    endif()
  elseif(MSVC)
    set(${OUTVAR} "Release")
  endif()
endmacro()

macro(project_build_tools_append_cmake_build_type_for_lib OUTVAR)
  if(CMAKE_BUILD_TYPE)
    if(MSVC)
      list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
    elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=RelWithDebInfo")
      if(NOT CMAKE_MAP_IMPORTED_CONFIG_DEBUG AND UNIX)
        list(APPEND ${ARGV0} "-DCMAKE_MAP_IMPORTED_CONFIG_DEBUG=RelWithDebInfo")
      endif()
    else()
      list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
    endif()
  elseif(MSVC)
    list(APPEND ${ARGV0} "-DCMAKE_BUILD_TYPE=Release")
    list(APPEND ${ARGV0} "-DCMAKE_MAP_IMPORTED_CONFIG_NOCONFIG=Release")
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
    if("${ARG}" STREQUAL "DISABLE_C_FLAGS" OR "${ARG}" STREQUAL "DISABLE_C_STANDARD")
      set(project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS TRUE)
    endif()
    if("${ARG}" STREQUAL "DISABLE_CXX_FLAGS" OR "${ARG}" STREQUAL "DISABLE_CXX_STANDARD")
      set(project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS TRUE)
    endif()
  endforeach()
  if(NOT project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS)
    if(CMAKE_C_STANDARD)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}")
    endif()
    if(DEFINED CMAKE_C_STANDARD)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}")
    endif()
  endif()
  if(NOT project_build_tools_append_cmake_cxx_standard_options_DISABLE_C_FLAGS)
    if(CMAKE_OBJC_STANDARD)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_OBJC_STANDARD=${CMAKE_OBJC_STANDARD}")
    endif()
    if(DEFINED CMAKE_OBJC_STANDARD)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_OBJC_STANDARD=${CMAKE_OBJC_STANDARD}")
    endif()
  endif()
  if(NOT project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS)
    if(CMAKE_CXX_STANDARD)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}")
    endif()
    if(DEFINED CMAKE_CXX_EXTENSIONS)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}")
    endif()
  endif()
  if(NOT project_build_tools_append_cmake_cxx_standard_options_DISABLE_CXX_FLAGS)
    if(CMAKE_OBJCXX_STANDARD)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_OBJCXX_STANDARD=${CMAKE_OBJCXX_STANDARD}")
    endif()
    if(DEFINED CMAKE_OBJCXX_EXTENSIONS)
      list(APPEND ${project_build_tools_append_cmake_cxx_standard_options_OUTVAR}
           "-DCMAKE_OBJCXX_EXTENSIONS=${CMAKE_OBJCXX_EXTENSIONS}")
    endif()
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

macro(project_build_tools_append_cmake_options_for_host OUTVAR)
  project_build_tools_append_cmake_host_options(${OUTVAR} ${ARGN})
  project_build_tools_append_cmake_build_type_for_lib(${OUTVAR})
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

function(project_expand_list_for_command_line_to_file MODE)
  unset(project_expand_list_for_command_line_to_file_OUTPUT)
  unset(project_expand_list_for_command_line_to_file_LINE)
  foreach(ARG ${ARGN})
    if(NOT project_expand_list_for_command_line_to_file_OUTPUT)
      set(project_expand_list_for_command_line_to_file_OUTPUT "${ARG}")
    else()
      if(MODE MATCHES "BAT|CMD")
        string(REPLACE "\\" "\\\\" project_expand_list_for_command_line_OUT_VAR "${ARG}")
        string(REPLACE "\"" "\\\"" project_expand_list_for_command_line_OUT_VAR
                       "${project_expand_list_for_command_line_OUT_VAR}")
      elseif(MODE MATCHES "POWERSHELL|PWSH")
        string(REPLACE "`" "``" project_expand_list_for_command_line_OUT_VAR "${ARG}")
        if(NOT project_expand_list_for_command_line_OUT_VAR STREQUAL "&")
          string(REPLACE "\"" "`\"" project_expand_list_for_command_line_OUT_VAR
                         "${project_expand_list_for_command_line_OUT_VAR}")
          string(REPLACE "\$" "`\$" project_expand_list_for_command_line_OUT_VAR
                         "${project_expand_list_for_command_line_OUT_VAR}")
        endif()
      elseif(MODE MATCHES "BASH|SHELL|ZSH")
        string(REPLACE "\\" "\\\\" project_expand_list_for_command_line_OUT_VAR "${ARG}")
        string(REPLACE "\"" "\\\"" project_expand_list_for_command_line_OUT_VAR
                       "${project_expand_list_for_command_line_OUT_VAR}")
        string(REPLACE "\$" "\\\$" project_expand_list_for_command_line_OUT_VAR
                       "${project_expand_list_for_command_line_OUT_VAR}")
      else()
        set(project_expand_list_for_command_line_OUT_VAR "${ARG}")
      endif()
      if(project_expand_list_for_command_line_to_file_LINE)
        set(project_expand_list_for_command_line_to_file_LINE
            "${project_expand_list_for_command_line_to_file_LINE} \"${project_expand_list_for_command_line_OUT_VAR}\"")
      else()
        if(MODE MATCHES "POWERSHELL|PWSH")
          if(project_expand_list_for_command_line_OUT_VAR STREQUAL "&")
            set(project_expand_list_for_command_line_to_file_LINE "${project_expand_list_for_command_line_OUT_VAR}")
          elseif(EXISTS "${project_expand_list_for_command_line_OUT_VAR}")
            set(project_expand_list_for_command_line_to_file_LINE
                "& \"${project_expand_list_for_command_line_OUT_VAR}\"")
          else()
            set(project_expand_list_for_command_line_to_file_LINE "\"${project_expand_list_for_command_line_OUT_VAR}\"")
          endif()
        else()
          set(project_expand_list_for_command_line_to_file_LINE "\"${project_expand_list_for_command_line_OUT_VAR}\"")
        endif()
      endif()
      unset(project_expand_list_for_command_line_OUT_VAR)
    endif()
  endforeach()

  if(project_expand_list_for_command_line_to_file_OUTPUT)
    file(APPEND "${project_expand_list_for_command_line_to_file_OUTPUT}"
         "${project_expand_list_for_command_line_to_file_LINE}${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(project_expand_list_for_command_line_to_file_OUTPUT)
  unset(project_expand_list_for_command_line_to_file_LINE)
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

function(project_build_tools_find_make_program OUTVAR)
  if(CMAKE_MAKE_PROGRAM MATCHES "make(.exe)?$")
    set(${OUTVAR}
        "${CMAKE_MAKE_PROGRAM}"
        PARENT_SCOPE)
  else()
    unset(_make_executable)
    if(MINGW)
      find_program(
        _make_executable mingw32-make.exe
        PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MinGW;InstallLocation]/bin"
              c:/MinGW/bin /MinGW/bin "[HKEY_CURRENT_USER\\Software\\CodeBlocks;Path]/MinGW/bin")
    endif()
    if(NOT _make_executable AND MSYS)
      find_program(
        _make_executable make
        PATHS
          "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MSYS-1.0_is1;Inno Setup: App Path]/bin"
          "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\MinGW;InstallLocation]/bin"
          c:/msys/1.0/bin
          /msys/1.0/bin)
    endif()
    if(NOT _make_executable)
      find_program(_make_executable NAMES gmake make smake)
      if(NOT _make_executable AND CMAKE_HOST_APPLE)
        execute_process(
          COMMAND xcrun --find make
          OUTPUT_VARIABLE _xcrun_out
          OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_VARIABLE _xcrun_err)
        if(_xcrun_out)
          set(_make_executable "${_xcrun_out}")
        endif()
      endif()
    endif()
    set(${OUTVAR}
        "${_make_executable}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_find_nmake_program OUTVAR)
  set(${OUTVAR}
      "nmake"
      PARENT_SCOPE)
endfunction()

function(project_git_get_ambiguous_name OUTPUT_VAR_NAME GIT_WORKSPACE)
  set(optionArgs ENABLE_TAG_NAME ENABLE_TAG_OFFSET ENABLE_BRANCH_NAME)
  set(oneValueArgs "")
  set(multiValueArgs "")
  cmake_parse_arguments(project_git_get_ambiguous_name "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  find_package(Git)
  if(NOT GIT_FOUND AND NOT Git_FOUND)
    message(FATAL_ERROR "git not found")
  endif()

  if(project_git_get_ambiguous_name_ENABLE_TAG_NAME)
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" describe --tags --exact-match HEAD
      WORKING_DIRECTORY "${GIT_WORKSPACE}"
      RESULT_VARIABLE OUTPUT_RESULT
      OUTPUT_VARIABLE OUTPUT_VAR_VALUE
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(OUTPUT_VAR_VALUE AND OUTPUT_RESULT EQUAL 0)
      set(${OUTPUT_VAR_NAME}
          "${OUTPUT_VAR_VALUE}"
          PARENT_SCOPE)
      return()
    endif()
  endif()

  if(project_git_get_ambiguous_name_ENABLE_TAG_NAME AND project_git_get_ambiguous_name_ENABLE_TAG_OFFSET)
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" describe --tags HEAD
      WORKING_DIRECTORY "${GIT_WORKSPACE}"
      RESULT_VARIABLE OUTPUT_RESULT
      OUTPUT_VARIABLE OUTPUT_VAR_VALUE
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(OUTPUT_VAR_VALUE AND OUTPUT_RESULT EQUAL 0)
      set(${OUTPUT_VAR_NAME}
          "${OUTPUT_VAR_VALUE}"
          PARENT_SCOPE)
      return()
    endif()
  endif()

  if(project_git_get_ambiguous_name_ENABLE_BRANCH_NAME)
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" describe --contains --all HEAD
      WORKING_DIRECTORY "${GIT_WORKSPACE}"
      RESULT_VARIABLE OUTPUT_RESULT
      OUTPUT_VARIABLE OUTPUT_VAR_VALUE
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(OUTPUT_VAR_VALUE AND OUTPUT_RESULT EQUAL 0)
      set(${OUTPUT_VAR_NAME}
          "${OUTPUT_VAR_VALUE}"
          PARENT_SCOPE)
      return()
    endif()
  endif()

  execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --short HEAD
    WORKING_DIRECTORY "${GIT_WORKSPACE}"
    OUTPUT_VARIABLE OUTPUT_VAR_VALUE
    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(OUTPUT_VAR_VALUE)
    set(${OUTPUT_VAR_NAME}
        "${OUTPUT_VAR_VALUE}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_git_clone_repository)
  set(optionArgs ENABLE_SUBMODULE SUBMODULE_RECURSIVE REQUIRED FORCE_RESET ALWAYS_UPDATE_REMOTE)
  set(oneValueArgs
      URL
      WORKING_DIRECTORY
      REPO_DIRECTORY
      DEPTH
      BRANCH
      COMMIT
      TAG
      CHECK_PATH
      LOCK_TIMEOUT
      LOCK_FILE)
  set(multiValueArgs PATCH_FILES SUBMODULE_PATH RESET_SUBMODULE_URLS GIT_CONFIG FETCH_FILTER SPARSE_CHECKOUT)
  cmake_parse_arguments(project_git_clone_repository "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG)
    set(project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS
        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    message(
      STATUS
        "Try to git clone ${project_git_clone_repository_TAG}${project_git_clone_repository_BRANCH}${project_git_clone_repository_COMMIT} into ${project_git_clone_repository_REPO_DIRECTORY}"
    )
    if(project_git_clone_repository_PATCH_FILES)
      message(STATUS "  Using patch files: ${project_git_clone_repository_PATCH_FILES}")
    endif()
  else()
    set(project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS)
  endif()

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
    set(project_git_clone_repository_GIT_BRANCH "${project_git_clone_repository_TAG}")
  elseif(project_git_clone_repository_BRANCH)
    set(project_git_clone_repository_GIT_BRANCH "${project_git_clone_repository_BRANCH}")
  endif()
  set(git_global_options -c "advice.detachedHead=false" -c "init.defaultBranch=main")
  if(project_git_clone_repository_GIT_CONFIG)
    foreach(config IN LISTS project_git_clone_repository_GIT_CONFIG)
      list(APPEND git_global_options -c "${config}")
    endforeach()
  endif()

  # Patch for `FindGit.cmake` on windows
  find_program(GIT_EXECUTABLE NAMES git git.cmd)
  find_package(Git)
  if(NOT GIT_FOUND AND NOT Git_FOUND)
    message(FATAL_ERROR "git not found")
  endif()

  # Lock the directory to prevent other process to access it
  if(NOT project_git_clone_repository_LOCK_TIMEOUT)
    set(project_git_clone_repository_LOCK_TIMEOUT 600)
  endif()
  if(NOT project_git_clone_repository_LOCK_FILE)
    set(project_git_clone_repository_LOCK_FILE "${project_git_clone_repository_REPO_DIRECTORY}.cmake-toolset.lock")
  endif()
  get_filename_component(project_git_clone_repository_LOCK_FILE_DIRECTORY "${project_git_clone_repository_LOCK_FILE}"
                         DIRECTORY)
  if(NOT EXISTS "${project_git_clone_repository_LOCK_FILE_DIRECTORY}")
    file(MAKE_DIRECTORY "${project_git_clone_repository_LOCK_FILE_DIRECTORY}")
  endif()
  file(
    LOCK "${project_git_clone_repository_LOCK_FILE}"
    GUARD PROCESS
    RESULT_VARIABLE LOCK_RESULT
    TIMEOUT ${project_git_clone_repository_LOCK_TIMEOUT})
  if(project_git_clone_repository_FORCE_RESET AND EXISTS "${project_git_clone_repository_REPO_DIRECTORY}")
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" ${git_global_options} clean -dfx
      COMMAND "${GIT_EXECUTABLE}" ${git_global_options} reset --hard
      WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
      RESULT_VARIABLE LAST_GIT_RESET_RESULT ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

    if(LAST_GIT_RESET_RESULT AND NOT LAST_GIT_RESET_RESULT EQUAL 0)
      file(REMOVE_RECURSE "${project_git_clone_repository_REPO_DIRECTORY}")
    elseif(project_git_clone_repository_ENABLE_SUBMODULE)
      if(project_git_clone_repository_SUBMODULE_RECURSIVE)
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} submodule foreach --recursive "git clean -dfx"
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} submodule foreach --recursive "git reset --hard"
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
      else()
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} submodule foreach "git clean -dfx"
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} submodule foreach "git reset --hard"
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
      endif()
      if(project_git_clone_repository_PATCH_FILES)
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} -c "core.autocrlf=true" apply
                  ${project_git_clone_repository_PATCH_FILES}
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
    endif()
  endif()

  # Check and cleanup directory if fetch failed before
  if(EXISTS "${project_git_clone_repository_REPO_DIRECTORY}/.git")
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" ${git_global_options} log -n 1 --oneline
      WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
      RESULT_VARIABLE project_git_clone_repository_GIT_CHECK_REPO
      OUTPUT_QUIET ERROR_QUIET ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
    if(NOT project_git_clone_repository_GIT_CHECK_REPO EQUAL 0)
      message(STATUS "${project_git_clone_repository_REPO_DIRECTORY} is not a valid git repository, remove it...")
      file(REMOVE_RECURSE "${project_git_clone_repository_REPO_DIRECTORY}")
    endif()
    unset(project_git_clone_repository_GIT_CHECK_REPO)
  endif()

  if(NOT EXISTS "${project_git_clone_repository_REPO_DIRECTORY}/${project_git_clone_repository_CHECK_PATH}")
    if(EXISTS "${project_git_clone_repository_REPO_DIRECTORY}")
      file(REMOVE_RECURSE "${project_git_clone_repository_REPO_DIRECTORY}")
    endif()
  else()
    # Check selected tag/branch/commit
    if(project_git_clone_repository_GIT_BRANCH)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} -c "core.autocrlf=true" config --local -z --get
                "atframework.toolset.git-clone.current-version"
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
        OUTPUT_VARIABLE LAST_GIT_CLONE_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
      if(NOT LAST_GIT_CLONE_VERSION STREQUAL project_git_clone_repository_GIT_BRANCH)
        message(
          STATUS
            "${project_git_clone_repository_REPO_DIRECTORY} is not branch/tag ${project_git_clone_repository_GIT_BRANCH}(got ${LAST_GIT_CLONE_VERSION}), remove it..."
        )
        file(REMOVE_RECURSE "${project_git_clone_repository_REPO_DIRECTORY}")
      endif()
    elseif(project_git_clone_repository_COMMIT)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} -c "core.autocrlf=true" config --local -z --get
                "atframework.toolset.git-clone.current-version"
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
        OUTPUT_VARIABLE LAST_GIT_CLONE_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
      if(NOT LAST_GIT_CLONE_VERSION STREQUAL project_git_clone_repository_COMMIT)
        message(
          STATUS
            "${project_git_clone_repository_REPO_DIRECTORY} is not commit ${project_git_clone_repository_COMMIT}(got ${LAST_GIT_CLONE_VERSION}), remove it..."
        )
        file(REMOVE_RECURSE "${project_git_clone_repository_REPO_DIRECTORY}")
      endif()
    endif()
  endif()

  if(NOT EXISTS "${project_git_clone_repository_REPO_DIRECTORY}/${project_git_clone_repository_CHECK_PATH}"
     OR (project_git_clone_repository_ALWAYS_UPDATE_REMOTE AND project_git_clone_repository_GIT_BRANCH))
    if(NOT EXISTS "${project_git_clone_repository_REPO_DIRECTORY}")
      file(MAKE_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}")
    endif()

    if(NOT EXISTS "${project_git_clone_repository_REPO_DIRECTORY}/.git")
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.28.0")
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} init -b main
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} init
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} remote add origin "${project_git_clone_repository_URL}"
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    endif()

    if(project_git_clone_repository_SPARSE_CHECKOUT)
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.25.0")
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} sparse-checkout init --cone
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} sparse-checkout set
                  ${project_git_clone_repository_SPARSE_CHECKOUT}
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        list(APPEND project_git_clone_repository_FETCH_FILTER
             "sparse:path=${project_git_clone_repository_SPARSE_CHECKOUT}")
      endif()
    endif()

    set(project_git_clone_repository_FETCH_FILTER_CONTENT)
    set(project_git_clone_repository_FETCH_FILTER_COMBINE FALSE)
    foreach(FILTER ${project_git_clone_repository_FETCH_FILTER})
      if(project_git_clone_repository_FETCH_FILTER_CONTENT)
        if(project_git_clone_repository_FETCH_FILTER_COMBINE)
          set(project_git_clone_repository_FETCH_FILTER_CONTENT
              "${project_git_clone_repository_FETCH_FILTER_CONTENT}+${FILTER}")
        else()
          set(project_git_clone_repository_FETCH_FILTER_CONTENT
              "combine:${project_git_clone_repository_FETCH_FILTER_CONTENT}+${FILTER}")
          set(project_git_clone_repository_FETCH_FILTER_COMBINE TRUE)
        endif()
      else()
        set(project_git_clone_repository_FETCH_FILTER_CONTENT "${FILTER}")
      endif()
    endforeach()

    if(NOT project_git_clone_repository_GIT_BRANCH AND NOT project_git_clone_repository_COMMIT)
      unset(project_git_clone_repository_GIT_CHECK_REPO)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} ls-remote --symref origin HEAD
        RESULT_VARIABLE project_git_clone_repository_GIT_LS_REMOTE_RESULT
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
        OUTPUT_VARIABLE project_git_clone_repository_GIT_CHECK_REPO
                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      if(project_git_clone_repository_GIT_CHECK_REPO AND project_git_clone_repository_GIT_CHECK_REPO MATCHES
                                                         "ref.*refs/heads/([^ \t]*)[ \t]*HEAD.*")
        set(project_git_clone_repository_GIT_BRANCH "${CMAKE_MATCH_1}")
      else()
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${git_global_options} ls-remote origin HEAD
          RESULT_VARIABLE project_git_clone_repository_GIT_LS_REMOTE_RESULT
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
          OUTPUT_VARIABLE project_git_clone_repository_GIT_CHECK_REPO
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        if(project_git_clone_repository_GIT_CHECK_REPO MATCHES "^([a-zA-Z0-9]*)[ \t]*HEAD.*")
          set(project_git_clone_repository_COMMIT "${CMAKE_MATCH_1}")
        endif()
      endif()
      if(NOT project_git_clone_repository_GIT_BRANCH AND NOT project_git_clone_repository_COMMIT)
        if(NOT project_git_clone_repository_GIT_LS_REMOTE_RESULT EQUAL 0 AND project_git_clone_repository_REQUIRED)
          message(FATAL_ERROR "git ls-remote --symref origin(${project_git_clone_repository_URL}) HEAD failed")
        endif()
        # Fallback
        set(project_git_clone_repository_GIT_BRANCH main)
      endif()
      unset(project_git_clone_repository_GIT_CHECK_REPO)
      unset(project_git_clone_repository_GIT_LS_REMOTE_RESULT)
    endif()

    if(project_git_clone_repository_GIT_BRANCH)
      set(project_git_fetch_repository_args ${git_global_options} fetch)
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "1.8.4")
        list(APPEND project_git_fetch_repository_args "--depth=${project_git_clone_repository_DEPTH}")
      endif()
      if(project_git_clone_repository_FETCH_FILTER_CONTENT)
        list(APPEND project_git_fetch_repository_args "--filter=${project_git_clone_repository_FETCH_FILTER_CONTENT}")
      endif()
      list(APPEND project_git_fetch_repository_args "-n" # No tags
           "origin" "${project_git_clone_repository_GIT_BRANCH}")
      set(project_git_fetch_repository_RETRY_TIMES 0)
      while(project_git_fetch_repository_RETRY_TIMES LESS_EQUAL PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES)
        if(project_git_fetch_repository_RETRY_TIMES GREATER 0)
          message(
            STATUS
              "Retry to fetch \"${project_git_clone_repository_GIT_BRANCH}\" from ${project_git_clone_repository_URL} for the ${project_git_fetch_repository_RETRY_TIMES} time(s)."
          )
        endif()
        math(EXPR project_git_fetch_repository_RETRY_TIMES "${project_git_fetch_repository_RETRY_TIMES} + 1"
             OUTPUT_FORMAT DECIMAL)
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${project_git_fetch_repository_args}
          RESULT_VARIABLE project_git_clone_repository_GIT_FETCH_RESULT
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        if(project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0)
          break()
        endif()
      endwhile()
      if(NOT project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0 AND project_git_clone_repository_REQUIRED)
        message(
          FATAL_ERROR
            "git fetch origin(${project_git_clone_repository_URL}) \"${project_git_clone_repository_GIT_BRANCH}\" failed"
        )
      endif()
    else()
      set(project_git_fetch_repository_args ${git_global_options} fetch)
      if(project_git_clone_repository_FETCH_FILTER_CONTENT)
        list(APPEND project_git_fetch_repository_args "--filter=${project_git_clone_repository_FETCH_FILTER_CONTENT}")
      endif()
      set(project_git_fetch_repository_RETRY_TIMES 0)
      while(project_git_fetch_repository_RETRY_TIMES LESS_EQUAL PROJECT_BUILD_TOOLS_DOWNLOAD_RETRY_TIMES)
        if(project_git_fetch_repository_RETRY_TIMES GREATER 0)
          message(
            STATUS
              "Retry to fetch ${project_git_clone_repository_COMMIT} from ${project_git_clone_repository_URL} for the ${project_git_fetch_repository_RETRY_TIMES} time(s)."
          )
        endif()
        math(EXPR project_git_fetch_repository_RETRY_TIMES "${project_git_fetch_repository_RETRY_TIMES} + 1"
             OUTPUT_FORMAT DECIMAL)
        execute_process(
          COMMAND "${GIT_EXECUTABLE}" ${project_git_fetch_repository_args}
                  "--depth=${project_git_clone_repository_DEPTH}" "-n" origin ${project_git_clone_repository_COMMIT}
          RESULT_VARIABLE project_git_clone_repository_GIT_FETCH_RESULT
          WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        # Some server do not support --depth=N , we fallback to full fetch
        if(NOT project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0)
          message(WARNING "It's recommended to use git 2.11.0 or upper to only fetch partly of repository.")
          execute_process(
            COMMAND "${GIT_EXECUTABLE}" ${project_git_fetch_repository_args} "-n" origin
                    ${project_git_clone_repository_COMMIT}
            RESULT_VARIABLE project_git_clone_repository_GIT_FETCH_RESULT
            WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                              ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        endif()
        if(project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0)
          break()
        endif()
      endwhile()
      if(NOT project_git_clone_repository_GIT_FETCH_RESULT EQUAL 0 AND project_git_clone_repository_REQUIRED)
        message(
          FATAL_ERROR
            "git fetch origin(${project_git_clone_repository_URL}) \"${project_git_clone_repository_GIT_BRANCH}\" failed"
        )
      endif()
    endif()
    unset(project_git_clone_repository_GIT_FETCH_RESULT)
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" ${git_global_options} reset --hard FETCH_HEAD
      WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    if(project_git_clone_repository_ENABLE_SUBMODULE)
      if(project_git_clone_repository_RESET_SUBMODULE_URLS)
        if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.25.0")
          foreach(RESET_SUBMODULE_URL ${project_git_clone_repository_RESET_SUBMODULE_URLS})
            if(RESET_SUBMODULE_URL MATCHES "([^:]+):(.+)")
              execute_process(
                COMMAND "${GIT_EXECUTABLE}" ${git_global_options} submodule "set-url" "--" "${CMAKE_MATCH_1}"
                        "${CMAKE_MATCH_2}"
                WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                                  ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
            else()
              message(WARNING "Ignore invalid git submodule reset-url rule ${RESET_SUBMODULE_URL}")
            endif()
          endforeach()
        else()
          message(WARNING "Only git 2.25.0 or upper support git set-url ...")
        endif()
      endif()
      set(project_git_clone_repository_submodule_args submodule update --init -f)
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "1.8.4")
        list(APPEND project_git_clone_repository_submodule_args --depth ${project_git_clone_repository_DEPTH})
      endif()
      if(project_git_clone_repository_SUBMODULE_RECURSIVE)
        list(APPEND project_git_clone_repository_submodule_args "--recursive")
      endif()
      if(project_git_clone_repository_SUBMODULE_PATH)
        list(APPEND project_git_clone_repository_submodule_args "--" ${project_git_clone_repository_SUBMODULE_PATH})
      endif()

      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} ${project_git_clone_repository_submodule_args}
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    endif()

    if(project_git_clone_repository_PATCH_FILES)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} -c "core.autocrlf=true" apply
                ${project_git_clone_repository_PATCH_FILES}
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                          ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    endif()
    if(project_git_clone_repository_GIT_BRANCH)
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} -c "core.autocrlf=true" config --local --replace-all
                "atframework.toolset.git-clone.current-version" "${project_git_clone_repository_GIT_BRANCH}"
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                          ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
    else()
      execute_process(
        COMMAND "${GIT_EXECUTABLE}" ${git_global_options} -c "core.autocrlf=true" config --local --replace-all
                "atframework.toolset.git-clone.current-version" "${project_git_clone_repository_COMMIT}"
        WORKING_DIRECTORY "${project_git_clone_repository_REPO_DIRECTORY}"
                          ${project_git_clone_repository_EXECUTE_PROCESS_DEBUG_OPTIONS})
    endif()
  endif()

  # unlock
  if(LOCK_RESULT EQUAL 0)
    file(LOCK "${project_git_clone_repository_LOCK_FILE}" RELEASE)
    file(REMOVE "${project_git_clone_repository_LOCK_FILE}")
  endif()
endfunction()

if(NOT PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS_SET)
  if(MSVC)
    unset(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS CACHE)
    set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS
        /wd4100
        /wd4244
        /wd4251
        /wd4267
        /wd4309
        /wd4668
        /wd4702
        /wd4715
        /wd4800
        /wd4946
        /wd6001
        /wd6244
        /wd6246)
    # upb
    list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd4090)

    if(MSVC_VERSION GREATER_EQUAL 1922)
      # see https://docs.microsoft.com/en-us/cpp/overview/cpp-conformance-improvements?view=vs-2019#improvements_162 for
      # detail
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd5054)
    endif()

    if(MSVC_VERSION GREATER_EQUAL 1925)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS /wd4996)
    endif()

    set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_REMOVE_OPTIONS /w44484 /w44485 /w45037 /we6001 /we6244 /we6246)
  else()
    unset(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS CACHE)
    set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-type-limits -Wno-sign-compare -Wno-sign-conversion
                                                           -Wno-shadow -Wno-uninitialized -Wno-conversion)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.9.0")
        list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-float-conversion)
      endif()
      if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "5.1.0")
        list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-suggest-override)
      endif()
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "3.5.0")
        list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-float-conversion)
      endif()
      if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "3.6.0")
        list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-inconsistent-missing-override)
      endif()
      if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "11.0")
        list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-suggest-override)
      endif()
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-suggest-override
           -Wno-inconsistent-missing-override -Wno-float-conversion)
    endif()
    set(PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_REMOVE_OPTIONS
        -Wunused-but-set-variable
        -Wtype-limits
        -Wsign-compare
        -Wsign-conversion
        -Wconversion
        -Wfloat-conversion
        -Wshadow
        -Wfloat-equal
        -Woverloaded-virtual
        -Wdelete-non-virtual-dtor
        -Wuninitialized
        -Wsuggest-override
        -Winconsistent-missing-override)
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag(-Wno-unused-parameter project_build_tools_patch_protobuf_sources_LINT_NO_UNUSED_PARAMETER)
    if(project_build_tools_patch_protobuf_sources_LINT_NO_UNUSED_PARAMETER)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-unused-parameter)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_REMOVE_OPTIONS -Wunused-parameter)
    endif()
    check_cxx_compiler_flag(-Wno-deprecated-declarations
                            project_build_tools_patch_protobuf_sources_LINT_NO_DEPRECATED_DECLARATIONS)
    if(project_build_tools_patch_protobuf_sources_LINT_NO_DEPRECATED_DECLARATIONS)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_OPTIONS -Wno-deprecated-declarations)
      list(APPEND PROJECT_BUILD_TOOLS_PATCH_PROTOBUF_SOURCES_REMOVE_OPTIONS -Wdeprecated-declarations)
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

function(project_build_tools_resolve_alias_target __OUTPUT_VAR_NAME __TARGET_NAME)
  if(NOT TARGET ${__TARGET_NAME})
    set(${__OUTPUT_VAR_NAME}
        ${__TARGET_NAME}
        PARENT_SCOPE)
  endif()

  get_target_property(IS_ALIAS_TARGET ${__TARGET_NAME} ALIASED_TARGET)
  if(IS_ALIAS_TARGET)
    project_build_tools_resolve_alias(${__OUTPUT_VAR_NAME} ${IS_ALIAS_TARGET})
    set(${__OUTPUT_VAR_NAME}
        ${${__OUTPUT_VAR_NAME}}
        PARENT_SCOPE)
  else()
    set(${__OUTPUT_VAR_NAME}
        ${__TARGET_NAME}
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_patch_imported_link_interface_libraries TARGET_NAME)
  set(optionArgs RESOLVE_ALIAS)
  set(multiValueArgs ADD_LIBRARIES REMOVE_LIBRARIES)
  cmake_parse_arguments(PATCH_OPTIONS "${optionArgs}" "" "${multiValueArgs}" ${ARGN})

  if(PATCH_OPTIONS_RESOLVE_ALIAS)
    project_build_tools_resolve_alias_target(TARGET_NAME ${TARGET_NAME})
  else()
    get_target_property(IS_ALIAS_TARGET ${TARGET_NAME} ALIASED_TARGET)
    if(IS_ALIAS_TARGET)
      return()
    endif()
  endif()
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
    if(OLD_IMPORTED_CONFIGURATIONS)
      list(GET OLD_IMPORTED_CONFIGURATIONS 0 OLD_IMPORTED_CONFIGURATION)
    endif()
    foreach(SELECT_CONFIGURATION ${OLD_IMPORTED_CONFIGURATIONS})
      if(SELECT_CONFIGURATION STREQUAL CMAKE_BUILD_TYPE)
        set(OLD_IMPORTED_CONFIGURATION "${SELECT_CONFIGURATION}")
        break()
      endif()
    endforeach()
    get_target_property(OLD_LINK_LIBRARIES ${TARGET_NAME}
                        "IMPORTED_LINK_INTERFACE_LIBRARIES_${OLD_IMPORTED_CONFIGURATION}")
    if(OLD_LINK_LIBRARIES)
      set(PROPERTY_NAME "IMPORTED_LINK_INTERFACE_LIBRARIES_${OLD_IMPORTED_CONFIGURATION}")
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
    if(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG)
      message(
        STATUS "Patch: ${PROPERTY_NAME} of ${TARGET_NAME} from \"${OLD_LINK_LIBRARIES}\" to \"${PATCH_INNER_LIBS}\"")
    endif()
  endif()
endfunction()

function(project_build_tools_patch_imported_interface_definitions TARGET_NAME)
  set(optionArgs RESOLVE_ALIAS)
  set(multiValueArgs ADD_DEFINITIONS REMOVE_DEFINITIONS)
  cmake_parse_arguments(PATCH_OPTIONS "${RESOLVE_ALIAS}" "" "${multiValueArgs}" ${ARGN})

  if(PATCH_OPTIONS_RESOLVE_ALIAS)
    project_build_tools_resolve_alias_target(TARGET_NAME ${TARGET_NAME})
  else()
    get_target_property(IS_ALIAS_TARGET ${TARGET_NAME} ALIASED_TARGET)
    if(IS_ALIAS_TARGET)
      return()
    endif()
  endif()
  get_target_property(OLD_DEFINITIONS ${TARGET_NAME} INTERFACE_COMPILE_DEFINITIONS)
  if(NOT OLD_DEFINITIONS)
    set(OLD_DEFINITIONS "") # Reset NOTFOUND
  endif()
  unset(PATCH_INNER_DEFINITIONS)
  if(OLD_DEFINITIONS AND PATCH_OPTIONS_REMOVE_DEFINITIONS)
    foreach(DEP_PATH IN LISTS OLD_DEFINITIONS)
      set(MATCH_ANY_RULES FALSE)
      foreach(MATCH_RULE IN LISTS PATCH_OPTIONS_REMOVE_DEFINITIONS)
        if(DEP_PATH MATCHES ${MATCH_RULE})
          set(MATCH_ANY_RULES TRUE)
          break()
        endif()
      endforeach()

      if(NOT MATCH_ANY_RULES)
        list(APPEND PATCH_INNER_DEFINITIONS ${DEP_PATH})
      endif()
    endforeach()
    if(PATCH_OPTIONS_ADD_DEFINITIONS)
      list(APPEND PATCH_INNER_DEFINITIONS ${PATCH_OPTIONS_ADD_DEFINITIONS})
    endif()
  elseif(OLD_DEFINITIONS)
    set(PATCH_INNER_DEFINITIONS ${OLD_DEFINITIONS})
    if(PATCH_OPTIONS_ADD_DEFINITIONS)
      list(APPEND PATCH_INNER_DEFINITIONS ${PATCH_OPTIONS_ADD_DEFINITIONS})
    endif()
  elseif(PATCH_OPTIONS_ADD_DEFINITIONS)
    set(PATCH_INNER_DEFINITIONS ${PATCH_OPTIONS_ADD_DEFINITIONS})
  else()
    set(PATCH_INNER_DEFINITIONS "")
  endif()

  if(PATCH_INNER_DEFINITIONS)
    list(REMOVE_DUPLICATES PATCH_INNER_DEFINITIONS)
  endif()

  if(NOT OLD_DEFINITIONS STREQUAL PATCH_INNER_DEFINITIONS)
    set_target_properties(${TARGET_NAME} PROPERTIES INTERFACE_COMPILE_DEFINITIONS "${PATCH_INNER_DEFINITIONS}")
    if(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG)
      message(
        STATUS
          "Patch: INTERFACE_COMPILE_DEFINITIONS of ${TARGET_NAME} from \"${OLD_DEFINITIONS}\" to \"${PATCH_INNER_DEFINITIONS}\""
      )
    endif()
  endif()
endfunction()

function(project_build_tools_get_imported_property OUTPUT_VAR_NAME TARGET_NAME VAR_NAME)
  project_build_tools_resolve_alias_target(TARGET_NAME ${TARGET_NAME})
  if(CMAKE_BUILD_TYPE)
    string(TOUPPER "${VAR_NAME}_${CMAKE_BUILD_TYPE}" TRY_SPECIFY_${VAR_NAME})
    get_target_property(${OUTPUT_VAR_NAME} ${TARGET_NAME} ${TRY_SPECIFY_${VAR_NAME}})
  endif()
  if(NOT ${OUTPUT_VAR_NAME})
    get_target_property(${OUTPUT_VAR_NAME} ${TARGET_NAME} ${VAR_NAME})
  endif()
  if(NOT ${OUTPUT_VAR_NAME})
    get_target_property(project_build_tools_get_imported_property_IMPORTED_CONFIGURATIONS ${TARGET_NAME}
                        IMPORTED_CONFIGURATIONS)
    foreach(project_build_tools_get_imported_property_IMPORTED_CONFIGURATION IN
            LISTS project_build_tools_get_imported_property_IMPORTED_CONFIGURATIONS)
      get_target_property(${OUTPUT_VAR_NAME} ${TARGET_NAME}
                          "${VAR_NAME}_${project_build_tools_get_imported_property_IMPORTED_CONFIGURATION}")
      if(${OUTPUT_VAR_NAME})
        break()
      endif()
    endforeach()
  endif()
  if(${OUTPUT_VAR_NAME})
    set(${OUTPUT_VAR_NAME}
        ${${OUTPUT_VAR_NAME}}
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_get_imported_location OUTPUT_VAR_NAME TARGET_NAME)
  project_build_tools_get_imported_property(OUTPUT_VAR_VALUE "${TARGET_NAME}" IMPORTED_LOCATION)
  if(OUTPUT_VAR_VALUE)
    set(${OUTPUT_VAR_NAME}
        ${OUTPUT_VAR_VALUE}
        PARENT_SCOPE)
  endif()
endfunction()

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
      get_target_property(IS_IMPORTED_TARGET ${TARGET_NAME} IMPORTED)
      if(NOT IS_IMPORTED_TARGET)
        continue()
      endif()

      get_target_property(IS_ALIAS_TARGET ${TARGET_NAME} ALIASED_TARGET)
      if(IS_ALIAS_TARGET)
        continue()
      endif()

      if(CMAKE_VERSION VERSION_LESS "3.19.0")
        get_target_property(TARGET_TYPE_NAME ${TARGET_NAME} TYPE)
        if(TARGET_TYPE_NAME STREQUAL "INTERFACE_LIBRARY")
          continue()
        endif()
      endif()

      get_target_property(DO_NOT_OVERWRITE ${TARGET_NAME} IMPORTED_LOCATION)
      if(DO_NOT_OVERWRITE)
        continue()
      endif()

      # MSVC's STL and debug level must match the target, so we can only move out IMPORTED_LOCATION_NOCONFIG
      if(MSVC)
        set(PATCH_IMPORTED_CONFIGURATION "NOCONFIG")
      else()
        get_target_property(PATCH_IMPORTED_CONFIGURATIONS ${TARGET_NAME} IMPORTED_CONFIGURATIONS)
        if(PATCH_IMPORTED_CONFIGURATIONS)
          list(GET PATCH_IMPORTED_CONFIGURATIONS 0 PATCH_IMPORTED_CONFIGURATION)
        endif()
        foreach(SELECT_CONFIGURATION ${PATCH_IMPORTED_CONFIGURATIONS})
          if(SELECT_CONFIGURATION STREQUAL CMAKE_BUILD_TYPE)
            set(PATCH_IMPORTED_CONFIGURATION "${SELECT_CONFIGURATION}")
            break()
          endif()
        endforeach()
      endif()

      if(NOT PATCH_IMPORTED_CONFIGURATION)
        continue()
      endif()

      get_target_property(PATCH_TARGET_LOCATION ${TARGET_NAME} "IMPORTED_LOCATION_${PATCH_IMPORTED_CONFIGURATION}")
      if(NOT PATCH_TARGET_LOCATION)
        continue()
      endif()

      foreach(PATCH_IMPORTED_KEY IN LISTS PATCH_VARS)
        get_target_property(PATCH_IMPORTED_VALUE ${TARGET_NAME} "${PATCH_IMPORTED_KEY}_${PATCH_IMPORTED_CONFIGURATION}")
        if(PATCH_IMPORTED_VALUE)
          set_target_properties(${TARGET_NAME} PROPERTIES "${PATCH_IMPORTED_KEY}" "${PATCH_IMPORTED_VALUE}")
          if(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG)
            message(
              STATUS
                "Patch: ${TARGET_NAME} ${PATCH_IMPORTED_KEY} use ${PATCH_IMPORTED_KEY}_${PATCH_IMPORTED_CONFIGURATION}(\"${PATCH_IMPORTED_VALUE}\") by default."
            )
          endif()
        endif()
      endforeach()
    endif()
  endforeach()
endfunction()

function(project_build_tools_sanitizer_use_static OUTPUT_VARNAME)
  if(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_ENABLE_SHARED_LINK)
    set(${OUTPUT_VARNAME}
        FALSE
        PARENT_SCOPE)
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_ENABLE_STATIC_LINK)
    set(${OUTPUT_VARNAME}
        TRUE
        PARENT_SCOPE)
  else()
    # GCC DSO implementation do not load sanitizer shared library automatically, so we use static link to support run
    # executable when building some packages. @see https://github.com/google/sanitizers/wiki/AddressSanitizerAsDso
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
      set(${OUTPUT_VARNAME}
          TRUE
          PARENT_SCOPE)
    else()
      set(${OUTPUT_VARNAME}
          FALSE
          PARENT_SCOPE)
    endif()
  endif()
endfunction()

function(project_build_tools_sanitizer_use_shared OUTPUT_VARNAME)
  if(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_ENABLE_SHARED_LINK)
    set(${OUTPUT_VARNAME}
        TRUE
        PARENT_SCOPE)
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_ENABLE_STATIC_LINK)
    set(${OUTPUT_VARNAME}
        FALSE
        PARENT_SCOPE)
  else()
    # GCC DSO implementation do not load sanitizer shared library automatically, so we use static link to support run
    # executable when building some packages. @see https://github.com/google/sanitizers/wiki/AddressSanitizerAsDso
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
      set(${OUTPUT_VARNAME}
          FALSE
          PARENT_SCOPE)
    else()
      set(${OUTPUT_VARNAME}
          TRUE
          PARENT_SCOPE)
    endif()
  endif()
endfunction()

function(project_build_tools_generate_load_env_bash OUTPUT_FILE)
  file(WRITE "${OUTPUT_FILE}" "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  project_make_executable("${OUTPUT_FILE}")

  file(APPEND "${OUTPUT_FILE}" "export CC=\"${CMAKE_C_COMPILER}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  file(APPEND "${OUTPUT_FILE}" "export CXX=\"${CMAKE_CXX_COMPILER}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  if(CMAKE_AR)
    file(APPEND "${OUTPUT_FILE}" "export AR=\"${CMAKE_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  elseif(CMAKE_CXX_COMPILER_AR)
    file(APPEND "${OUTPUT_FILE}" "export AR=\"${CMAKE_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  elseif(CMAKE_C_COMPILER_AR)
    file(APPEND "${OUTPUT_FILE}" "export AR=\"${CMAKE_C_COMPILER_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  unset(FINAL_CFLAGS)
  unset(FINAL_CXXFLAGS)
  add_compiler_flags_to_var(FINAL_CFLAGS ${COMPILER_OPTION_INHERIT_CMAKE_C_FLAGS})
  add_compiler_flags_to_var(FINAL_CXXFLAGS ${COMPILER_OPTION_INHERIT_CMAKE_CXX_FLAGS})
  if(CMAKE_OSX_ARCHITECTURES)
    if(CMAKE_CROSSCOMPILING AND CMAKE_OSX_SYSROOT)
      add_compiler_flags_to_var(FINAL_CFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
    endif()

    if(CMAKE_OSX_DEPLOYMENT_TARGET)
      add_compiler_flags_to_var(FINAL_CFLAGS "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()

    add_compiler_flags_to_var(FINAL_CFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
    add_compiler_flags_to_var(FINAL_CXXFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
  endif()

  if(FINAL_CFLAGS)
    file(APPEND "${OUTPUT_FILE}" "export CFLAGS=\"\$CFLAGS ${FINAL_CFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CFLAGS)

  if(FINAL_CXXFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "export CXXFLAGS=\"\$CXXFLAGS ${FINAL_CXXFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CXXFLAGS)

  if(ENV{RC})
    file(APPEND "${OUTPUT_FILE}" "export RC=\"$ENV{RC}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{RCFLAGS})
    file(APPEND "${OUTPUT_FILE}" "export RCFLAGS=\"$ENV{RCFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{LD})
    file(APPEND "${OUTPUT_FILE}" "export LD=\"$ENV{LD}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{AS})
    file(APPEND "${OUTPUT_FILE}" "export AS=\"$ENV{AS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  elseif(DEFINED CACHE{CMAKE_ASM_COMPILER})
    file(APPEND "${OUTPUT_FILE}" "export AS=\"${CMAKE_ASM_COMPILER}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{STRIP})
    file(APPEND "${OUTPUT_FILE}" "export STRIP=\"$ENV{STRIP}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{NM})
    file(APPEND "${OUTPUT_FILE}" "export NM=\"$ENV{NM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  if(COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS OR COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS_RELEASE)
    file(
      APPEND "${OUTPUT_FILE}"
      "export ASFLAGS=\"\$ASFLAGS ${COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS} ${COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS_RELEASE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()

  if(COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS
     OR COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS
     OR COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS)

    project_build_tools_sanitizer_use_static(SANITIZER_USE_STATIC_LINK)
    if(SANITIZER_USE_STATIC_LINK)
      project_build_tools_sanitizer_try_get_static_link(
        CHECK_SANITIZER_LINK_TYPE ${COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS}
        ${COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS} ${COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS})
    else()
      project_build_tools_sanitizer_try_get_shared_link(
        CHECK_SANITIZER_LINK_TYPE ${COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS}
        ${COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS} ${COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS})
    endif()

    unset(INHERIT_LDFLAGS_VALUE)
    project_build_tools_combine_space_flags_unique(
      INHERIT_LDFLAGS_VALUE COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS
      COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS
      CHECK_SANITIZER_LINK_TYPE)

    file(APPEND "${OUTPUT_FILE}"
         "export LDFLAGS=\"\$LDFLAGS ${INHERIT_LDFLAGS_VALUE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  if(CMAKE_RANLIB)
    file(APPEND "${OUTPUT_FILE}" "export RANLIB=\"${CMAKE_RANLIB}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_INSTALL_RPATH)
    set(RPATH_STRING_VALUE)
    set(RPATH_LINK_VALUE)
    foreach(RPATH_ITEM IN LISTS CMAKE_INSTALL_RPATH)
      string(REPLACE "$" "\\$" RPATH_ITEM_AS_VARIABLE "${RPATH_ITEM}")
      if(RPATH_STRING_VALUE)
        set(RPATH_STRING_VALUE
            "${RPATH_STRING_VALUE}${ATFRAMEWORK_CMAKE_TOOLSET_HOST_PATH_SEPARATOR}${RPATH_ITEM_AS_VARIABLE}")
      else()
        set(RPATH_STRING_VALUE "${RPATH_ITEM_AS_VARIABLE}")
      endif()
      if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android|iOS|Darwin")
        if(RPATH_LINK_VALUE)
          set(RPATH_LINK_VALUE
              "${RPATH_LINK_VALUE}${ATFRAMEWORK_CMAKE_TOOLSET_HOST_PATH_SEPARATOR}${RPATH_ITEM_AS_VARIABLE}")
        else()
          set(RPATH_LINK_VALUE "${RPATH_ITEM_AS_VARIABLE}")
        endif()
      endif()
    endforeach()

    file(APPEND "${OUTPUT_FILE}" "export RPATH=\"${RPATH_STRING_VALUE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
    if(RPATH_LINK_VALUE)
      file(APPEND "${OUTPUT_FILE}"
           "export LDFLAGS=\"\$LDFLAGS -Wl,-rpath,${RPATH_LINK_VALUE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(APPEND "${OUTPUT_FILE}" "export ORIGIN='\$ORIGIN'${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
    endif()
  endif()

  if(CMAKE_CROSSCOMPILING AND CMAKE_OSX_SYSROOT)
    file(APPEND "${OUTPUT_FILE}"
         "export OSX_SYSROOT=\"${CMAKE_OSX_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_OSX_ARCHITECTURES)
    file(APPEND "${OUTPUT_FILE}"
         "export OSX_ARCHITECTURES=\"${CMAKE_OSX_ARCHITECTURES}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ANDROID)
    file(
      APPEND "${OUTPUT_FILE}"
      "export ANDROID_NDK=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_NDK_HOME=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_NDK_ROOT=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "export ANDROID_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
      # ANDROID_NDK_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_PLATFORM=\"${ANDROID_PLATFORM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_ABI=\"${ANDROID_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "export ANDROID_SYSROOT_ABI=\"${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}" "export
      # ANDROID_TOOLCHAIN_NAME=\"${ANDROID_TOOLCHAIN_NAME}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_TOOLCHAIN_ROOT=\"${ANDROID_TOOLCHAIN_ROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "export ANDROID_TOOLCHAIN_PREFIX=\"${ANDROID_TOOLCHAIN_PREFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export ANDROID_USE_LEGACY_TOOLCHAIN_FILE=\"${ANDROID_USE_LEGACY_TOOLCHAIN_FILE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "export PATH=\"${ANDROID_TOOLCHAIN_ROOT}/bin:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")

    # For legacy android-ndk-r16
    if(ANDROID_SYSTEM_LIBRARY_PATH)
      file(
        APPEND "${OUTPUT_FILE}"
        "export ANDROID_SYSTEM_LIBRARY_PATH=\"${ANDROID_SYSTEM_LIBRARY_PATH}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      )
    endif()
    # For android-ndk-r23
  endif()
endfunction()

function(project_build_tool_generate_load_env_powershell OUTPUT_FILE)
  file(WRITE "${OUTPUT_FILE}" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  project_make_executable("${OUTPUT_FILE}")

  file(APPEND "${OUTPUT_FILE}"
       "$PSDefaultParameterValues['*:Encoding'] = 'UTF-8'${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  file(APPEND "${OUTPUT_FILE}"
       "$OutputEncoding = [System.Text.UTF8Encoding]::new()${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  if(CMAKE_AR)
    file(APPEND "${OUTPUT_FILE}" "$ENV:AR=\"${CMAKE_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  elseif(CMAKE_CXX_COMPILER_AR)
    file(APPEND "${OUTPUT_FILE}" "$ENV:AR=\"${CMAKE_CXX_COMPILER_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  elseif(CMAKE_C_COMPILER_AR)
    file(APPEND "${OUTPUT_FILE}" "$ENV:AR=\"${CMAKE_C_COMPILER_AR}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  unset(FINAL_CFLAGS)
  unset(FINAL_CXXFLAGS)
  add_compiler_flags_to_var(FINAL_CFLAGS ${COMPILER_OPTION_INHERIT_CMAKE_C_FLAGS})
  add_compiler_flags_to_var(FINAL_CXXFLAGS ${COMPILER_OPTION_INHERIT_CMAKE_CXX_FLAGS})
  if(ANDROID)
    # No need to patch anymore
  else()
    if(CMAKE_CROSSCOMPILING AND CMAKE_OSX_SYSROOT)
      add_compiler_flags_to_var(FINAL_CFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-isysroot" "${CMAKE_OSX_SYSROOT}")
    endif()

    if(CMAKE_OSX_DEPLOYMENT_TARGET)
      add_compiler_flags_to_var(FINAL_CFLAGS "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-miphoneos-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()

    if(CMAKE_OSX_ARCHITECTURES)
      add_compiler_flags_to_var(FINAL_CFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
      add_compiler_flags_to_var(FINAL_CXXFLAGS "-arch ${CMAKE_OSX_ARCHITECTURES}")
    endif()
  endif()

  if(FINAL_CFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:CFLAGS=\"\$ENV:CFLAGS ${FINAL_CFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CFLAGS)

  if(FINAL_CXXFLAGS)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:CXXFLAGS=\"\$ENV:CXXFLAGS ${FINAL_CXXFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  unset(FINAL_CXXFLAGS)

  if(ENV{RC})
    file(APPEND "${OUTPUT_FILE}" "$ENV:RC=\"$ENV{RC}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{RCFLAGS})
    file(APPEND "${OUTPUT_FILE}" "$ENV:RCFLAGS=\"$ENV{RCFLAGS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{LD})
    file(APPEND "${OUTPUT_FILE}" "$ENV:LD=\"$ENV{LD}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{AS})
    file(APPEND "${OUTPUT_FILE}" "$ENV:AS=\"$ENV{AS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  elseif(DEFINED CACHE{CMAKE_ASM_COMPILER})
    file(APPEND "${OUTPUT_FILE}" "$ENV:AS=\"$ENV{CMAKE_ASM_COMPILER}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{STRIP})
    file(APPEND "${OUTPUT_FILE}" "$ENV:STRIP=\"$ENV{STRIP}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ENV{NM})
    file(APPEND "${OUTPUT_FILE}" "$ENV:NM=\"$ENV{NM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  if(COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS OR COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS_RELEASE)
    file(
      APPEND "${OUTPUT_FILE}"
      "$ENV:ASFLAGS=\"\$ENV:ASFLAGS ${COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS} ${COMPILER_OPTION_INHERIT_CMAKE_ASM_FLAGS_RELEASE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )
  endif()

  if(COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS
     OR COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS
     OR COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS)

    project_build_tools_sanitizer_use_static(SANITIZER_USE_STATIC_LINK)
    if(SANITIZER_USE_STATIC_LINK)
      project_build_tools_sanitizer_try_get_static_link(
        CHECK_SANITIZER_LINK_TYPE ${COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS}
        ${COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS} ${COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS})
    else()
      project_build_tools_sanitizer_try_get_shared_link(
        CHECK_SANITIZER_LINK_TYPE ${COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS}
        ${COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS} ${COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS})
    endif()

    unset(INHERIT_LDFLAGS_VALUE)
    project_build_tools_combine_space_flags_unique(
      INHERIT_LDFLAGS_VALUE COMPILER_OPTION_INHERIT_CMAKE_EXE_LINKER_FLAGS
      COMPILER_OPTION_INHERIT_CMAKE_SHARED_LINKER_FLAGS COMPILER_OPTION_INHERIT_CMAKE_STATIC_LINKER_FLAGS
      CHECK_SANITIZER_LINK_TYPE)

    file(APPEND "${OUTPUT_FILE}"
         "$ENV:LDFLAGS=\"\$ENV:LDFLAGS ${INHERIT_LDFLAGS_VALUE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()

  if(CMAKE_RANLIB)
    file(APPEND "${OUTPUT_FILE}" "$ENV:RANLIB=\"${CMAKE_RANLIB}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_INSTALL_RPATH)
    set(RPATH_STRING_VALUE)
    set(RPATH_LINK_VALUE)
    foreach(RPATH_ITEM IN LISTS CMAKE_INSTALL_RPATH)
      string(REPLACE "$" "`$" RPATH_ITEM_AS_VARIABLE "${RPATH_ITEM}")
      if(RPATH_STRING_VALUE)
        set(RPATH_STRING_VALUE
            "${RPATH_STRING_VALUE}${ATFRAMEWORK_CMAKE_TOOLSET_HOST_PATH_SEPARATOR}${RPATH_ITEM_AS_VARIABLE}")
      else()
        set(RPATH_STRING_VALUE "${RPATH_ITEM_AS_VARIABLE}")
      endif()
      if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android|iOS|Darwin")
        if(RPATH_LINK_VALUE)
          set(RPATH_LINK_VALUE
              "${RPATH_LINK_VALUE}${ATFRAMEWORK_CMAKE_TOOLSET_HOST_PATH_SEPARATOR}${RPATH_ITEM_AS_VARIABLE}")
        else()
          set(RPATH_LINK_VALUE "${RPATH_ITEM_AS_VARIABLE}")
        endif()
      endif()
    endforeach()
    file(APPEND "${OUTPUT_FILE}" "$ENV:RPATH=\"${RPATH_STRING_VALUE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
    if(RPATH_LINK_VALUE)
      file(APPEND "${OUTPUT_FILE}"
           "$ENV:LDFLAGS=\"\$ENV:LDFLAGS -Wl,-rpath,${RPATH_LINK_VALUE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      file(APPEND "${OUTPUT_FILE}" "$ENV:ORIGIN='\$ORIGIN'${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
    endif()
  endif()
  if(CMAKE_CROSSCOMPILING AND CMAKE_OSX_SYSROOT)
    file(APPEND "${OUTPUT_FILE}" "$ENV:OSX_SYSROOT=\"${CMAKE_OSX_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(CMAKE_OSX_ARCHITECTURES)
    file(APPEND "${OUTPUT_FILE}"
         "$ENV:OSX_ARCHITECTURES=\"${CMAKE_OSX_ARCHITECTURES}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
  endif()
  if(ANDROID)
    file(
      APPEND "${OUTPUT_FILE}"
      "$ENV:ANDROID_NDK=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_NDK_HOME=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_NDK_ROOT=\"${ANDROID_NDK}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "$ENV:ANDROID_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "$ENV:ANDROID_NDK_SYSROOT=\"${ANDROID_SYSROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_PLATFORM=\"${ANDROID_PLATFORM}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_ABI=\"${ANDROID_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "$ENV:ANDROID_SYSROOT_ABI=\"${ANDROID_SYSROOT_ABI}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "$ENV:ANDROID_TOOLCHAIN_NAME=\"${ANDROID_TOOLCHAIN_NAME}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_TOOLCHAIN_ROOT=\"${ANDROID_TOOLCHAIN_ROOT}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      # "$ENV:ANDROID_TOOLCHAIN_PREFIX=\"${ANDROID_TOOLCHAIN_PREFIX}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:ANDROID_USE_LEGACY_TOOLCHAIN_FILE=\"${ANDROID_USE_LEGACY_TOOLCHAIN_FILE}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
      "$ENV:PATH=\"${ANDROID_TOOLCHAIN_ROOT}/bin\" + [IO.Path]::PathSeparator + \"\$ENV:PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
    )

    # For legacy android-ndk-r16
    if(ANDROID_SYSTEM_LIBRARY_PATH)
      file(
        APPEND "${OUTPUT_FILE}"
        "$ENV:ANDROID_SYSTEM_LIBRARY_PATH=\"${ANDROID_SYSTEM_LIBRARY_PATH}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
    endif()
    # For android-ndk-r23
  endif()
endfunction()

function(project_build_tools_copy_directory_if_different DESTINATION SOURCE_DIR)
  cmake_parse_arguments(project_build_tools_copy_directory_if_different "" "OUTPUT_CMAKE_COMMAND" "FILES" ${ARGN})
  set(COPY_FILES ${project_build_tools_copy_directory_if_different_FILES})
  list(SORT COPY_FILES)
  set(LAST_CREATED_DIR ".")
  unset(FINAL_GENERATED_COPY_COMMANDS)
  foreach(FILE_PATH ${COPY_FILES})
    file(RELATIVE_PATH RELATIVE_FILE_PATH "${SOURCE_DIR}" "${FILE_PATH}")
    get_filename_component(FINAL_DESTINATION_DIR "${DESTINATION}/${RELATIVE_FILE_PATH}" DIRECTORY)
    if(NOT LAST_CREATED_DIR STREQUAL FINAL_DESTINATION_DIR)
      if(NOT EXISTS "${FINAL_DESTINATION_DIR}")
        file(MAKE_DIRECTORY "${FINAL_DESTINATION_DIR}")
      endif()
      set(LAST_CREATED_DIR "${FINAL_DESTINATION_DIR}")

      if(FINAL_GENERATED_COPY_COMMANDS)
        list(APPEND FINAL_GENERATED_COPY_COMMANDS "${LAST_CREATED_DIR}")
      endif()
      list(
        APPEND
        FINAL_GENERATED_COPY_COMMANDS
        "COMMAND"
        "${CMAKE_COMMAND}"
        "-E"
        "copy_if_different"
        "${FILE_PATH}")
    else()
      list(APPEND FINAL_GENERATED_COPY_COMMANDS "${FILE_PATH}")
    endif()
    if(FINAL_GENERATED_COPY_COMMANDS)
      list(APPEND FINAL_GENERATED_COPY_COMMANDS "${LAST_CREATED_DIR}")

      if(project_build_tools_copy_directory_if_different_OUTPUT_CMAKE_COMMAND)
        set(${project_build_tools_copy_directory_if_different_OUTPUT_CMAKE_COMMAND}
            ${FINAL_GENERATED_COPY_COMMANDS}
            PARENT_SCOPE)
      else()
        execute_process(${FINAL_GENERATED_COPY_COMMANDS} ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
    endif()
  endforeach()
endfunction()

function(project_build_tools_set_export_declaration OUTPUT_VARNAME)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang|Intel|XL|XLClang")
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
      set(${OUTPUT_VARNAME}
          "__attribute__((__dllexport__))"
          PARENT_SCOPE)
    else()
      set(${OUTPUT_VARNAME}
          "__attribute__((visibility(\"default\")))"
          PARENT_SCOPE)
    endif()
  elseif(MSVC)
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
      set(${OUTPUT_VARNAME}
          "__declspec(dllexport)"
          PARENT_SCOPE)
    else()
      set(${OUTPUT_VARNAME}
          ""
          PARENT_SCOPE)
    endif()
  elseif(SunPro)
    set(${OUTPUT_VARNAME}
        "__global"
        PARENT_SCOPE)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(${OUTPUT_VARNAME}
        "__declspec(dllexport)"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VARNAME}
        ""
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_set_import_declaration OUTPUT_VARNAME)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang|Intel|XL|XLClang")
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
      set(${OUTPUT_VARNAME}
          "__attribute__((__dllimport__))"
          PARENT_SCOPE)
    else()
      set(${OUTPUT_VARNAME}
          ""
          PARENT_SCOPE)
    endif()
  elseif(MSVC)
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
      set(${OUTPUT_VARNAME}
          "__declspec(dllimport)"
          PARENT_SCOPE)
    else()
      set(${OUTPUT_VARNAME}
          ""
          PARENT_SCOPE)
    endif()
  elseif(SunPro)
    set(${OUTPUT_VARNAME}
        "__global"
        PARENT_SCOPE)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(${OUTPUT_VARNAME}
        "__declspec(dllimport)"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VARNAME}
        ""
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_set_shared_library_declaration DEFINITION_VARNAME)
  project_build_tools_set_export_declaration(EXPORT_DECLARATION)
  project_build_tools_set_import_declaration(IMPORT_DECLARATION)
  foreach(TARGET_NAME ${ARGN})
    target_compile_definitions(${TARGET_NAME} INTERFACE "${DEFINITION_VARNAME}=${IMPORT_DECLARATION}")
    target_compile_definitions(${TARGET_NAME} PRIVATE "${DEFINITION_VARNAME}=${EXPORT_DECLARATION}")
  endforeach()
endfunction()

function(project_build_tools_set_static_library_declaration DEFINITION_VARNAME)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang|Intel|XL|XLClang")
    foreach(TARGET_NAME ${ARGN})
      target_compile_definitions(${TARGET_NAME} PUBLIC "${DEFINITION_VARNAME}=__attribute__((visibility(\"default\")))")
    endforeach()
  else()
    foreach(TARGET_NAME ${ARGN})
      target_compile_definitions(${TARGET_NAME} PUBLIC "${DEFINITION_VARNAME}=")
    endforeach()
  endif()
endfunction()

function(project_build_tools_set_library_visibility_hidden)
  if(NOT APPLE)
    foreach(TARGET_NAME ${ARGN})
      set_target_properties("${TARGET_NAME}" PROPERTIES C_VISIBILITY_PRESET "hidden" CXX_VISIBILITY_PRESET "hidden")
    endforeach()
  endif()
endfunction()

function(project_build_tools_set_native_export_declaration NATIVE_DEFINITION_VARNAME DLL_DEFINITION_VARNAME)
  if(DLL_DEFINITION_VARNAME)
    foreach(TARGET_NAME ${ARGN})
      target_compile_definitions(${TARGET_NAME} PRIVATE "${NATIVE_DEFINITION_VARNAME}=1" "${DLL_DEFINITION_VARNAME}=1")
    endforeach()
  else()
    foreach(TARGET_NAME ${ARGN})
      target_compile_definitions(${TARGET_NAME} PRIVATE "${NATIVE_DEFINITION_VARNAME}=1")
    endforeach()
  endif()
endfunction()

function(project_build_tools_get_origin_rpath OUTVAR)
  unset(ORIGIN_RPATHS)
  if(UNIX AND NOT APPLE)
    foreach(RELPATH ${ARGN})
      if(RELPATH STREQUAL ".")
        list(APPEND ORIGIN_RPATHS "$ORIGIN")
      else()
        list(APPEND ORIGIN_RPATHS "$ORIGIN/${RELPATH}")
      endif()
    endforeach()
  elseif(APPLE)
    foreach(RELPATH ${ARGN})
      if(RELPATH STREQUAL ".")
        # list(APPEND ORIGIN_RPATHS "@loader_path")
        list(APPEND ORIGIN_RPATHS "@rpath")
      else()
        # list(APPEND ORIGIN_RPATHS "@loader_path/${RELPATH}")
        list(APPEND ORIGIN_RPATHS "@rpath/${RELPATH}")
      endif()
    endforeach()
  endif()
  set(${OUTVAR}
      ${ORIGIN_RPATHS}
      PARENT_SCOPE)
endfunction()

function(project_build_tools_set_global_install_rpath_origin)
  project_build_tools_get_origin_rpath(ORIGIN_RPATHS ${ARGN})
  set(CMAKE_INSTALL_RPATH ${ORIGIN_RPATHS})
endfunction()

function(project_build_tools_set_global_build_rpath_origin)
  project_build_tools_get_origin_rpath(ORIGIN_RPATHS ${ARGN})
  set(CMAKE_BUILD_RPATH_USE_ORIGIN TRUE)
  set(CMAKE_BUILD_RPATH ${ORIGIN_RPATHS})
endfunction()

macro(project_build_tools_auto_append_postfix OUTVAR)
  if(WIN32
     OR MINGW
     OR CYGWIN)
    if(NOT CMAKE_BUILD_TYPE OR NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND ${OUTVAR} "-DCMAKE_DEBUG_POSTFIX=-dbg")
    endif()
    if(NOT CMAKE_BUILD_TYPE OR NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
      list(APPEND ${OUTVAR} "-DCMAKE_RELWITHDEBINFO_POSTFIX=-reldbg")
    endif()
    if(CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
      list(APPEND ${OUTVAR} "-DCMAKE_RELEASE_POSTFIX=-rel")
    endif()
  endif()
endmacro()

function(project_build_tools_auto_set_target_postfix)
  if(WIN32
     OR MINGW
     OR CYGWIN)
    unset(POSTFIX_PROPERTIES)
    if(NOT CMAKE_BUILD_TYPE OR NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND POSTFIX_PROPERTIES "DEBUG_POSTFIX" "-dbg")
    endif()
    if(NOT CMAKE_BUILD_TYPE OR NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
      list(APPEND POSTFIX_PROPERTIES "RELWITHDEBINFO_POSTFIX" "-reldbg")
    endif()
    if(CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
      list(APPEND POSTFIX_PROPERTIES "RELEASE_POSTFIX" "-rel")
    endif()
    set_target_properties(${ARGN} PROPERTIES ${POSTFIX_PROPERTIES})
  endif()
endfunction()

function(project_build_tools_print_configure_log)
  foreach(DIRNAME ${ARGN})
    if(EXISTS "${DIRNAME}/CMakeFiles/CMakeConfigureLog.yaml")
      file(READ "${DIRNAME}/CMakeFiles/CMakeConfigureLog.yaml" LOG_CONTENT)
      message(
        STATUS
          "============ ${DIRNAME}/CMakeFiles/CMakeConfigureLog.yaml ============${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${LOG_CONTENT}"
      )
    endif()

    if(EXISTS "${DIRNAME}/CMakeFiles/CMakeOutput.log")
      unset(LOG_CONTENT)
      file(READ "${DIRNAME}/CMakeFiles/CMakeOutput.log" LOG_CONTENT)
      message(
        STATUS
          "============ ${DIRNAME}/CMakeFiles/CMakeOutput.log ============${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${LOG_CONTENT}"
      )
    endif()

    if(EXISTS "${DIRNAME}/CMakeFiles/CMakeError.log")
      unset(LOG_CONTENT)
      file(READ "${DIRNAME}/CMakeFiles/CMakeError.log" LOG_CONTENT)
      message(
        STATUS
          "============ ${DIRNAME}/CMakeFiles/CMakeError.log ============${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${LOG_CONTENT}"
      )
    endif()

    if(EXISTS "${DIRNAME}/config.log")
      unset(LOG_CONTENT)
      file(READ "${DIRNAME}/config.log" LOG_CONTENT)
      message(
        STATUS "============ ${DIRNAME}/config.log ============${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}${LOG_CONTENT}"
      )
    endif()
  endforeach()
endfunction()

macro(atframework_cmake_toolset_find_bash_tools)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_BASH bash)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_BASH)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_CP cp)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_CP)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_GZIP gzip)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_GZIP)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_MV mv)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_MV)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_RM rm)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_RM)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_TAR NAMES tar gtar)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_TAR)

  if(ATFRAMEWORK_CMAKE_TOOLSET_BASH)
    message(STATUS "cmake-toolset: ATFRAMEWORK_CMAKE_TOOLSET_BASH=${ATFRAMEWORK_CMAKE_TOOLSET_BASH}")
  endif()
endmacro()

macro(atframework_cmake_toolset_find_pwsh_tools)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_PWSH NAMES pwsh pwsh.exe pwsh-preview pwsh-preview.exe)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)

  if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
    message(STATUS "cmake-toolset: ATFRAMEWORK_CMAKE_TOOLSET_PWSH=${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}")
  endif()
endmacro()

macro(
  project_build_tools_add_archive_library_internal
  TARGET_NAME
  WITH_DEPENDENCIES
  TARGET_MERGE_ARCHIVES
  TARGET_MERGE_LINK_LIBRARIES_VAR
  TARGET_MERGE_INCLUDE_DIRECTORIES_VAR
  TARGET_MERGE_COMPILE_DEFINITIONS_VAR
  LINK_LIBRARY_NAMES
  INCLUDE_RULE
  EXCLUDE_RULE)

  if(_add_archive_library_DEEP)
    math(EXPR _add_archive_library_DEEP "${_add_archive_library_DEEP}+1")
  else()
    set(_add_archive_library_DEEP 1)
  endif()
  set(_add_archive_library_LINK_LIBRARY_PATHS_${_add_archive_library_DEEP})
  foreach(DEP_LINK_NAME ${LINK_LIBRARY_NAMES})
    if(NOT DEP_LINK_NAME)
      continue()
    endif()

    # skip debug, optimized, general keywords
    if(DEP_LINK_NAME MATCHES "^(debug|optimized|general)$")
      continue()
    endif()

    if(DEP_LINK_NAME MATCHES "^\\$<LINK_ONLY:(.*)>$")
      set(DEP_LINK_NAME "${CMAKE_MATCH_1}")
    endif()

    if(NOT TARGET "${DEP_LINK_NAME}")
      list(APPEND _add_archive_library_LINK_LIBRARY_PATHS_${_add_archive_library_DEEP} "${DEP_LINK_NAME}")
      continue()
    endif()

    get_target_property(DEP_LINK_ALIASED_NAME "${DEP_LINK_NAME}" ALIASED_TARGET)
    if(DEP_LINK_ALIASED_NAME AND TARGET "${DEP_LINK_ALIASED_NAME}")
      set(DEP_LINK_NAME "${DEP_LINK_ALIASED_NAME}")
    endif()

    if(DEFINED "_add_archive_library_internal_LINK_${TARGET_NAME}_${DEP_LINK_NAME}")
      continue()
    endif()
    set("_add_archive_library_internal_LINK_${TARGET_NAME}_${DEP_LINK_NAME}" TRUE)

    set(DEP_TARGET_DEFINITIONS)
    get_target_property(DEP_TARGET_DEFINITIONS "${DEP_LINK_NAME}" INTERFACE_COMPILE_DEFINITIONS)
    if(DEP_TARGET_DEFINITIONS)
      list(APPEND ${TARGET_MERGE_COMPILE_DEFINITIONS_VAR} ${DEP_TARGET_DEFINITIONS})
    endif()

    set(DEP_TARGET_DEFINITIONS)
    get_target_property(DEP_TARGET_INCLUDE_DIRECTORIES "${DEP_LINK_NAME}" INTERFACE_INCLUDE_DIRECTORIES)
    if(DEP_TARGET_INCLUDE_DIRECTORIES)
      list(APPEND ${TARGET_MERGE_INCLUDE_DIRECTORIES_VAR} ${DEP_TARGET_INCLUDE_DIRECTORIES})
    endif()

    set(DEP_TARGET_NEED_DEPENDENCIES ${WITH_DEPENDENCIES})
    if(DEP_TARGET_NEED_DEPENDENCIES)
      set(DEP_TARGET_LINK_DEPENDS)
      set(DEP_TARGET_LINK_LIBRARIES)
      get_target_property(DEP_TARGET_LINK_DEPENDS "${DEP_LINK_NAME}" INTERFACE_LINK_DEPENDS)
      get_target_property(DEP_TARGET_LINK_LIBRARIES "${DEP_LINK_NAME}" INTERFACE_LINK_LIBRARIES)
      if(DEP_TARGET_LINK_DEPENDS OR DEP_TARGET_LINK_LIBRARIES)
        set(DEP_TARGET_LINK_NAMES)
        foreach(DEP_TARGET_LINK_NAME ${DEP_TARGET_LINK_DEPENDS} ${DEP_TARGET_LINK_LIBRARIES})
          if(NOT DEP_TARGET_LINK_NAME MATCHES "^$<")
            list(APPEND DEP_TARGET_LINK_NAMES "${DEP_TARGET_LINK_NAME}")
          endif()
        endforeach()

        if(DEP_TARGET_LINK_NAMES)
          project_build_tools_add_archive_library_internal(
            "${TARGET_NAME}"
            ${WITH_DEPENDENCIES}
            "${TARGET_MERGE_ARCHIVES}"
            "${TARGET_MERGE_LINK_LIBRARIES_VAR}"
            "${TARGET_MERGE_INCLUDE_DIRECTORIES_VAR}"
            "${TARGET_MERGE_COMPILE_DEFINITIONS_VAR}"
            "${DEP_TARGET_LINK_NAMES}"
            "${INCLUDE_RULE}"
            "${EXCLUDE_RULE}")
        endif()
      endif()
    endif()

    set(DEP_TARGET_IS_IMPORTED)
    set(DEP_TARGET_TYPE)
    get_target_property(DEP_TARGET_IS_IMPORTED "${DEP_LINK_NAME}" IMPORTED)
    get_target_property(DEP_TARGET_TYPE "${DEP_LINK_NAME}" TYPE)
    if(DEP_TARGET_IS_IMPORTED)
      get_target_property(DEP_TARGET_IMPORTED_CONFIGURES "${DEP_LINK_NAME}" IMPORTED_CONFIGURATIONS)
      if(DEP_TARGET_IMPORTED_CONFIGURES)
        list(GET DEP_TARGET_IMPORTED_CONFIGURES 0 DEP_TARGET_IMPORTED_CONFIGURE)
      endif()
      foreach(SELECT_CONFIGURATION ${DEP_TARGET_IMPORTED_CONFIGURES})
        if(SELECT_CONFIGURATION STREQUAL CMAKE_BUILD_TYPE)
          set(DEP_TARGET_IMPORTED_CONFIGURE "${SELECT_CONFIGURATION}")
          break()
        endif()
      endforeach()
      set(DEP_TARGET_IMPORTED_LOCATION)
      if(DEP_TARGET_IMPORTED_CONFIGURE)
        get_target_property(DEP_TARGET_IMPORTED_LOCATION "${DEP_LINK_NAME}"
                            IMPORTED_LOCATION_${DEP_TARGET_IMPORTED_CONFIGURE})
      endif()
      if(NOT DEP_TARGET_IMPORTED_LOCATION)
        get_target_property(DEP_TARGET_IMPORTED_LOCATION "${DEP_LINK_NAME}" IMPORTED_LOCATION)
      endif()
      if(DEP_TARGET_IMPORTED_LOCATION)
        list(APPEND _add_archive_library_LINK_LIBRARY_PATHS_${_add_archive_library_DEEP}
             "${DEP_TARGET_IMPORTED_LOCATION}")
      endif()
    elseif(DEP_TARGET_TYPE STREQUAL "STATIC_LIBRARY")
      list(APPEND _add_archive_library_LINK_LIBRARY_PATHS_${_add_archive_library_DEEP}
           "$<TARGET_FILE:${DEP_LINK_NAME}>")
    endif()
  endforeach()

  foreach(DEP_LINK_NAME ${_add_archive_library_LINK_LIBRARY_PATHS_${_add_archive_library_DEEP}})
    get_filename_component(DEP_LINK_NAME_BASENAME "${DEP_LINK_NAME}" NAME)
    string(REPLACE "." "\\." DEP_LINK_LIBRARY_PREFIX "${CMAKE_STATIC_LIBRARY_PREFIX}")
    string(REPLACE "." "\\." DEP_LINK_LIBRARY_SUFFIX "${CMAKE_STATIC_LIBRARY_SUFFIX}")

    # Target file is always included
    if(DEP_LINK_NAME_BASENAME MATCHES "^\\$<TARGET_FILE:(.*)>")
      set(DEP_LINK_NAME_SELECT TRUE)
      set(DEP_LINK_NAME_IS_TARGET TRUE)
    elseif(DEP_LINK_NAME_BASENAME MATCHES "^\\$<")
      # Ignore $<LINK_ONLY:...> because it can not be evaluated
      set(DEP_LINK_NAME_SELECT FALSE)
      set(DEP_LINK_NAME_IS_TARGET FALSE)
    else()
      set(DEP_LINK_NAME_SELECT TRUE)
      set(DEP_LINK_NAME_IS_TARGET FALSE)

      if(NOT DEP_LINK_NAME_BASENAME MATCHES "^${DEP_LINK_LIBRARY_PREFIX}.*${DEP_LINK_LIBRARY_SUFFIX}$")
        set(DEP_LINK_NAME_SELECT FALSE)
      endif()

      if(DEP_LINK_NAME_SELECT AND NOT EXISTS "${DEP_LINK_NAME}")
        set(DEP_LINK_NAME_SELECT FALSE)
      endif()

      if(DEP_LINK_NAME_SELECT AND NOT "${INCLUDE_RULE}" STREQUAL "")
        set(DEL_LINK_NAME_INC_RULE FALSE)
        foreach(RULE ${INCLUDE_RULE})
          if(DEP_LINK_NAME_BASENAME MATCHES "${RULE}")
            set(DEL_LINK_NAME_INC_RULE TRUE)
            break()
          endif()
        endforeach()
        set(DEP_LINK_NAME_SELECT ${DEL_LINK_NAME_INC_RULE})
      endif()

      if(DEP_LINK_NAME_SELECT AND NOT "${EXCLUDE_RULE}" STREQUAL "")
        foreach(RULE ${EXCLUDE_RULE})
          if(DEP_LINK_NAME_BASENAME MATCHES "${RULE}")
            set(DEP_LINK_NAME_SELECT FALSE)
            break()
          endif()
        endforeach()
      endif()
    endif()

    if(DEP_LINK_NAME_SELECT)
      if(DEP_LINK_NAME_IS_TARGET)
        list(APPEND TARGET_MERGE_ARCHIVES "${DEP_LINK_NAME}")
      elseif(IS_ABSOLUTE "${DEP_LINK_NAME}")
        list(APPEND TARGET_MERGE_ARCHIVES "${DEP_LINK_NAME}")
      else()
        list(APPEND TARGET_MERGE_ARCHIVES "${CMAKE_CURRENT_BINARY_DIR}/${DEP_LINK_NAME}")
      endif()
    else()
      list(APPEND ${TARGET_MERGE_LINK_LIBRARIES_VAR} "${DEP_LINK_NAME}")
    endif()
  endforeach()

  math(EXPR _add_archive_library_DEEP "${_add_archive_library_DEEP}-1")
endmacro()

function(project_build_tools_add_archive_library TARGET_NAME)
  if(CMAKE_INTERPROCEDURAL_OPTIMIZATION OR CMAKE_INTERPROCEDURAL_OPTIMIZATION_${CMAKE_BUILD_TYPE})
    if(CMAKE_CXX_COMPILER_AR)
      set(AR_TOOL_BIN "${CMAKE_CXX_COMPILER_AR}")
    elseif(CMAKE_C_COMPILER_AR)
      set(AR_TOOL_BIN "${CMAKE_C_COMPILER_AR}")
    endif()
  endif()
  if(NOT AR_TOOL_BIN)
    if(CMAKE_AR)
      set(AR_TOOL_BIN "${CMAKE_AR}")
    elseif(CMAKE_CXX_COMPILER_AR)
      set(AR_TOOL_BIN "${CMAKE_CXX_COMPILER_AR}")
    elseif(CMAKE_C_COMPILER_AR)
      set(AR_TOOL_BIN "${CMAKE_C_COMPILER_AR}")
    else()
      if(WIN32)
        find_program(AR_TOOL_BIN NAMES lib lib.exe)
      endif()
      if(NOT AR_TOOL_BIN)
        message(FATAL_ERROR "Can not find ar or lib.exe, we do not support archive static for this platform now")
      endif()
    endif()
  endif()

  cmake_parse_arguments(
    add_archive_options
    "ALL;MERGE_COMPILE_DEFINITIONS;MERGE_INCLUDE_DIRECTORIES;MERGE_LINK_LIBRARIES;WITH_DEPENDENCIES"
    "OUTPUT_NAME;INSTALL_DESTINATION;OUTPUT_NAME_VARIABLE;OUTPUT_PATH_VARIABLE"
    "LINK_LIBRARIES;INCLUDE;EXCLUDE;REMOVE_OBJECTS"
    ${ARGN})

  if(CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
    set(OUTPUT_DIR "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
  elseif(LIBRARY_OUTPUT_PATH)
    set(OUTPUT_DIR "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
  else()
    set(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
  endif()
  if(add_archive_options_OUTPUT_NAME)
    set(OUTPUT_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}${add_archive_options_OUTPUT_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
  else()
    set(OUTPUT_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}${TARGET_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
  endif()
  set(OUTPUT_PATH "${OUTPUT_DIR}/${OUTPUT_NAME}")
  set(TARGET_WORK_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir")
  file(MAKE_DIRECTORY "${TARGET_WORK_DIR}")

  set(TARGET_OPTIONS)
  set(TARGET_MERGE_ARCHIVES)
  set(TARGET_MERGE_LINK_LIBRARIES)
  set(TARGET_MERGE_INCLUDE_DIRECTORIES)
  set(TARGET_MERGE_COMPILE_DEFINITIONS)

  project_build_tools_add_archive_library_internal(
    "${TARGET_NAME}"
    ${add_archive_options_WITH_DEPENDENCIES}
    TARGET_MERGE_ARCHIVES
    TARGET_MERGE_LINK_LIBRARIES
    TARGET_MERGE_INCLUDE_DIRECTORIES
    TARGET_MERGE_COMPILE_DEFINITIONS
    "${add_archive_options_LINK_LIBRARIES}"
    "${add_archive_options_INCLUDE}"
    "${add_archive_options_EXCLUDE}")

  list(REMOVE_DUPLICATES TARGET_MERGE_ARCHIVES)
  # list(REVERSE TARGET_MERGE_ARCHIVES)
  set(TARGET_MERGE_ARCHIVE_LIST)
  set(TARGET_MERGE_ARCHIVE_COPY_TARGET_COMMANDS)
  set(TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES)
  foreach(ARCHIVE_FILE ${TARGET_MERGE_ARCHIVES})
    if(ARCHIVE_FILE MATCHES "^\\$<TARGET_FILE:(.*)>")
      string(REPLACE "+" "_" ARCHIVE_TARGET_NAME "${CMAKE_MATCH_1}")
      list(
        APPEND
        TARGET_MERGE_ARCHIVE_COPY_TARGET_COMMANDS
        COMMAND
        "${CMAKE_COMMAND}"
        -E
        copy_if_different
        "$<TARGET_FILE:${ARCHIVE_TARGET_NAME}>"
        "${TARGET_WORK_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${ARCHIVE_TARGET_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
      list(APPEND TARGET_MERGE_ARCHIVE_LIST
           "${TARGET_WORK_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${ARCHIVE_TARGET_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
      list(APPEND TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES
           "${TARGET_WORK_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${ARCHIVE_TARGET_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    else()
      list(APPEND TARGET_MERGE_ARCHIVE_LIST "${ARCHIVE_FILE}")
    endif()
  endforeach()
  if(TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES)
    add_custom_command(
      OUTPUT ${TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES} ${TARGET_MERGE_ARCHIVE_COPY_TARGET_COMMANDS}
      WORKING_DIRECTORY "${TARGET_WORK_DIR}"
      COMMENT "Copy ${TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES}")
  endif()

  if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows|Darwin|MinGW")
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
      atframework_cmake_toolset_find_pwsh_tools()
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH AND NOT ATFRAMEWORK_CMAKE_TOOLSET_BASH)
      atframework_cmake_toolset_find_bash_tools()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
      set(PWSH_SCRIPT_PATH "${TARGET_WORK_DIR}/build-${TARGET_NAME}.ps1")
      project_build_tool_generate_load_env_powershell("${PWSH_SCRIPT_PATH}.in")
      if(MSVC)
        file(WRITE "${PWSH_SCRIPT_PATH}.in"
             "& \"${AR_TOOL_BIN}\" \"/OUT:${OUTPUT_PATH}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      elseif(
        CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"
        AND CMAKE_LIBTOOL
        AND CMAKE_LIBTOOL_IS_CCTOOLS)
        file(WRITE "${PWSH_SCRIPT_PATH}.in"
             "& \"${CMAKE_LIBTOOL}\" \"-static\" \"-o\" \"${OUTPUT_PATH}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      else()
        file(WRITE "${PWSH_SCRIPT_PATH}.in"
             "& \"${AR_TOOL_BIN}\" \"crsT\" \"${OUTPUT_PATH}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      endif()
    else()
      set(BASH_SCRIPT_PATH "${TARGET_WORK_DIR}/build-${TARGET_NAME}.sh")
      project_build_tools_generate_load_env_bash("${BASH_SCRIPT_PATH}.in")
      if(MSVC)
        file(WRITE "${BASH_SCRIPT_PATH}.in"
             "\"${AR_TOOL_BIN}\" \"/OUT:${OUTPUT_PATH}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      elseif(
        CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"
        AND CMAKE_LIBTOOL
        AND CMAKE_LIBTOOL_IS_CCTOOLS)
        file(WRITE "${BASH_SCRIPT_PATH}.in"
             "\"${CMAKE_LIBTOOL}\" \"-static\" \"-o\" \"${OUTPUT_PATH}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      else()
        file(WRITE "${BASH_SCRIPT_PATH}.in"
             "\"${AR_TOOL_BIN}\" \"crsT\" \"${OUTPUT_PATH}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      endif()
    endif()

    foreach(ARCHIVE_FILE ${TARGET_MERGE_ARCHIVE_LIST})
      if(ARCHIVE_FILE MATCHES "\\+")
        get_filename_component(ARCHIVE_FILE_BASENAME "${ARCHIVE_FILE}" NAME)
        string(REPLACE "+" "_" ARCHIVE_FILE_BASENAME_RENAME "${ARCHIVE_FILE_BASENAME}")
        file(CREATE_LINK "${ARCHIVE_FILE}" "${TARGET_WORK_DIR}/${ARCHIVE_FILE_BASENAME_RENAME}" COPY_ON_ERROR SYMBOLIC)
        if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          file(APPEND "${PWSH_SCRIPT_PATH}.in"
               "  \"${TARGET_WORK_DIR}/${ARCHIVE_FILE_BASENAME_RENAME}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        else()
          file(APPEND "${BASH_SCRIPT_PATH}.in"
               "  \"${TARGET_WORK_DIR}/${ARCHIVE_FILE_BASENAME_RENAME}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        endif()
      else()
        if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          file(APPEND "${PWSH_SCRIPT_PATH}.in" "  \"${ARCHIVE_FILE}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        else()
          file(APPEND "${BASH_SCRIPT_PATH}.in" "  \"${ARCHIVE_FILE}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        endif()
      endif()
    endforeach()
    if(add_archive_options_REMOVE_OBJECTS)
      if(MSVC)
        foreach(REMOVE_OBJECT ${add_archive_options_REMOVE_OBJECTS})
          if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
            file(APPEND "${PWSH_SCRIPT_PATH}.in"
                 "  \"/REMOVE:${REMOVE_OBJECT}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          else()
            file(APPEND "${BASH_SCRIPT_PATH}.in"
                 "  \"/REMOVE:${REMOVE_OBJECT}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          endif()
        endforeach()
      elseif(
        CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"
        AND CMAKE_LIBTOOL
        AND CMAKE_LIBTOOL_IS_CCTOOLS)
        if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          file(APPEND "${PWSH_SCRIPT_PATH}.in" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          file(APPEND "${PWSH_SCRIPT_PATH}.in"
               "& \"${AR_TOOL_BIN}\" \"-dTlsv\" \"${OUTPUT_PATH}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        else()
          file(APPEND "${BASH_SCRIPT_PATH}.in" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          file(APPEND "${BASH_SCRIPT_PATH}.in"
               "\"${AR_TOOL_BIN}\" \"-dTlsv\" \"${OUTPUT_PATH}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        endif()
        foreach(REMOVE_OBJECT ${add_archive_options_REMOVE_OBJECTS})
          if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
            file(APPEND "${PWSH_SCRIPT_PATH}.in" "  \"${REMOVE_OBJECT}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          else()
            file(APPEND "${BASH_SCRIPT_PATH}.in" "  \"${REMOVE_OBJECT}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          endif()
        endforeach()
      else()
        if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
          file(APPEND "${PWSH_SCRIPT_PATH}.in" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          file(APPEND "${PWSH_SCRIPT_PATH}.in"
               "& \"${AR_TOOL_BIN}\" \"dsvT\" \"${OUTPUT_PATH}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        else()
          file(APPEND "${BASH_SCRIPT_PATH}.in" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          file(APPEND "${BASH_SCRIPT_PATH}.in"
               "\"${AR_TOOL_BIN}\" \"dsvT\" \"${OUTPUT_PATH}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        endif()
        foreach(REMOVE_OBJECT ${add_archive_options_REMOVE_OBJECTS})
          if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
            file(APPEND "${PWSH_SCRIPT_PATH}.in" "  \"${REMOVE_OBJECT}\" `${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          else()
            file(APPEND "${BASH_SCRIPT_PATH}.in" "  \"${REMOVE_OBJECT}\" \\${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          endif()
        endforeach()
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
      file(
        GENERATE
        OUTPUT "${PWSH_SCRIPT_PATH}"
        INPUT "${PWSH_SCRIPT_PATH}.in")
      set(TARGET_COMMAND_ARGS "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" "${PWSH_SCRIPT_PATH}")
      file(APPEND "${PWSH_SCRIPT_PATH}.in" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      set(TARGET_COMMAND_SCRIPT_FILE "${PWSH_SCRIPT_PATH}")
    else()
      file(
        GENERATE
        OUTPUT "${BASH_SCRIPT_PATH}"
        INPUT "${BASH_SCRIPT_PATH}.in")
      set(TARGET_COMMAND_ARGS "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}" "${BASH_SCRIPT_PATH}")
      file(APPEND "${BASH_SCRIPT_PATH}.in" "${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
      set(TARGET_COMMAND_SCRIPT_FILE "${BASH_SCRIPT_PATH}")
    endif()

    if(add_archive_options_ALL)
      list(APPEND TARGET_OPTIONS ALL)
    endif()
    add_custom_target(
      "${TARGET_NAME}"
      ${TARGET_OPTIONS}
      BYPRODUCTS "${OUTPUT_PATH}"
      COMMAND ${TARGET_COMMAND_ARGS}
      DEPENDS ${add_archive_options_LINK_LIBRARIES} "${TARGET_COMMAND_SCRIPT_FILE}"
              ${TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES}
      COMMENT "Generating static library ${TARGET_NAME} with ${TARGET_COMMAND_ARGS}"
      VERBATIM)

  else()
    set(AR_SCRIPT_PATH "${TARGET_WORK_DIR}/${TARGET_NAME}.ar")
    set(AR_SCRIPT_PATH_IN "${TARGET_WORK_DIR}/${TARGET_NAME}.ar.in")

    file(WRITE "${AR_SCRIPT_PATH_IN}" "create ${OUTPUT_PATH}\n")
    foreach(ARCHIVE_FILE ${TARGET_MERGE_ARCHIVE_LIST})
      if(ARCHIVE_FILE MATCHES "\\+")
        get_filename_component(ARCHIVE_FILE_BASENAME "${ARCHIVE_FILE}" NAME)
        string(REPLACE "+" "_" ARCHIVE_FILE_BASENAME_RENAME "${ARCHIVE_FILE_BASENAME}")
        file(CREATE_LINK "${ARCHIVE_FILE}" "${TARGET_WORK_DIR}/${ARCHIVE_FILE_BASENAME_RENAME}" COPY_ON_ERROR SYMBOLIC)
        file(APPEND "${AR_SCRIPT_PATH_IN}" "addlib ${TARGET_WORK_DIR}/${ARCHIVE_FILE_BASENAME_RENAME}\n")
      else()
        file(APPEND "${AR_SCRIPT_PATH_IN}" "addlib ${ARCHIVE_FILE}\n")
      endif()
    endforeach()
    if(add_archive_options_REMOVE_OBJECTS)
      foreach(REMOVE_OBJECT ${add_archive_options_REMOVE_OBJECTS})
        file(APPEND "${AR_SCRIPT_PATH_IN}" "delete ${REMOVE_OBJECT}\n")
      endforeach()
    endif()

    file(APPEND "${AR_SCRIPT_PATH_IN}" "save\nend\n")
    file(
      GENERATE
      OUTPUT "${AR_SCRIPT_PATH}"
      INPUT "${AR_SCRIPT_PATH_IN}")

    if(add_archive_options_ALL)
      list(APPEND TARGET_OPTIONS ALL)
    endif()
    add_custom_target(
      "${TARGET_NAME}"
      ${TARGET_OPTIONS}
      BYPRODUCTS "${OUTPUT_PATH}"
      COMMAND "${AR_TOOL_BIN}" "-M" "<" "${AR_SCRIPT_PATH}"
      DEPENDS ${add_archive_options_LINK_LIBRARIES} "${AR_SCRIPT_PATH}" ${TARGET_MERGE_ARCHIVE_COPY_TARGET_FILES}
      COMMENT "Generating static library ${TARGET_NAME} with \"${AR_TOOL_BIN}\" \"-M\" < \"${AR_SCRIPT_PATH}\""
      VERBATIM)
  endif()

  if(add_archive_options_MERGE_COMPILE_DEFINITIONS AND TARGET_MERGE_COMPILE_DEFINITIONS)
    list(REMOVE_DUPLICATES TARGET_MERGE_COMPILE_DEFINITIONS)
    set_target_properties("${TARGET_NAME}" PROPERTIES INTERFACE_COMPILE_DEFINITIONS
                                                      "${TARGET_MERGE_COMPILE_DEFINITIONS}")
  endif()
  if(add_archive_options_MERGE_INCLUDE_DIRECTORIES AND TARGET_MERGE_INCLUDE_DIRECTORIES)
    list(REMOVE_DUPLICATES TARGET_MERGE_INCLUDE_DIRECTORIES)
    set_target_properties("${TARGET_NAME}" PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                                      "${TARGET_MERGE_INCLUDE_DIRECTORIES}")
  endif()
  if(add_archive_options_MERGE_LINK_LIBRARIES AND TARGET_MERGE_LINK_LIBRARIES)
    list(REVERSE TARGET_MERGE_LINK_LIBRARIES)
    list(REMOVE_DUPLICATES TARGET_MERGE_LINK_LIBRARIES)
    list(REVERSE TARGET_MERGE_LINK_LIBRARIES)
    set_target_properties("${TARGET_NAME}" PROPERTIES INTERFACE_LINK_LIBRARIES "${TARGET_MERGE_LINK_LIBRARIES}")
  endif()

  # Install
  if(add_archive_options_INSTALL_DESTINATION)
    install(FILES "${OUTPUT_PATH}" DESTINATION "${add_archive_options_INSTALL_DESTINATION}")
  endif()
  if(add_archive_options_OUTPUT_NAME_VARIABLE)
    set(${add_archive_options_OUTPUT_NAME_VARIABLE}
        "${OUTPUT_NAME}"
        PARENT_SCOPE)
  endif()
  if(add_archive_options_OUTPUT_PATH_VARIABLE)
    set(${add_archive_options_OUTPUT_PATH_VARIABLE}
        "${OUTPUT_PATH}"
        PARENT_SCOPE)
  endif()
endfunction()

macro(project_build_tools_push_patch_inherit_compile_flags_state)
  if(NOT __inherit_compile_flags_state_STACK_LEVEL)
    set(__inherit_compile_flags_state_STACK_LEVEL 0)
  else()
    math(EXPR __inherit_compile_flags_state_STACK_LEVEL "${__inherit_compile_flags_state_STACK_LEVEL}+1")
  endif()
  foreach(__inherit_compile_flags_state_INHERIT_VAR "PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT"
                                                    "PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE")
    foreach(__inherit_compile_flags_state_LANG "ASM" "C" "CXX")
      foreach(__inherit_compile_flags_state_FLAG "FLAGS" "FLAGS_DEBUG" "FLAGS_MINSIZEREL" "FLAGS_RELEASE"
                                                 "FLAGS_RELWITHDEBINFO")
        set(__inherit_compile_flags_state_INHERIT_SRC_NAME
            ${__inherit_compile_flags_state_INHERIT_VAR}_CMAKE_${__inherit_compile_flags_state_LANG}_${__inherit_compile_flags_state_FLAG}
        )
        set(__inherit_compile_flags_state_INHERIT_BACKUP_NAME
            __inherit_compile_flags_state_BACKUP_${__inherit_compile_flags_state_STACK_LEVEL}_${__inherit_compile_flags_state_INHERIT_VAR}_CMAKE_${__inherit_compile_flags_state_LANG}_${__inherit_compile_flags_state_FLAG}
        )
        if(DEFINED ${__inherit_compile_flags_state_INHERIT_SRC_NAME})
          set(${__inherit_compile_flags_state_INHERIT_BACKUP_NAME}
              "${${__inherit_compile_flags_state_INHERIT_SRC_NAME}}")
        else()
          unset(${__inherit_compile_flags_state_INHERIT_BACKUP_NAME})
        endif()
      endforeach()
    endforeach()
  endforeach()

  unset(__inherit_compile_flags_state_INHERIT_SRC_NAME)
  unset(__inherit_compile_flags_state_INHERIT_BACKUP_NAME)
endmacro()

macro(project_build_tools_pop_patch_compile_flags_state)
  if(__inherit_compile_flags_state_STACK_LEVEL)
    foreach(__inherit_compile_flags_state_INHERIT_VAR "PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT"
                                                      "PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE")
      foreach(__inherit_compile_flags_state_LANG "ASM" "C" "CXX")
        foreach(__inherit_compile_flags_state_FLAG "FLAGS" "FLAGS_DEBUG" "FLAGS_MINSIZEREL" "FLAGS_RELEASE"
                                                   "FLAGS_RELWITHDEBINFO")
          set(__inherit_compile_flags_state_INHERIT_SRC_NAME
              ${__inherit_compile_flags_state_INHERIT_VAR}_CMAKE_${__inherit_compile_flags_state_LANG}_${__inherit_compile_flags_state_FLAG}
          )
          set(__inherit_compile_flags_state_INHERIT_BACKUP_NAME
              __inherit_compile_flags_state_BACKUP_${__inherit_compile_flags_state_STACK_LEVEL}_${__inherit_compile_flags_state_INHERIT_VAR}_CMAKE_${__inherit_compile_flags_state_LANG}_${__inherit_compile_flags_state_FLAG}
          )
          if(DEFINED ${__inherit_compile_flags_state_INHERIT_BACKUP_NAME})
            set(${__inherit_compile_flags_state_INHERIT_SRC_NAME}
                "${${__inherit_compile_flags_state_INHERIT_BACKUP_NAME}}")
            unset(${__inherit_compile_flags_state_INHERIT_BACKUP_NAME})
          endif()
        endforeach()
      endforeach()
    endforeach()

    if(__inherit_compile_flags_state_STACK_LEVEL LESS 1)
      unset(__inherit_compile_flags_state_STACK_LEVEL)
    else()
      math(EXPR __inherit_compile_flags_state_STACK_LEVEL "${__inherit_compile_flags_state_STACK_LEVEL}-1")
    endif()
  endif()

  unset(__inherit_compile_flags_state_INHERIT_SRC_NAME)
  unset(__inherit_compile_flags_state_INHERIT_BACKUP_NAME)
endmacro()

macro(project_build_tools_push_patch_inherit_link_flags_state)
  if(NOT __inherit_link_flags_state_STACK_LEVEL)
    set(__inherit_link_flags_state_STACK_LEVEL 0)
  else()
    math(EXPR __inherit_link_flags_state_STACK_LEVEL "${__inherit_link_flags_state_STACK_LEVEL}+1")
  endif()
  foreach(__inherit_link_flags_state_INHERIT_VAR "PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT"
                                                 "PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE")
    foreach(__inherit_link_flags_state_TYPE "STATIC" "SHARED" "MODULE" "EXE")
      foreach(__inherit_link_flags_state_FLAG "LINKER_FLAGS" "LINKER_FLAGS_DEBUG" "LINKER_FLAGS_MINSIZEREL"
                                              "LINKER_FLAGS_RELEASE" "LINKER_FLAGS_RELWITHDEBINFO")
        set(__inherit_link_flags_state_INHERIT_SRC_NAME
            ${__inherit_link_flags_state_INHERIT_VAR}_CMAKE_${__inherit_link_flags_state_TYPE}_${__inherit_link_flags_state_FLAG}
        )
        set(__inherit_link_flags_state_INHERIT_BACKUP_NAME
            __inherit_link_flags_state_BACKUP_${__inherit_link_flags_state_STACK_LEVEL}_${__inherit_link_flags_state_INHERIT_VAR}_CMAKE_${__inherit_link_flags_state_TYPE}_${__inherit_link_flags_state_FLAG}
        )
        if(DEFINED ${__inherit_link_flags_state_INHERIT_SRC_NAME})
          set(${__inherit_link_flags_state_INHERIT_BACKUP_NAME} "${${__inherit_link_flags_state_INHERIT_SRC_NAME}}")
        else()
          unset(${__inherit_link_flags_state_INHERIT_BACKUP_NAME})
        endif()
      endforeach()
    endforeach()
  endforeach()

  unset(__inherit_link_flags_state_INHERIT_SRC_NAME)
  unset(__inherit_link_flags_state_INHERIT_BACKUP_NAME)
endmacro()

macro(project_build_tools_pop_patch_link_flags_state)
  if(__inherit_link_flags_state_STACK_LEVEL)
    foreach(__inherit_link_flags_state_INHERIT_VAR "PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT"
                                                   "PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE")
      foreach(__inherit_link_flags_state_TYPE "STATIC" "SHARED" "MODULE" "EXE")
        foreach(__inherit_link_flags_state_FLAG "LINKER_FLAGS" "LINKER_FLAGS_DEBUG" "LINKER_FLAGS_MINSIZEREL"
                                                "LINKER_FLAGS_RELEASE" "LINKER_FLAGS_RELWITHDEBINFO")
          set(__inherit_link_flags_state_INHERIT_SRC_NAME
              ${__inherit_link_flags_state_INHERIT_VAR}_CMAKE_${__inherit_link_flags_state_TYPE}_${__inherit_link_flags_state_FLAG}
          )
          set(__inherit_link_flags_state_INHERIT_BACKUP_NAME
              __inherit_link_flags_state_BACKUP_${__inherit_link_flags_state_STACK_LEVEL}_${__inherit_link_flags_state_INHERIT_VAR}_CMAKE_${__inherit_link_flags_state_TYPE}_${__inherit_link_flags_state_FLAG}
          )
          if(DEFINED ${__inherit_link_flags_state_INHERIT_BACKUP_NAME})
            set(${__inherit_link_flags_state_INHERIT_SRC_NAME} "${${__inherit_link_flags_state_INHERIT_BACKUP_NAME}}")
            unset(${__inherit_link_flags_state_INHERIT_BACKUP_NAME})
          endif()
        endforeach()
      endforeach()
    endforeach()

    if(__inherit_link_flags_state_STACK_LEVEL LESS 1)
      unset(__inherit_link_flags_state_STACK_LEVEL)
    else()
      math(EXPR __inherit_link_flags_state_STACK_LEVEL "${__inherit_link_flags_state_STACK_LEVEL}-1")
    endif()
  endif()

  unset(__inherit_link_flags_state_INHERIT_SRC_NAME)
  unset(__inherit_link_flags_state_INHERIT_BACKUP_NAME)
endmacro()
