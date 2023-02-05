include_guard(DIRECTORY)

include(ProjectBuildTools)

get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${CMAKE_CURRENT_LIST_DIR}/../" ABSOLUTE CACHE)

option(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ENABLE_PACKAGE_REGISTRY "Enable export(PACKAGE)" OFF)
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ENABLE_PACKAGE_REGISTRY)
  set_compiler_flags_to_inherit_var(CMAKE_EXPORT_NO_PACKAGE_REGISTRY OFF) # cmake_policy(SET CMP0090 OLD)
  set_compiler_flags_to_inherit_var(CMAKE_EXPORT_PACKAGE_REGISTRY ON) # cmake_policy(SET CMP0090 NEW)
else()
  set_compiler_flags_to_inherit_var(CMAKE_EXPORT_NO_PACKAGE_REGISTRY ON) # cmake_policy(SET CMP0090 OLD)
  set_compiler_flags_to_inherit_var(CMAKE_EXPORT_PACKAGE_REGISTRY OFF) # cmake_policy(SET CMP0090 NEW)
endif()

# Migrate from PROJECT_3RD_PARTY_PACKAGE_DIR
if(NOT PROJECT_THIRD_PARTY_PACKAGE_DIR AND PROJECT_3RD_PARTY_PACKAGE_DIR)
  set(PROJECT_THIRD_PARTY_PACKAGE_DIR
      "${PROJECT_3RD_PARTY_PACKAGE_DIR}"
      CACHE PATH "Where to store packages for third party packages")
elseif(NOT PROJECT_THIRD_PARTY_PACKAGE_DIR)
  set(PROJECT_THIRD_PARTY_PACKAGE_DIR
      "${PROJECT_SOURCE_DIR}/third_party/packages"
      CACHE PATH "Where to store packages for third party packages")
endif()

# Migrate from PROJECT_3RD_PARTY_INSTALL_DIR
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR AND PROJECT_3RD_PARTY_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_INSTALL_DIR
      "${PROJECT_3RD_PARTY_INSTALL_DIR}"
      CACHE PATH "Where to install packages for third party packages")
elseif(NOT PROJECT_THIRD_PARTY_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_PLATFORM_NAME}"
      CACHE PATH "Where to install packages for third party packages")
endif()
if(NOT PROJECT_THIRD_PARTY_HOST_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_HOST_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}")
endif()

set(PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}/Modules")
if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR "_deps")
endif()
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR)
  if(NOT IS_ABSOLUTE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}")
    get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_DIR "${CMAKE_BINARY_DIR}" DIRECTORY)
    get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_NAME "${CMAKE_BINARY_DIR}" NAME)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_NAME}_${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}"
    )
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_DIR)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_NAME)
  endif()
  if(DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}"
        CACHE PATH "Host target build directory when crossing compilling" FORCE)
  endif()
endif()
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_RESET_BUILD_ENVS_BASH
    "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/reset-host-build-envs.sh")
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_RESTORE_BUILD_ENVS_BASH
    "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/restore-host-build-envs.sh")
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_RESET_BUILD_ENVS_PWSH
    "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/reset-host-build-envs.ps1")
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_RESTORE_BUILD_ENVS_PWSH
    "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/restore-host-build-envs.ps1")
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE
    OFF
    CACHE BOOL "Disable parallel building for some packages to reduce memory usage")

if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE AND NOT DEFINED
                                                                 CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE})
  if(DEFINED ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE "$ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE}")
  endif()
endif()

if(NOT EXISTS ${PROJECT_THIRD_PARTY_PACKAGE_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_PACKAGE_DIR})
endif()

if(NOT EXISTS ${PROJECT_THIRD_PARTY_INSTALL_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR})
endif()

if(NOT EXISTS ${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR})
endif()

if(NOT EXISTS ${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR})
endif()

