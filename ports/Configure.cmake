include_guard(GLOBAL)

include(ProjectBuildTools)

get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_DIR "${CMAKE_CURRENT_LIST_DIR}/../" ABSOLUTE CACHE)

option(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ENABLE_PACKAGE_REGISTRY "Enable export(PACKAGE)" OFF)
if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ENABLE_PACKAGE_REGISTRY)
  set(CMAKE_EXPORT_NO_PACKAGE_REGISTRY OFF)
  set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
else()
  set(CMAKE_EXPORT_NO_PACKAGE_REGISTRY ON)
  set(CMAKE_EXPORT_PACKAGE_REGISTRY OFF)
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
set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE
    OFF
    CACHE BOOL "Disable parallel building for some packages to reduce memory usage")

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
    list(PREPEND CMAKE_FIND_ROOT_PATH
         "${PROJECT_THIRD_PARTY_INSTALL_DIR};${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}/cmake")
  else()
    list(PREPEND CMAKE_FIND_ROOT_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  endif()
endif()
if(NOT PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR IN_LIST CMAKE_MODULE_PATH)
  list(PREPEND CMAKE_MODULE_PATH "${PROJECT_THIRD_PARTY_INSTALL_CMAKE_MODULE_DIR}")
endif()
if(NOT PROJECT_THIRD_PARTY_INSTALL_DIR IN_LIST CMAKE_PREFIX_PATH)
  if(ATFRAMEWORK_CMAKE_TOOLSET_TARGET_IS_WINDOWS)
    list(PREPEND CMAKE_PREFIX_PATH
         "${PROJECT_THIRD_PARTY_INSTALL_DIR};${PROJECT_THIRD_PARTY_INSTALL_DIR}/${CMAKE_INSTALL_DATADIR}/cmake")
  else()
    list(PREPEND CMAKE_PREFIX_PATH "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  endif()
endif()
if(UNIX)
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
macro(project_third_party_append_build_shared_lib_var PORT_NAME PORT_PREFIX LISTNAME)
  if(PORT_PREFIX AND NOT "${PORT_PREFIX}" STREQUAL "")
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_PREFIX}_${PORT_NAME}" FULL_PORT_NAME)
  else()
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_NAME}" FULL_PORT_NAME)
  endif()

  if((BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY) AND NOT ${FULL_PORT_NAME}_USE_STATIC)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=ON")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=OFF")
    endforeach()
  endif()

  unset(FULL_PORT_NAME)
endmacro()

macro(project_third_party_append_build_static_lib_var PORT_NAME PORT_PREFIX LISTNAME)
  if(PORT_PREFIX AND NOT "${PORT_PREFIX}" STREQUAL "")
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_PREFIX}_${PORT_NAME}" FULL_PORT_NAME)
  else()
    string(TOUPPER "ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_${PORT_NAME}" FULL_PORT_NAME)
  endif()

  if((BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY) AND NOT ${FULL_PORT_NAME}_USE_STATIC)
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=OFF")
    endforeach()
  else()
    foreach(VARNAME ${ARGN})
      list(APPEND ${LISTNAME} "-D${VARNAME}=ON")
    endforeach()
  endif()

  unset(FULL_PORT_NAME)
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

if(NOT project_third_party_get_build_dir_HASH)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -n 1 "--format=%H" --encoding=UTF-8
    WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_DIR}"
    OUTPUT_VARIABLE project_third_party_get_build_dir_HASH)
endif()

if(NOT project_third_party_get_build_dir_HASH)
  file(SHA256 "${CMAKE_CURRENT_LIST_FILE}" project_third_party_get_build_dir_HASH)
endif()
string(SUBSTRING "${project_third_party_get_build_dir_HASH}" 0 8 project_third_party_get_build_dir_HASH)
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
endif()

function(project_third_party_get_build_dir OUTPUT_VARNAME PORT_NAME PORT_VERSION)
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
        "${project_third_party_get_build_dir_USER_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VARNAME}
        "${CMAKE_CURRENT_BINARY_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_PLATFORM_NAME}"
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

  if(WIN32
     AND NOT MINGW
     AND NOT CYGWIN)
    set(${OUTPUT_VARNAME}
        "${project_third_party_get_build_dir_USER_BASE}/cmake-toolset/${project_third_party_get_build_dir_HASH}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VARNAME}
        "${CMAKE_CURRENT_BINARY_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BUILDTREE_DIR}/${PORT_NAME}-${project_third_party_get_build_dir_PORT_VERSION}/${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
        PARENT_SCOPE)
  endif()
endfunction()

function(project_third_party_cleanup_old_build_tree BASE_DIR)
  file(GLOB project_third_party_old_build_dirs "${BASE_DIR}/cmake-toolset/*" "${BASE_DIR}/cmake-toolset-*")

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
  set(multiValueArgs BUILD_OPTIONS PATCH_FILE)
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
            ${${FULL_PORT_NAME}_BUILD_OPTIONS} ${project_third_party_port_declare_BUILD_OPTIONS}
            ${${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS}
            PARENT_SCOPE)
      else()
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            ${${FULL_PORT_NAME}_BUILD_OPTIONS} ${project_third_party_port_declare_BUILD_OPTIONS}
            PARENT_SCOPE)
      endif()
    else()
      if(${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS)
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            ${project_third_party_port_declare_BUILD_OPTIONS} ${${FULL_PORT_NAME}_APPEND_DEFAULT_BUILD_OPTIONS}
            PARENT_SCOPE)
      else()
        set(${FULL_PORT_NAME}_BUILD_OPTIONS
            ${project_third_party_port_declare_BUILD_OPTIONS}
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
    if(DEFINED CACHE{${FULL_PORT_NAME}_USE_STATIC})
      set(${FULL_PORT_NAME}_USE_STATIC
          $CACHE{${FULL_PORT_NAME}_USE_STATIC}
          PARENT_SCOPE)
    elseif(DEFINED ENV{${FULL_PORT_NAME}_USE_STATIC})
      set(${FULL_PORT_NAME}_USE_STATIC
          $ENV{${FULL_PORT_NAME}_USE_STATIC}
          PARENT_SCOPE)
    else()
      set(${FULL_PORT_NAME}_USE_STATIC
          FALSE
          PARENT_SCOPE)
    endif()
  endif()

  unset(FULL_PORT_NAME)
endfunction()
