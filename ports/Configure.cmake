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

# Migrate from PROJECT_3RD_PARTY_PACKAGE_DIR
if(NOT PROJECT_THIRD_PARTY_PACKAGE_DIR AND PROJECT_3RD_PARTY_PACKAGE_DIR)
  set(PROJECT_THIRD_PARTY_PACKAGE_DIR
      "${PROJECT_3RD_PARTY_PACKAGE_DIR}"
      CACHE PATH "Where to store packages for third party packages")
elseif(NOT PROJECT_THIRD_PARTY_PACKAGE_DIR)
  if(WIN32
     AND NOT MINGW
     AND NOT CYGWIN)
    set(PROJECT_THIRD_PARTY_PACKAGE_DIR
        "${project_third_party_get_build_dir_SELECT_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/packages"
        CACHE PATH "Where to store packages for third party packages")
  else()
    set(PROJECT_THIRD_PARTY_PACKAGE_DIR
        "${PROJECT_SOURCE_DIR}/third_party/packages"
        CACHE PATH "Where to store packages for third party packages")
  endif()
endif()

# Sanitizer options
project_build_tools_sanitizer_use_static(PROJECT_COMPILER_OPTIONS_SANITIZER_USE_STATIC)
project_build_tools_sanitizer_use_shared(PROJECT_COMPILER_OPTIONS_SANITIZER_USE_SHARED)
project_build_tools_sanitizer_get_name(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER ${CMAKE_CXX_FLAGS}
                                       ${CMAKE_C_FLAGS})
if(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER STREQUAL "address")
  set(PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX "-asan")
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    set(ENV{ASAN_OPTIONS}
        "detect_leaks=0:detect_deadlocks=false:report_globals=0:detect_container_overflow=false:log_path=/dev/null")
  else()
    set(ENV{ASAN_OPTIONS} "detect_leaks=0:detect_deadlocks=false:report_globals=0:detect_container_overflow=false")
  endif()
elseif(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER STREQUAL "memory")
  set(PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX "-msan")
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    set(ENV{ASAN_OPTIONS}
        "detect_leaks=0:detect_deadlocks=false:report_globals=0:detect_container_overflow=false:log_path=/dev/null")
  else()
    set(ENV{ASAN_OPTIONS} "detect_leaks=0:detect_deadlocks=false:report_globals=0:detect_container_overflow=false")
  endif()
elseif(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER STREQUAL "undefined")
  set(PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX "-ubsan")
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    set(ENV{UBSAN_OPTIONS} "log_path=/dev/null")
  endif()
elseif(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER STREQUAL "thread")
  set(PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX "-tsan")
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    set(ENV{TSAN_OPTIONS} "report_bugs=0:log_path=/dev/null")
  else()
    set(ENV{TSAN_OPTIONS} "report_bugs=0")
  endif()
elseif(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER STREQUAL "hwaddress")
  set(PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX "-hwasan")
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    set(ENV{ASAN_OPTIONS}
        "detect_leaks=0:detect_deadlocks=false:report_globals=0:detect_container_overflow=false:log_path=/dev/null")
  else()
    set(ENV{ASAN_OPTIONS} "detect_leaks=0:detect_deadlocks=false:report_globals=0:detect_container_overflow=false")
  endif()
elseif(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER STREQUAL "dataflow")
  set(PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX "-dfsan")
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    set(ENV{DFSAN_OPTIONS} "log_path=/dev/null")
  endif()
endif()

if(PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER)
  if(PROJECT_COMPILER_OPTIONS_SANITIZER_USE_STATIC)
    project_build_tools_sanitizer_try_get_static_link(PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE
                                                      ${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS})
    add_linker_flags_for_runtime_inherit("${PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE}")
  else()
    project_build_tools_sanitizer_try_get_shared_link(PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE
                                                      ${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS})
    add_compiler_flags_to_inherit_var_unique(CMAKE_EXE_LINKER_FLAGS
                                             "${PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE}")
  endif()
endif()