set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR IN_LIST CMAKE_FIND_ROOT_PATH)
  if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
    list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/cmake"
         "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}"
         "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}/cmake")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64/cmake"
           "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/cmake")
    else()
      list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake")
    endif()
  else()
    list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  endif()
endif()
if(NOT PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR IN_LIST CMAKE_MODULE_PATH)
  list(PREPEND CMAKE_MODULE_PATH "${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR}")
endif()
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR IN_LIST CMAKE_PREFIX_PATH)
  if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
    list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/cmake"
         "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}"
         "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}/cmake")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64/cmake"
           "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/cmake")
    else()
      list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake")
    endif()
  else()
    list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  endif()
endif()
if(CMAKE_CROSSCOMPILING)
  list(PREPEND CMAKE_PROGRAM_PATH "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/bin"
       "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/libexec")
endif()
if(UNIX OR MINGW)
  set(PKG_CONFIG_USE_CMAKE_PREFIX_PATH TRUE)
  if(ENV{PKG_CONFIG_PATH})
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(ENV{PKG_CONFIG_PATH}
          "$ENV{PKG_CONFIG_PATH}:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64/pkgconfig:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/pkgconfig"
      )
    else()
      set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/pkgconfig")
    endif()
  else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      set(ENV{PKG_CONFIG_PATH}
          "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64/pkgconfig:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/pkgconfig")
    else()
      set(ENV{PKG_CONFIG_PATH} "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/pkgconfig")
    endif()
  endif()
endif()

function(project_third_party_print_find_information)
  message(STATUS "cmake-toolset: CMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}")
  message(STATUS "cmake-toolset: CMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR)
    message(
      STATUS
        "cmake-toolset: ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}"
    )
  endif()
  message(STATUS "cmake-toolset: PROJECT_THIRD_PARTY_INSTALL_DIR=${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  message(STATUS "cmake-toolset: PROJECT_THIRD_PARTY_HOST_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}")
  message(STATUS "cmake-toolset: PROJECT_THIRD_PARTY_PACKAGE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}")
  set(_PRINT_CMAKE_VARIABLES
      CMAKE_SYSROOT
      CMAKE_MODULE_PATH
      CMAKE_PREFIX_PATH
      CMAKE_FIND_ROOT_PATH
      CMAKE_FIND_PACKAGE_PREFER_CONFIG
      CMAKE_FIND_NO_INSTALL_PREFIX
      CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY
      CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY
      CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH
      CMAKE_FIND_USE_CMAKE_PATH
      CMAKE_FIND_USE_CMAKE_SYSTEM_PATH
      CMAKE_FIND_USE_PACKAGE_REGISTRY
      CMAKE_FIND_USE_PACKAGE_ROOT_PATH
      CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH
      CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY
      CMAKE_FIND_ROOT_PATH_MODE_INCLUDE
      CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
      CMAKE_FIND_ROOT_PATH_MODE_PACKAGE
      CMAKE_FIND_ROOT_PATH_MODE_PROGRAM
      CMAKE_FIND_LIBRARY_CUSTOM_LIB_SUFFIX
      FIND_LIBRARY_USE_LIB32_PATHS
      FIND_LIBRARY_USE_LIBX32_PATHS
      FIND_LIBRARY_USE_LIB64_PATHS)
  foreach(VAR_NAME IN LISTS _PRINT_CMAKE_VARIABLES)
    if(${VAR_NAME})
      message(STATUS "cmake-toolset: ${VAR_NAME}=${${VAR_NAME}}")
    endif()
  endforeach()
  if(UNIX)
    message(STATUS "cmake-toolset: ENV{PKG_CONFIG_PATH}=$ENV{PKG_CONFIG_PATH}")
  endif()
endfunction()
project_third_party_print_find_information()

mark_as_advanced(PROJECT_THIRD_PARTY_PACKAGE_DIR PROJECT_THIRD_PARTY_INSTALL_DIR)

# Some libraries maybe has wrong RPATH
string(FIND "$ENV{PATH}" "\;" PROJECT_THIRD_PARTY_TEST_PATH_SEP)
if(PROJECT_THIRD_PARTY_TEST_PATH_SEP GREATER_EQUAL 0)
  set(PROJECT_THIRD_PARTY_PATH_SEPARATOR ";")
else()
  set(PROJECT_THIRD_PARTY_PATH_SEPARATOR ":")
endif()
unset(PROJECT_THIRD_PARTY_TEST_PATH_SEP)
if(UNIX
   OR MINGW
   OR MSYS)
  if(DEFINED ENV{LD_LIBRARY_PATH})
    set(ENV{LD_LIBRARY_PATH}
        "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64${PROJECT_THIRD_PARTY_PATH_SEPARATOR}${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib${PROJECT_THIRD_PARTY_PATH_SEPARATOR}$ENV{LD_LIBRARY_PATH}"
    )
  else()
    set(ENV{LD_LIBRARY_PATH}
        "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64${PROJECT_THIRD_PARTY_PATH_SEPARATOR}${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib"
    )
  endif()
endif()

if(CMAKE_CROSSCOMPILING)
  set(ENV{PATH}
      "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/bin${PROJECT_THIRD_PARTY_PATH_SEPARATOR}${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/libexec${PROJECT_THIRD_PARTY_PATH_SEPARATOR}$ENV{PATH}"
  )
else()
  set(ENV{PATH}
      "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/bin${PROJECT_THIRD_PARTY_PATH_SEPARATOR}${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/libexec${PROJECT_THIRD_PARTY_PATH_SEPARATOR}$ENV{PATH}"
  )
endif()

find_package(Threads)

# Max for two core when low memory detected
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE AND NOT PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD)
  set(PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD 2)
