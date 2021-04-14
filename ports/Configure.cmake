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
  set(PROJECT_THIRD_PARTY_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_PLATFORM_NAME}")
endif()
set(PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}/Modules"
)
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

if(NOT EXISTS ${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR})
  file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR})
endif()

set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)
list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
list(PREPEND CMAKE_MODULE_PATH "${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR}")

unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_INCLUDE_DIRS)
unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES)
unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INTERFACE_LINK_NAMES)
unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COPY_EXECUTABLE_PATTERN)

find_package(Threads)

# Utility macros for build third party libraries
macro(project_third_party_append_build_shared_lib_var LISTNAME)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=YES")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=NO")
    endforeach()
  endif()
endmacro()

macro(project_third_party_append_build_static_lib_var LISTNAME)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=NO")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=YES")
    endforeach()
  endif()
endmacro()

macro(project_third_party_append_find_root_args VARNAME)
  string(REPLACE ";" "\\;" CMAKE_FIND_ROOT_PATH_AS_CMD_ARGS "${CMAKE_FIND_ROOT_PATH}")
  string(REPLACE ";" "\\;" CMAKE_PREFIX_PATH_AS_CMD_ARGS "${CMAKE_PREFIX_PATH}")

  list(APPEND ${VARNAME} "-DCMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH_AS_CMD_ARGS}"
       "-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_AS_CMD_ARGS}")

  unset(CMAKE_FIND_ROOT_PATH_AS_CMD_ARGS)
  unset(CMAKE_PREFIX_PATH_AS_CMD_ARGS)
endmacro()

file(SHA256 "${CMAKE_CURRENT_LIST_FILE}" project_third_party_get_build_dir_HASH)
string(SUBSTRING "${project_third_party_get_build_dir_HASH}" 0 8
                 project_third_party_get_build_dir_HASH)
if(DEFINED ENV{HOME})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{HOME}")
elseif(DEFINED ENV{USERPROFILE})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{USERPROFILE}")
elseif(DEFINED ENV{TEMP})
  set(project_third_party_get_build_dir_USER_BASE "$ENV{TEMP}")
endif()
string(REPLACE "\\" "/" project_third_party_get_build_dir_USER_BASE
               "${project_third_party_get_build_dir_USER_BASE}")
macro(project_third_party_get_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
  string(LENGTH "${PORT_VERSION}" project_third_party_get_build_dir_PORT_VERSION_LEN)
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES
                                                                       "[0-9A-Fa-f]+")
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
  if(project_third_party_get_build_dir_PORT_VERSION_LEN GREATER 12 AND PORT_VERSION MATCHES
                                                                       "[0-9A-Fa-f]+")
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