if(CMAKE_CROSSCOMPILING)
  project_build_tools_sanitizer_get_name(
    PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER ${COMPILER_OPTION_INHERIT_CMAKE_CXX_FLAGS}
    ${COMPILER_OPTION_INHERIT_CMAKE_C_FLAGS})
  if(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER STREQUAL "address")
    set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "-asan")
  elseif(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER STREQUAL "memory")
    set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "-msan")
  elseif(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER STREQUAL "undefined")
    set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "-ubsan")
  elseif(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER STREQUAL "thread")
    set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "-tsan")
  elseif(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER STREQUAL "hwaddress")
    set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "-hwasan")
  elseif(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER STREQUAL "dataflow")
    set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "-dfsan")
  endif()

  if(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER)
    if(PROJECT_COMPILER_OPTIONS_SANITIZER_USE_STATIC)
      project_build_tools_sanitizer_try_get_static_link(PROJECT_COMPILER_OPTIONS_HOST_SANITIZER_USE_LINK_TYPE
                                                        ${CMAKE_HOST_CXX_FLAGS} ${CMAKE_HOST_C_FLAGS})
      add_compiler_flags_to_inherit_var_unique(CMAKE_HOST_EXE_LINKER_FLAGS
                                               "${PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE}")
      add_compiler_flags_to_inherit_var_unique(CMAKE_HOST_MODULE_LINKER_FLAGS
                                               "${PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE}")
      add_compiler_flags_to_inherit_var_unique(CMAKE_HOST_SHARED_LINKER_FLAGS
                                               "${PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE}")
    else()
      project_build_tools_sanitizer_try_get_shared_link(PROJECT_COMPILER_OPTIONS_HOST_SANITIZER_USE_LINK_TYPE
                                                        ${CMAKE_HOST_CXX_FLAGS} ${CMAKE_HOST_C_FLAGS})
      add_compiler_flags_to_inherit_var_unique(CMAKE_HOST_EXE_LINKER_FLAGS
                                               "${PROJECT_COMPILER_OPTIONS_HOST_SANITIZER_USE_LINK_TYPE}")
    endif()
  endif()
else()
  set(PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER "${PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER}")
  set(PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX "${PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX}")
  set(PROJECT_COMPILER_OPTIONS_HOST_SANITIZER_USE_LINK_TYPE
      "${PROJECT_COMPILER_OPTIONS_TARGET_SANITIZER_USE_LINK_TYPE}")
endif()

# Migrate from PROJECT_3RD_PARTY_INSTALL_DIR
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR AND PROJECT_3RD_PARTY_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_INSTALL_DIR
      "${PROJECT_3RD_PARTY_INSTALL_DIR}"
      CACHE PATH "Where to install packages for third party packages")
elseif(NOT PROJECT_THIRD_PARTY_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_PLATFORM_NAME}${PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX}"
      CACHE PATH "Where to install packages for third party packages")
endif()
if(NOT PROJECT_THIRD_PARTY_HOST_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_HOST_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}${PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX}"
  )
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
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS
    "2"
    CACHE STRING "Parallel building jobs when low memory mode")
# ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS is not allowed to be empty
if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS OR ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS}
                                                                LESS 1)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS
      "2"
      CACHE STRING "Parallel building jobs when low memory mode" FORCE)
endif()

if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
  if(DEFINED ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE})
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE "$ENV{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE}")
  endif()
endif()

if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG)
  if(DEFINED ENV{ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG})
    set(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG "$ENV{ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG}")
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    set(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG TRUE)
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_PACKAGE_PATCH_LOG FALSE)
  endif()
endif()

if(NOT EXISTS ${PROJECT_THIRD_PARTY_PACKAGE_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_PACKAGE_DIR})
endif()

if(NOT EXISTS ${PROJECT_THIRD_PARTY_INSTALL_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_DIR})
endif()

if(NOT CMAKE_BUILD_RPATH)
  add_list_flags_to_inherit_var(CMAKE_BUILD_RPATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64"
                                "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")

  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    add_compiler_flags_to_inherit_var_unique(
      CMAKE_EXE_LINKER_FLAGS
      "-Wl,-rpath-link,${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")
    add_compiler_flags_to_inherit_var_unique(
      CMAKE_MODULE_LINKER_FLAGS
      "-Wl,-rpath-link,${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")
    add_compiler_flags_to_inherit_var_unique(
      CMAKE_SHARED_LINKER_FLAGS
      "-Wl,-rpath-link,${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64:${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")
  endif()