endif()

# Utility macros for build third party libraries
function(project_third_party_check_build_shared_lib PORT_NAME PORT_PREFIX VARNAME)
  if(PORT_PREFIX AND NOT "${PORT_PREFIX}" STREQUAL "")
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_PREFIX}_${PORT_NAME}" FULL_PORT_NAME)
  else()
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_NAME}" FULL_PORT_NAME)
  endif()

  if(DEFINED ${FULL_PORT_NAME}_USE_SHARED AND ${FULL_PORT_NAME}_USE_SHARED)
    set(${VARNAME}
        TRUE
        PARENT_SCOPE)
  elseif(DEFINED ENV{${FULL_PORT_NAME}_USE_SHARED} AND ENV{${FULL_PORT_NAME}_USE_SHARED)
    set(${VARNAME}
        TRUE
        PARENT_SCOPE)
  elseif(DEFINED ${FULL_PORT_NAME}_USE_STATIC AND ${FULL_PORT_NAME}_USE_STATIC)
    set(${VARNAME}
        FALSE
        PARENT_SCOPE)
  elseif(DEFINED ENV{${FULL_PORT_NAME}_USE_STATIC} AND ENV{${FULL_PORT_NAME}_USE_STATIC)
    set(${VARNAME}
        FALSE
        PARENT_SCOPE)
  elseif(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    set(${VARNAME}
        TRUE
        PARENT_SCOPE)
  else()
    set(${VARNAME}
        FALSE
        PARENT_SCOPE)
  endif()
endfunction()

macro(project_third_party_append_build_shared_lib_var PORT_NAME PORT_PREFIX LISTNAME)
  project_third_party_check_build_shared_lib("${PORT_NAME}" "${PORT_PREFIX}"
                                             project_third_party_append_build_shared_lib_var_USE_SHARED)
  if(project_third_party_append_build_shared_lib_var_USE_SHARED)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=ON")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=OFF")
    endforeach()
  endif()

  unset(project_third_party_append_build_shared_lib_var_USE_SHARED)
endmacro()

macro(project_third_party_append_build_static_lib_var PORT_NAME PORT_PREFIX LISTNAME)
  project_third_party_check_build_shared_lib("${PORT_NAME}" "${PORT_PREFIX}"
                                             project_third_party_append_build_static_lib_var_USE_SHARED)

  if(project_third_party_append_build_static_lib_var_USE_SHARED)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=OFF")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=ON")
    endforeach()
  endif()

  unset(project_third_party_append_build_static_lib_var_USE_SHARED)
endmacro()

macro(project_third_party_append_find_root_args VARNAME)
  if(CMAKE_FIND_ROOT_PATH)
    list_append_unescape(${VARNAME} "-DCMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}")
  endif()
  if(CMAKE_PREFIX_PATH)
    list_append_unescape(${VARNAME} "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
  endif()
endmacro()

# Patch for `FindGit.cmake` on windows
find_program(GIT_EXECUTABLE NAMES git git.cmd)
find_package(Git)
if(NOT GIT_FOUND AND NOT Git_FOUND)
  message(FATAL_ERROR "git is required to use ports")
endif()

project_git_get_ambiguous_name(ATFRAMEWORK_CMAKE_TOOLSET_GIT_COMMIT_HASH "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}")

if(NOT project_third_party_get_build_dir_HASH)
  if(ATFRAMEWORK_CMAKE_TOOLSET_GIT_COMMIT_HASH)
    set(project_third_party_get_build_dir_HASH_TOOLSET "${ATFRAMEWORK_CMAKE_TOOLSET_GIT_COMMIT_HASH}")
  else()
    file(SHA256 "${CMAKE_CURRENT_LIST_FILE}" project_third_party_get_build_dir_HASH_TOOLSET)
  endif()
  string(SHA256 project_third_party_get_build_dir_HASH_PROJECT "${PROJECT_SOURCE_DIR}")

  string(SUBSTRING "${project_third_party_get_build_dir_HASH_TOOLSET}" 0 8
                   project_third_party_get_build_dir_HASH_TOOLSET)
  string(SUBSTRING "${project_third_party_get_build_dir_HASH_PROJECT}" 0 5
                   project_third_party_get_build_dir_HASH_PROJECT)
  set(project_third_party_get_build_dir_HASH
      "${project_third_party_get_build_dir_HASH_TOOLSET}-${project_third_party_get_build_dir_HASH_PROJECT}")
endif()
if(DEFINED ENV{HOME})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{HOME}")
elseif(DEFINED ENV{USERPROFILE})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{USERPROFILE}")
elseif(DEFINED ENV{TEMP})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{TEMP}")
endif()
string(REPLACE "\\" "/" project_third_party_get_build_dir_USER_BASE "${project_third_party_get_build_dir_USER_BASE}")

if(WIN32
   AND NOT MINGW
   AND NOT CYGWIN)
  message(
    STATUS
      "CMake Toolset using buildtree: ${project_third_party_get_build_dir_USER_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}"
  )
  if(CMAKE_BINARY_DIR MATCHES "^[cC]:" OR CMAKE_BINARY_DIR MATCHES "^/[cC]/")
    set(project_third_party_get_build_dir_SELECT_BASE "${project_third_party_get_build_dir_USER_BASE}")
  elseif(CMAKE_BINARY_DIR MATCHES "^([A-Za-z]:)")
    set(project_third_party_get_build_dir_SELECT_BASE "${CMAKE_MATCH_1}")
  elseif(CMAKE_BINARY_DIR MATCHES "^(/[A-Za-z])/")
    set(project_third_party_get_build_dir_SELECT_BASE "${CMAKE_MATCH_1}")
  else()
    set(project_third_party_get_build_dir_SELECT_BASE "${project_third_party_get_build_dir_USER_BASE}")
  endif()
endif()
message(STATUS "cmake-toolset: ATFRAMEWORK_CMAKE_TOOLSET_GIT_COMMIT_HASH=${ATFRAMEWORK_CMAKE_TOOLSET_GIT_COMMIT_HASH}")

function(project_third_party_get_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
  string(LENGTH "${PORT_VERSION}" project_third_party_get_build_dir_PORT_VERSION_LEN)
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES "[0-9A-Fa-f]+")
    string(SUBSTRING "${PORT_VERSION}" 0 12 project_third_party_get_build_dir_PORT_VERSION)
  else()
    set(project_third_party_get_build_dir_PORT_VERSION "${PORT_VERSION}")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR)
    set(${OUTPUT_VARNAME}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
        PARENT_SCOPE)
  elseif(
    WIN32
    AND NOT MINGW
    AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_SELECT_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VARNAME}
        "${CMAKE_BINARY_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_third_party_get_host_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
  string(LENGTH "${PORT_VERSION}" project_third_party_get_build_dir_PORT_VERSION_LEN)
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES "[0-9A-Fa-f]+")
    string(SUBSTRING "${PORT_VERSION}" 0 12 project_third_party_get_build_dir_PORT_VERSION)
  else()
    set(project_third_party_get_build_dir_PORT_VERSION "${PORT_VERSION}")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR)
    set(${OUTPUT_VARNAME}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
        PARENT_SCOPE)
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR)
    set(${OUTPUT_VARNAME}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
        PARENT_SCOPE)
  elseif(
    WIN32
    AND NOT MINGW
    AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_SELECT_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
        PARENT_SCOPE)
  else()
    get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_DIR "${CMAKE_BINARY_DIR}" DIRECTORY)
    get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_NAME "${CMAKE_BINARY_DIR}" NAME)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_NAME}_host"
    )
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_DIR)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_BASE_NAME)
    set(${OUTPUT_VARNAME}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_third_party_cleanup_old_build_tree BASE_DIR)
  file(GLOB project_third_party_old_build_dirs "${BASE_DIR}/cmake-toolset/*")

  string(TIMESTAMP current_time "%s" UTC)

  foreach(old_build_dir IN LISTS project_third_party_old_build_dirs)
    if(IS_DIRECTORY "${old_build_dir}")
      get_filename_component(old_build_dir_parent "${old_build_dir}" DIRECTORY)
      if(EXISTS "${old_build_dir_parent}/.git")
        message(STATUS "Ignore cleanup ${old_build_dir} because ${old_build_dir_parent}/.git exists")
      else()
        file(TIMESTAMP "${old_build_dir}" old_build_dir_time "%s" UTC)
        math(EXPR old_build_dir_time_offset "${current_time}-${old_build_dir_time}")
        if(old_build_dir_time_offset GREATER 2592000) # 30 days
          file(TIMESTAMP "${old_build_dir}" old_build_dir_modify_time "%Y-%m-%d %H:%M:%S")
          message(STATUS "Cleanup old build tree ${old_build_dir}, last modified on ${old_build_dir_modify_time}")
          file(REMOVE_RECURSE "${old_build_dir}")
        endif()
      endif()
    endif()
  endforeach()
