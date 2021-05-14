include_guard(GLOBAL)

include(ProjectBuildTools)

# Migrate from PROJECT_3RD_PARTY_PACKAGE_DIR
if(NOT PROJECT_THIRD_PARTY_PACKAGE_DIR AND PROJECT_3RD_PARTY_PACKAGE_DIR)
  set(PROJECT_THIRD_PARTY_PACKAGE_DIR "${PROJECT_3RD_PARTY_PACKAGE_DIR}")
elseif(NOT PROJECT_THIRD_PARTY_PACKAGE_DIR)
  set(PROJECT_THIRD_PARTY_PACKAGE_DIR "${PROJECT_SOURCE_DIR}/third_party/packages")
endif()

# Migrate from PROJECT_3RD_PARTY_INSTALL_DIR
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR AND PROJECT_3RD_PARTY_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_INSTALL_DIR "${PROJECT_3RD_PARTY_INSTALL_DIR}")
elseif(NOT PROJECT_THIRD_PARTY_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_INSTALL_DIR "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_PLATFORM_NAME}")
endif()
if(NOT PROJECT_THIRD_PARTY_HOST_INSTALL_DIR)
  set(PROJECT_THIRD_PARTY_HOST_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}")
endif()

set(PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}/Modules")
if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR)
  if(WIN32)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR "dbt")
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR "dependency-buildtree")
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
list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
list(PREPEND CMAKE_MODULE_PATH "${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR}")

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

unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS)
unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES)
unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INTERFACE_LINK_NAMES)
unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN)

find_package(Threads)

# Utility macros for build third party libraries
macro(project_third_party_append_build_shared_lib_var LISTNAME)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=ON")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=OFF")
    endforeach()
  endif()
endmacro()

macro(project_third_party_append_build_static_lib_var LISTNAME)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=OFF")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=ON")
    endforeach()
  endif()
endmacro()

macro(project_third_party_append_find_root_args VARNAME)
  if(CMAKE_FIND_ROOT_PATH)
    list_append_unescape(${VARNAME} "-DCMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}")
  endif()
  if(CMAKE_PREFIX_PATH)
    list_append_unescape(${VARNAME} "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
  endif()
endmacro()

file(SHA256 "${CMAKE_CURRENT_LIST_FILE}" project_third_party_get_build_dir_HASH)
string(SUBSTRING "${project_third_party_get_build_dir_HASH}" 0 8 project_third_party_get_build_dir_HASH)
if(DEFINED ENV{HOME})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{HOME}")
elseif(DEFINED ENV{USERPROFILE})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{USERPROFILE}")
elseif(DEFINED ENV{TEMP})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{TEMP}")
endif()
string(REPLACE "\\" "/" project_third_party_get_build_dir_USER_BASE "${project_third_party_get_build_dir_USER_BASE}")
macro(project_third_party_get_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
  string(LENGTH "${PORT_VERSION}" project_third_party_get_build_dir_PORT_VERSION_LEN)
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES "[0-9A-Fa-f]+")
    string(SUBSTRING "${PORT_VERSION}" 0 12 project_third_party_get_build_dir_PORT_VERSION)
  else()
    set(project_third_party_get_build_dir_PORT_VERSION "${PORT_VERSION}")
  endif()

  if(WIN32
     AND NOT MINGW
     AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_USER_BASE}/cmake-toolset-${project_third_party_get_build_dir_HASH}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
    )
  else()
    set(${OUTPUT_VARNAME}
        "${CMAKE_CURRENT_BINARY_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
    )
  endif()
  unset(project_third_party_get_build_dir_PORT_VERSION_LEN)
  unset(project_third_party_get_build_dir_PORT_VERSION)
endmacro()

macro(project_third_party_get_host_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
  string(LENGTH "${PORT_VERSION}" project_third_party_get_build_dir_PORT_VERSION_LEN)
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES "[0-9A-Fa-f]+")
    string(SUBSTRING "${PORT_VERSION}" 0 12 project_third_party_get_build_dir_PORT_VERSION)
  else()
    set(project_third_party_get_build_dir_PORT_VERSION "${PORT_VERSION}")
  endif()

  if(WIN32
     AND NOT MINGW
     AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_USER_BASE}/cmake-toolset-${project_third_party_get_build_dir_HASH}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
    )
  else()
    set(${OUTPUT_VARNAME}
        "${CMAKE_CURRENT_BINARY_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
    )
  endif()
  unset(project_third_party_get_build_dir_PORT_VERSION_LEN)
  unset(project_third_party_get_build_dir_PORT_VERSION)
endmacro()

find_package(Git)
if(NOT GIT_FOUND AND NOT Git_FOUND)
  message(FATAL_ERROR "git is required to use ports")
endif()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_BASH)
  find_package(UnixCommands)
  if(BASH)
    set(ATFRAMEWORK_CMAKE_TOOLSET_BASH "${BASH}")
  elseif(WIN32)
    get_filename_component(GIT_EXECUTABLE_DIR "${GIT_EXECUTABLE}" DIRECTORY)
    get_filename_component(GIT_HOME_DIR "${GIT_EXECUTABLE_DIR}" DIRECTORY)

    set(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS
        "${GIT_EXECUTABLE_DIR}/bash.exe"
        "${GIT_EXECUTABLE_DIR}/sh.exe"
        "${GIT_EXECUTABLE_DIR}/bin/bash.exe"
        "${GIT_EXECUTABLE_DIR}/bin/sh.exe"
        "${GIT_EXECUTABLE_DIR}/usr/bin/bash.exe"
        "${GIT_EXECUTABLE_DIR}/usr/bin/sh.exe"
        "${GIT_EXECUTABLE_DIR}/usr/bin/dash.exe"
        "${GIT_HOME_DIR}/bin/bash.exe"
        "${GIT_HOME_DIR}/bin/sh.exe"
        "${GIT_HOME_DIR}/usr/bin/bash.exe"
        "${GIT_HOME_DIR}/usr/bin/sh.exe"
        "${GIT_HOME_DIR}/usr/bin/dash.exe")

    foreach(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_PATH ${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS})
      if(EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_PATH}")
        set(ATFRAMEWORK_CMAKE_TOOLSET_BASH "${ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_PATH}")
        break()
      endif()
    endforeach()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_BASH)
      message(FATAL_ERROR "bash is required to use ports")
    endif()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_PATH)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_BASH_TEST_DIRS)
  endif()
endif()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
  find_program(ATFRAMEWORK_CMAKE_TOOLSET_PWSH NAMES pwsh pwsh.exe pwsh-preview pwsh-preview.exe)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
    find_program(ATFRAMEWORK_CMAKE_TOOLSET_PWSH NAMES powershell powershell.exe)
  endif()
  set(ATFRAMEWORK_CMAKE_TOOLSET_PWSH
      "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}"
      CACHE FILEPATH "powershell PATH" FORCE)
  mark_as_advanced(ATFRAMEWORK_CMAKE_TOOLSET_PWSH)
endif()

function(project_third_party_generate_load_env_bash)
  project_build_tools_generate_load_env_bash(${ARGN})
endfunction()

function(project_third_party_generate_load_env_powershell)
  project_build_tool_generate_load_env_powershell(${ARGN})
endfunction()