else()
  if(ANDROID OR CMAKE_SYSTEM_NAME MATCHES "Linux|Android")
    add_compiler_flags_to_inherit_var_unique(CMAKE_EXE_LINKER_FLAGS "-Wl,-rpath-link,${CMAKE_BUILD_RPATH}")
    add_compiler_flags_to_inherit_var_unique(CMAKE_MODULE_LINKER_FLAGS "-Wl,-rpath-link,${CMAKE_BUILD_RPATH}")
    add_compiler_flags_to_inherit_var_unique(CMAKE_SHARED_LINKER_FLAGS "-Wl,-rpath-link,${CMAKE_BUILD_RPATH}")
  endif()
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
    prepend_list_flags_to_inherit_var_unique(
      CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/cmake"
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}"
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}/cmake")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      prepend_list_flags_to_inherit_var_unique(CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64/cmake"
                                               "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/cmake")
    else()
      prepend_list_flags_to_inherit_var_unique(CMAKE_FIND_ROOT_PATH
                                               "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake")
    endif()
  else()
    prepend_list_flags_to_inherit_var_unique(CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  endif()
endif()
if(NOT PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR IN_LIST CMAKE_MODULE_PATH)
  prepend_list_flags_to_inherit_var_unique(CMAKE_MODULE_PATH "${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR}")
endif()
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR IN_LIST CMAKE_PREFIX_PATH)
  if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
    prepend_list_flags_to_inherit_var_unique(
      CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/cmake"
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}"
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}/cmake")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
      prepend_list_flags_to_inherit_var_unique(CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib64/cmake"
                                               "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/cmake")
    else()
      prepend_list_flags_to_inherit_var_unique(CMAKE_PREFIX_PATH
                                               "${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake")
    endif()
  else()
    prepend_list_flags_to_inherit_var_unique(CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
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
  foreach(VAR_NAME IN LISTS PROJECT_BUILD_TOOLS_CMAKE_FIND_ROOT_VARS)
    if(${VAR_NAME})
      message(STATUS "cmake-toolset: ${VAR_NAME}=${${VAR_NAME}}")
    endif()
  endforeach()
  if(CMAKE_CROSSCOMPILING)
    message(STATUS "cmake-toolset: CMAKE_PROGRAM_PATH=${CMAKE_PROGRAM_PATH}")
  endif()
  if(UNIX)
    message(STATUS "cmake-toolset: ENV{PKG_CONFIG_PATH}=$ENV{PKG_CONFIG_PATH}")
  endif()
  if(VCPKG_TOOLCHAIN)
    if(VCPKG_INSTALLED_DIR)
      message(STATUS "cmake-toolset: VCPKG_INSTALLED_DIR=${VCPKG_INSTALLED_DIR}")
    endif()
    if(Z_VCPKG_ROOT_DIR)
      message(STATUS "cmake-toolset: Z_VCPKG_ROOT_DIR=${Z_VCPKG_ROOT_DIR}")
    endif()
    if(VCPKG_TARGET_TRIPLET)
      message(STATUS "cmake-toolset: VCPKG_TARGET_TRIPLET=${VCPKG_TARGET_TRIPLET}")
    endif()
    if(VCPKG_HOST_TRIPLET)
      message(STATUS "cmake-toolset: VCPKG_HOST_TRIPLET=${VCPKG_HOST_TRIPLET}")
    endif()
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

# reset LD_LIBRARY_PATH may lead to conflict when external tools depends on our ports when ours are built with sanitizer
if(NOT ((CMAKE_CROSSCOMPILING AND PROJECT_COMPILER_OPTIONS_HOST_USE_SANITIZER)
        OR PROJECT_COMPILER_OPTIONS_TARGET_USE_SANITIZER))
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
endif()

# Can not append PATH when corssing compiling, CMAKE_USE_SYSTEM_ENVIRONMENT_PATH will cause a invalid arch searching.
if(NOT CMAKE_CROSSCOMPILING)
  set(ENV{PATH}
      "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/bin${PROJECT_THIRD_PARTY_PATH_SEPARATOR}${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/libexec${PROJECT_THIRD_PARTY_PATH_SEPARATOR}$ENV{PATH}"
  )
endif()

set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads)
if(CMAKE_USE_PTHREADS_INIT OR ATFRAMEWORK_CMAKE_TOOLSET_TEST_FLAG_PTHREAD)
  add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS "-pthread")
  add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS "-pthread")
  add_compiler_flags_to_inherit_var_unique(CMAKE_SHARED_LINKER_FLAGS "-pthread")
  add_compiler_flags_to_inherit_var_unique(CMAKE_MODULE_LINKER_FLAGS "-pthread")
  add_compiler_flags_to_inherit_var_unique(CMAKE_EXE_LINKER_FLAGS "-pthread")