endfunction()
project_third_party_cleanup_old_build_tree("${project_third_party_get_build_dir_USER_BASE}")
if(NOT project_third_party_get_build_dir_SELECT_BASE STREQUAL project_third_party_get_build_dir_USER_BASE)
  project_third_party_cleanup_old_build_tree("${project_third_party_get_build_dir_SELECT_BASE}")
endif()

macro(ATFRAMEWORK_CMAKE_TOOLSET_FIND_BASH_TOOLS)
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
endmacro()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_BASH)
  if(CMAKE_HOST_WIN32 OR CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      atframework_cmake_toolset_find_bash_tools()
    endif()

    get_filename_component(GIT_EXECUTABLE_DIR "${GIT_EXECUTABLE}" DIRECTORY)
    get_filename_component(GIT_HOME_DIR "${GIT_EXECUTABLE_DIR}" DIRECTORY)

    set(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS
        "${GIT_EXECUTABLE_DIR}" "${GIT_EXECUTABLE_DIR}/bin" "${GIT_EXECUTABLE_DIR}/usr/bin" "${GIT_HOME_DIR}/bin"
        "${GIT_HOME_DIR}/usr/bin")
    set(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_NAMES bash cp gzip mv rm tar)

    if(DEFINED ENV{HOME})
      if(EXISTS "$ENV{HOME}/scoop/apps")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS "$ENV{HOME}/scoop/shims"
             "$ENV{HOME}/scoop/apps/git/current/bin" "$ENV{HOME}/scoop/apps/git/current/usr/bin"
             "$ENV{HOME}/scoop/apps/msys2/current/usr/bin")
      endif()
    elseif(DEFINED ENV{USERPROFILE})
      if(EXISTS "$ENV{USERPROFILE}/scoop/apps")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS "$ENV{USERPROFILE}/scoop/shims"
             "$ENV{USERPROFILE}/scoop/apps/git/current/bin" "$ENV{USERPROFILE}/scoop/apps/git/current/usr/bin"
             "$ENV{USERPROFILE}/scoop/apps/msys2/current/usr/bin")
      endif()
    endif()

    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS "C:/Program Files/Git/bin" "C:/msys64/usr/bin"
         "C:/tools/msys64/usr/bin" "C:/Program Files (x86)/Git/bin")

    foreach(TEST_BIN_NAME ${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_NAMES})
      string(TOUPPER ${TEST_BIN_NAME} TEST_VAR_NAME)
      if(ATFRAMEWORK_CMAKE_TOOLSET_${TEST_VAR_NAME})
        continue()
      endif()
      foreach(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIR ${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS})
        if(EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIR}/${TEST_BIN_NAME}.exe")
          string(REPLACE "\\" "/" ATFRAMEWORK_CMAKE_TOOLSET_${TEST_VAR_NAME}
                         "${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIR}/${TEST_BIN_NAME}.exe")
          set(ATFRAMEWORK_CMAKE_TOOLSET_${TEST_VAR_NAME}
              "${ATFRAMEWORK_CMAKE_TOOLSET_${TEST_VAR_NAME}}"
              CACHE FILEPATH "PATH of ${TEST_BIN_NAME}")
          break()
        endif()
      endforeach()
      unset(TEST_VAR_NAME)
    endforeach()

    unset(TEST_BIN_NAME)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIR)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS)
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_BASH)
    atframework_cmake_toolset_find_bash_tools()
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_BASH)
    message(FATAL_ERROR "bash is required to use ports")
  endif()
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_BASH)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_CP)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_GZIP)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_MV)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_RM)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_TAR)
endif()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_PWSH NAMES pwsh pwsh.exe pwsh-preview pwsh-preview.exe)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
endif()