endif()

# Max for two core when low memory detected
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE AND NOT PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD)
  set(PROJECT_FIND_CONFIGURE_PACKAGE_PARALLEL_BUILD ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS})
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
  foreach(_find_root_VAR IN LISTS PROJECT_BUILD_TOOLS_CMAKE_FIND_ROOT_VARS)
    if(${_find_root_VAR})
      list_append_unescape(${VARNAME} "-D${_find_root_VAR}=${${_find_root_VAR}}")
    endif()
  endforeach()
endmacro()

function(project_third_party_get_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
  string(LENGTH "${PORT_VERSION}" project_third_party_get_build_dir_PORT_VERSION_LEN)
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES "[0-9A-Fa-f]+")
    string(SUBSTRING "${PORT_VERSION}" 0 12 project_third_party_get_build_dir_PORT_VERSION)
  else()
    set(project_third_party_get_build_dir_PORT_VERSION "${PORT_VERSION}")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR)
    set(${OUTPUT_VARNAME}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}${PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX}"
        PARENT_SCOPE)
  elseif(
    WIN32
    AND NOT MINGW
    AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_SELECT_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/build/${PORT_NAME}/${PROJECT_PREBUILT_PLATFORM_NAME}${PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX}"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VARNAME}
        "${CMAKE_BINARY_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}${PROJECT_THIRD_PARTY_INSTALL_DEFAULT_SUFFIX}"
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
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}${PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX}"
        PARENT_SCOPE)
  elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR)
    set(${OUTPUT_VARNAME}
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}${PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX}"
        PARENT_SCOPE)
  elseif(
    WIN32
    AND NOT MINGW
    AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_SELECT_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/build/${PORT_NAME}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}${PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX}"
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
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}${PROJECT_THIRD_PARTY_HOST_INSTALL_DEFAULT_SUFFIX}"
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
  atframework_cmake_toolset_find_pwsh_tools()
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
      if(PATCH_FILE_BASE_NAME MATCHES "^${PORT_PREFIX}-(v)?([0-9]+.*)${SUFFIX_REGEX}")
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