function(project_third_party_generate_load_env_bash)
  project_build_tools_generate_load_env_bash(${ARGN})
endfunction()

function(project_third_party_generate_load_env_powershell)
  project_build_tool_generate_load_env_powershell(${ARGN})
endfunction()

function(project_third_party_port_declare PORT_NAME)
  set(optionArgs APPEND_BUILD_OPTIONS)
  set(oneValueArgs VERSION GIT_URL TAR_URL SRC_DIRECTORY_NAME BUILD_DIR PORT_PREFIX)
  set(multiValueArgs BUILD_OPTIONS)
  cmake_parse_arguments(project_third_party_port_declare "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}"
                        "${ARGN}")
  if(project_third_party_port_declare_PORT_PREFIX)
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${project_third_party_port_declare_PORT_PREFIX}_${PORT_NAME}"
                   FULL_PORT_NAME)
  else()
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_NAME}" FULL_PORT_NAME)
  endif()

  string(REGEX REPLACE "[-\\.]" "_" FULL_PORT_NAME "${FULL_PORT_NAME}")

  if(NOT ${FULL_PORT_NAME}_VERSION AND project_third_party_port_declare_VERSION)
    set(${FULL_PORT_NAME}_VERSION "${project_third_party_port_declare_VERSION}")
    set(${FULL_PORT_NAME}_VERSION
        "${${FULL_PORT_NAME}_VERSION}"
        PARENT_SCOPE)
  endif()
  if(NOT ${FULL_PORT_NAME}_GIT_URL AND project_third_party_port_declare_GIT_URL)
    set(${FULL_PORT_NAME}_GIT_URL
        "${project_third_party_port_declare_GIT_URL}"
        PARENT_SCOPE)
  endif()
  if(NOT ${FULL_PORT_NAME}_BUILD_OPTIONS AND project_third_party_port_declare_BUILD_OPTIONS)
    if(project_third_party_port_declare_APPEND_BUILD_OPTIONS)
      if(${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS)
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            "${project_third_party_port_declare_BUILD_OPTIONS}"
            "${project_third_party_port_declare_APPEND_BUILD_OPTIONS}"
            "${${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS}"
            PARENT_SCOPE)
      else()
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            "${project_third_party_port_declare_BUILD_OPTIONS}"
            "${project_third_party_port_declare_APPEND_BUILD_OPTIONS}"
            PARENT_SCOPE)
      endif()
    else()
      if(${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS)
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            "${project_third_party_port_declare_BUILD_OPTIONS}" "${${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS}"
            PARENT_SCOPE)
      else()
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            "${project_third_party_port_declare_BUILD_OPTIONS}"
            PARENT_SCOPE)
      endif()
    endif()
  endif()

  if(NOT ${FULL_PORT_NAME}_BUILD_DIR)
    if(NOT project_third_party_port_declare_BUILD_DIR)
      project_third_party_get_build_dir(${FULL_PORT_NAME}_BUILD_DIR "${PORT_NAME}" "${${FULL_PORT_NAME}_VERSION}")
    else()
      set(${FULL_PORT_NAME}_BUILD_DIR "${project_third_party_port_declare_BUILD_DIR}")
    endif()
    set(${FULL_PORT_NAME}_BUILD_DIR
        "${${FULL_PORT_NAME}_BUILD_DIR}"
        PARENT_SCOPE)
  endif()

  if(NOT ${FULL_PORT_NAME}_SRC_DIRECTORY_NAME)
    if(NOT project_third_party_port_declare_SRC_DIRECTORY_NAME)
      set(${FULL_PORT_NAME}_SRC_DIRECTORY_NAME "${PORT_NAME}-${${FULL_PORT_NAME}_VERSION}")
    else()
      set(${FULL_PORT_NAME}_SRC_DIRECTORY_NAME "${project_third_party_port_declare_SRC_DIRECTORY_NAME}")
    endif()
    set(${FULL_PORT_NAME}_SRC_DIRECTORY_NAME
        "${${FULL_PORT_NAME}_SRC_DIRECTORY_NAME}"
        PARENT_SCOPE)
  endif()

  if(NOT DEFINED ${FULL_PORT_NAME}_USE_STATIC)
    if(DEFINED ENV{${FULL_PORT_NAME}_USE_STATIC})
      set(${FULL_PORT_NAME}_USE_STATIC
          $ENV{${FULL_PORT_NAME}_USE_STATIC}
          PARENT_SCOPE)
    endif()
  endif()

  if(NOT DEFINED ${FULL_PORT_NAME}_USE_SHARED)
    if(DEFINED ENV{${FULL_PORT_NAME}_USE_SHARED})
      set(${FULL_PORT_NAME}_USE_SHARED
          $ENV{${FULL_PORT_NAME}_USE_SHARED}
          PARENT_SCOPE)
    endif()
  endif()

  unset(FULL_PORT_NAME)
endfunction()

function(project_third_party_try_patch_file_internal OUTPUT_VAR BASE_DIRECTORY PORT_PREFIX VERSION SUFFIX)
  string(REPLACE "." "\\." SUFFIX_REGEX "${SUFFIX}")
  if(EXISTS "${BASE_DIRECTORY}/${PORT_PREFIX}-${VERSION}${SUFFIX}")
    set(${OUTPUT_VAR}
        "${BASE_DIRECTORY}/${PORT_PREFIX}-${VERSION}${SUFFIX}"
        PARENT_SCOPE)
  elseif(VERSION MATCHES "(.*)\\.[^\\.]*$")
    unset(SELECT_PATCH_FILE)
    unset(SELECT_PATCH_VERSION)
    set(MINOR_VERSION "${CMAKE_MATCH_1}")
    if(VERSION MATCHES "^v(.*)")
      set(STANDARD_VERSION "${CMAKE_MATCH_1}")
    else()
      set(STANDARD_VERSION "${VERSION}")
    endif()
    file(GLOB TRY_PATCH_FILES "${BASE_DIRECTORY}/${PORT_PREFIX}-${MINOR_VERSION}*${SUFFIX}")
    foreach(PATCH_FILE IN LISTS TRY_PATCH_FILES)
      get_filename_component(PATCH_FILE_BASE_NAME "${PATCH_FILE}" NAME)
      if(PATCH_FILE_BASE_NAME MATCHES "^${PORT_PREFIX}-(v)?([0-9]+\\..*)${SUFFIX_REGEX}")
        set(TRY_SELECT_PATCH_VERSION "${CMAKE_MATCH_2}")
        if("${TRY_SELECT_PATCH_VERSION}" VERSION_LESS_EQUAL "${STANDARD_VERSION}")
          if(NOT SELECT_PATCH_VERSION)
            set(SELECT_PATCH_FILE "${PATCH_FILE}")
            set(SELECT_PATCH_VERSION "${TRY_SELECT_PATCH_VERSION}")
          elseif(TRY_SELECT_PATCH_VERSION VERSION_GREATER SELECT_PATCH_VERSION)
            set(SELECT_PATCH_FILE "${PATCH_FILE}")
            set(SELECT_PATCH_VERSION "${TRY_SELECT_PATCH_VERSION}")
          endif()
        endif()
      endif()
    endforeach()
    if(SELECT_PATCH_FILE)
      set(${OUTPUT_VAR}
          "${SELECT_PATCH_FILE}"
          PARENT_SCOPE)
    endif()
  endif()