function(project_third_party_crosscompiling_host PORT_NAME HOST_PROJECT_SOURCE_DIRECTORY)
  if(ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING)
    return()
  endif()

  set(optionArgs "")
  set(oneValueArgs VERSION PORT_PREFIX RESULT_VARIABLE)
  set(multiValueArgs TEST_PATH TEST_PROGRAM)
  cmake_parse_arguments(project_third_party_crosscompiling_host "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}"
                        "${ARGN}")

  if(project_third_party_crosscompiling_host_PORT_PREFIX)
    string(
      TOUPPER
        "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${project_third_party_crosscompiling_host_PORT_PREFIX}_${PORT_NAME}"
        FULL_PORT_NAME)
  else()
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_NAME}" FULL_PORT_NAME)
  endif()
  string(REGEX REPLACE "[-\\.]" "_" FULL_PORT_NAME "${FULL_PORT_NAME}")

  if(NOT project_third_party_crosscompiling_host_VERSION AND ${FULL_PORT_NAME}_VERSION)
    set(project_third_party_crosscompiling_host_VERSION "${${FULL_PORT_NAME}_VERSION}")
  endif()

  set(HOST_PREBUILT_EXISTED FALSE)
  foreach(CHECK_PATH ${project_third_party_crosscompiling_host_TEST_PATH})
    if(EXISTS "${CHECK_PATH}")
      set(HOST_PREBUILT_EXISTED TRUE)
      break()
    elseif(NOT IS_ABSOLUTE "${CHECK_PATH}" AND EXISTS "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/${CHECK_PATH}")
      set(HOST_PREBUILT_EXISTED TRUE)
      break()
    endif()
  endforeach()
  if(NOT HOST_PREBUILT_EXISTED AND project_third_party_crosscompiling_host_TEST_PROGRAM)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.21")
      find_program(
        HOST_PREBUILT_PORGRAM_EXISTED
        NAMES ${project_third_party_crosscompiling_host_TEST_PROGRAM}
        PATHS "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}" NO_CACHE
        NO_DEFAULT_PATH)
      if(HOST_PREBUILT_PORGRAM_EXISTED)
        set(HOST_PREBUILT_EXISTED TRUE)
      endif()
    else()
      foreach(TEST_PROGRAM ${project_third_party_crosscompiling_host_TEST_PROGRAM})
        find_program(
          project_third_party_crosscompiling_host_HOST_PREBUILT_PORGRAM_${TEST_PROGRAM}
          NAMES "${TEST_PROGRAM}"
          PATHS "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
          NO_DEFAULT_PATH)
        if(project_third_party_crosscompiling_host_HOST_PREBUILT_PORGRAM_${TEST_PROGRAM})
          set(HOST_PREBUILT_EXISTED TRUE)
        endif()
      endforeach()
    endif()
  endif()
  if(HOST_PREBUILT_EXISTED)
    if(project_third_party_crosscompiling_host_RESULT_VARIABLE)
      set(${project_third_party_crosscompiling_host_RESULT_VARIABLE}
          ${BUILD_RESULT_CODE}
          PARENT_SCOPE)
    endif()
    return()
  endif()

  project_third_party_get_host_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_DIR
                                         "${PORT_NAME}" ${project_third_party_crosscompiling_host_VERSION})
  file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_DIR}")
  get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR
                         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_DIR}" DIRECTORY)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}/crosscompiling-${PORT_NAME}-host")
  file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}")
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS "${CMAKE_COMMAND}"
                                                                            "${HOST_PROJECT_SOURCE_DIRECTORY}")
  message(
    STATUS
      "Dependency(${PROJECT_NAME}): Try to build ${PORT_NAME} fo host architecture(${PROJECT_PREBUILT_HOST_PLATFORM_NAME}@${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR})"
  )
  project_build_tools_append_cmake_host_options(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS)
  # Vcpkg
  if(DEFINED VCPKG_HOST_CRT_LINKAGE)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS
         "-DVCPKG_CRT_LINKAGE=${VCPKG_HOST_CRT_LINKAGE}")
  elseif(DEFINED VCPKG_CRT_LINKAGE)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS
         "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}")
  endif()
  # Shared or static
  project_third_party_append_build_shared_lib_var(
    "${PORT_NAME}" "${project_third_party_crosscompiling_host_PORT_PREFIX}"
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS BUILD_SHARED_LIBS)

  # cmake-toolset
  list(
    APPEND
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS
    "-DPROJECT_THIRD_PARTY_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
    "-DPROJECT_THIRD_PARTY_HOST_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
    "-DPROJECT_THIRD_PARTY_PACKAGE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}"
    "-DATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING=ON")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS
         "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILD_DIR=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_HOST_BUILD_DIR}")
  endif()
  if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE)
    list(
      APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS
      "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE}"
    )
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS_PWSH)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS_BASH)
  foreach(CMD_ARG IN LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS)
    # string(REPLACE ";" "\\;" CMD_ARG_UNESCAPE "${CMD_ARG}")
    set(CMD_ARG_UNESCAPE "${CMD_ARG}")
    add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS_PWSH
                              "\"${CMD_ARG_UNESCAPE}\"")
    string(REPLACE "\$" "\\\$" CMD_ARG_UNESCAPE "${CMD_ARG_UNESCAPE}")
    add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_BUILD_FLAGS_BASH
                              "\"${CMD_ARG_UNESCAPE}\"")
  endforeach()
  unset(CMD_ARG_UNESCAPE)

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH
     OR CMAKE_HOST_UNIX
     OR MSYS)
    configure_file(
      "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/crosscompiling/run-build-host.sh.in"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}/run-build-host.sh" @ONLY
      NEWLINE_STYLE LF)

    # build
    execute_process(
      COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}/run-build-host.sh"
      RESULT_VARIABLE BUILD_RESULT_CODE
      WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}"
                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
  else()
    configure_file(
      "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/crosscompiling/run-build-host.ps1.in"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}/run-build-host.ps1" @ONLY
      NEWLINE_STYLE CRLF)
    configure_file(
      "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/modules/crosscompiling/run-build-host.bat.in"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}/run-build-host.bat" @ONLY
      NEWLINE_STYLE CRLF)

    # build
    execute_process(
      COMMAND
        "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass -NonInteractive -NoLogo
        -File "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}/run-build-host.ps1"
      RESULT_VARIABLE BUILD_RESULT_CODE
      WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CROSSCOMPILING_HOST_TOOL_BUILD_DIR}"
                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
  endif()
  if(project_third_party_crosscompiling_host_RESULT_VARIABLE)
    set(${project_third_party_crosscompiling_host_RESULT_VARIABLE}
        ${BUILD_RESULT_CODE}
        PARENT_SCOPE)
  endif()
endfunction()

macro(project_third_party_include_lock BASE_DIR PATH)
  cmake_parse_arguments(project_third_party_include_lock "" "TIMEOUT" "" ${ARGN})
  if(NOT project_third_party_include_lock_TIMEOUT)
    set(project_third_party_include_lock_TIMEOUT 7200)
  endif()

  if(NOT project_third_party_include_lock_DEPTH)
    set(project_third_party_include_lock_DEPTH 0)
  endif()
  math(EXPR project_third_party_include_lock_DEPTH "${project_third_party_include_lock_DEPTH}+1" OUTPUT_FORMAT DECIMAL)

  get_filename_component(
    LOCK_FILE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/custom/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}"
    DIRECTORY)
  if(NOT EXISTS "${LOCK_FILE_DIRECTORY}")
    file(MAKE_DIRECTORY "${LOCK_FILE_DIRECTORY}")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING)
    file(
      LOCK "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/custom/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}.lock"
      GUARD PROCESS
      RESULT_VARIABLE project_third_party_include_lock_${project_third_party_include_lock_DEPTH}_LOCK_RESULT
      TIMEOUT ${project_third_party_include_lock_TIMEOUT})
  endif()

  include("${BASE_DIR}/${PATH}")

  # Unlock
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING)
    if(project_third_party_include_lock_${project_third_party_include_lock_DEPTH}_LOCK_RESULT EQUAL 0)
      file(LOCK "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/custom/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}.lock" RELEASE)
      file(REMOVE "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/custom/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}.lock")
    endif()
  endif()

  math(EXPR project_third_party_include_lock_DEPTH "${project_third_party_include_lock_DEPTH}-1" OUTPUT_FORMAT DECIMAL)
endmacro()

macro(project_third_party_include_port PATH)
  cmake_parse_arguments(project_third_party_include_port "" "TIMEOUT" "" ${ARGN})
  if(NOT project_third_party_include_port_TIMEOUT)
    set(project_third_party_include_port_TIMEOUT 7200)
  endif()

  if(NOT project_third_party_include_port_DEPTH)
    set(project_third_party_include_port_DEPTH 0)
  endif()
  math(EXPR project_third_party_include_port_DEPTH "${project_third_party_include_port_DEPTH}+1" OUTPUT_FORMAT DECIMAL)

  get_filename_component(
    LOCK_FILE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/ports/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}"
    DIRECTORY)
  if(NOT EXISTS "${LOCK_FILE_DIRECTORY}")
    file(MAKE_DIRECTORY "${LOCK_FILE_DIRECTORY}")
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING)
    file(
      LOCK "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/ports/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}.lock"
      GUARD PROCESS
      RESULT_VARIABLE project_third_party_include_port_${project_third_party_include_port_DEPTH}_LOCK_RESULT
      TIMEOUT ${project_third_party_include_port_TIMEOUT})
  endif()

  include("${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/ports/${PATH}")

  # Unlock
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING)
    if(project_third_party_include_port_${project_third_party_include_port_DEPTH}_LOCK_RESULT EQUAL 0)
      file(LOCK "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/ports/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}.lock" RELEASE)
      file(REMOVE "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}/.lock/ports/${PROJECT_PREBUILT_PLATFORM_NAME}/${PATH}.lock")
    endif()
  endif()

  math(EXPR project_third_party_include_port_DEPTH "${project_third_party_include_port_DEPTH}-1" OUTPUT_FORMAT DECIMAL)
endmacro()

message(STATUS "cmake-toolset: Configure for third party ports done.")