endfunction()

function(project_third_party_try_patch_file OUTPUT_VAR BASE_DIRECTORY PORT_PREFIX VERSION)
  if(CMAKE_CROSSCOMPILING)
    project_third_party_try_patch_file_internal(TRY_PATCH_FILE_PATH_CROSS "${BASE_DIRECTORY}" "${PORT_PREFIX}"
                                                "${VERSION}" ".cross.patch")
    if(TRY_PATCH_FILE_PATH_CROSS)
      file(SIZE "${TRY_PATCH_FILE_PATH_CROSS}" TRY_PATCH_FILE_SIZE_CROSS)
      # Valid patch file should contains "diff --git a/ b/" at least
      if(${TRY_PATCH_FILE_SIZE_CROSS} GREATER 16)
        set(${OUTPUT_VAR}
            "${TRY_PATCH_FILE_PATH_CROSS}"
            PARENT_SCOPE)
      endif()
      return()
    endif()
  endif()
  project_third_party_try_patch_file_internal(TRY_PATCH_FILE_PATH_HOST "${BASE_DIRECTORY}" "${PORT_PREFIX}"
                                              "${VERSION}" ".patch")
  if(TRY_PATCH_FILE_PATH_HOST)
    file(SIZE "${TRY_PATCH_FILE_PATH_HOST}" TRY_PATCH_FILE_SIZE_HOST)
    # Valid patch file should contains "diff --git a/ b/" at least
    if(${TRY_PATCH_FILE_SIZE_HOST} GREATER 16)
      set(${OUTPUT_VAR}
          "${TRY_PATCH_FILE_PATH_HOST}"
          PARENT_SCOPE)
    endif()
    return()
  endif()
endfunction()
