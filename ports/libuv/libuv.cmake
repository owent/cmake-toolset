include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_LIBUV_IMPORT)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET uv)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET uv_a)
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET uv_a)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET uv)
  endif()
  if(TARGET ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET})
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): libuv using target: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET}")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET})
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS
                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES
                                              ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET})
  elseif(TARGET libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET})
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): libuv using target: libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET}"
    )
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME
        libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET})
    get_target_property(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS
      libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES
                                              libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PREFER_TARGET})
  elseif(TARGET ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET})
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): libuv using target: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET}"
    )
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET})
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS
                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES
                                              ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET})
  elseif(TARGET libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET})
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): libuv using target: libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET}"
    )
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME
        libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET})
    get_target_property(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS
      libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET} INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES
                                              libuv::${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_FALLBACK_TARGET})
  elseif(TARGET libuv)
    message(STATUS "Dependency(${PROJECT_NAME}): libuv using target: libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS libuv INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES libuv)
  elseif(TARGET libuv::libuv)
    message(STATUS "Dependency(${PROJECT_NAME}): libuv using target: libuv::libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv::libuv)
    get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS libuv::libuv
                        INTERFACE_INCLUDE_DIRECTORIES)
    project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES libuv::libuv)
  elseif(Libuv_FOUND OR LIBUV_FOUND)
    add_library(libuv UNKNOWN IMPORTED)
    if(Libuv_INCLUDE_DIRS)
      set_target_properties(libuv PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${Libuv_INCLUDE_DIRS})
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS "${Libuv_INCLUDE_DIRS}")
    elseif(LIBUV_INCLUDE_DIRS)
      set_target_properties(libuv PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${LIBUV_INCLUDE_DIRS})
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS "${LIBUV_INCLUDE_DIRS}")
    endif()
    if(Libuv_LIBRARIES)
      set_target_properties(libuv PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX;RC" IMPORTED_LOCATION
                                                                                          "${Libuv_LIBRARIES}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES "${Libuv_LIBRARIES}")
    elseif(LIBUV_LIBRARIES)
      set_target_properties(libuv PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX;RC" IMPORTED_LOCATION
                                                                                          "${LIBUV_LIBRARIES}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES "${LIBUV_LIBRARIES}")
    endif()
    message(STATUS "Dependency(${PROJECT_NAME}): libuv create target: libuv")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME libuv)

    if(WIN32)
      set_target_properties(libuv PROPERTIES INTERFACE_LINK_LIBRARIES "psapi;user32;advapi32;iphlpapi;userenv;ws2_32")
    else()
      unset(uv_libraries)
      if(NOT CMAKE_SYSTEM_NAME MATCHES "Android|OS390")
        list(APPEND uv_libraries pthread)
      endif()
      if(CMAKE_SYSTEM_NAME STREQUAL "AIX")
        list(APPEND uv_libraries perfstat)
      endif()
      if(CMAKE_SYSTEM_NAME STREQUAL "Android")
        list(APPEND uv_libraries dl)
      endif()
      if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        list(APPEND uv_libraries dl rt)
      endif()
      if(CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
        list(APPEND uv_libraries kvm)
      endif()
      if(CMAKE_SYSTEM_NAME STREQUAL "OS390")
        list(APPEND uv_libraries -Wl,xplink)
      endif()
      if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
        list(APPEND uv_libraries kstat nsl sendfile socket)
      endif()
      if(uv_libraries)
        set_target_properties(libuv PROPERTIES INTERFACE_LINK_LIBRARIES "${uv_libraries}")
        unset(uv_libraries)
      endif()
    endif()
  else()
    message(STATUS "Dependency(${PROJECT_NAME}): Libuv support disabled")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES AND Libuv_LIBRARIES)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES "${Libuv_LIBRARIES}")
  endif()
endmacro()

# =========== third party libuv ==================
if(NOT TARGET uv_a
   AND NOT TARGET uv
   AND NOT TARGET libuv
   AND NOT Libuv_FOUND
   AND NOT LIBUV_FOUND)
  if(VCPKG_TOOLCHAIN)
    find_package(Libuv QUIET)
  endif()

  if(NOT TARGET uv_a
     AND NOT TARGET uv
     AND NOT TARGET libuv
     AND NOT Libuv_FOUND
     AND NOT LIBUV_FOUND)

    project_third_party_port_declare(
      libuv
      VERSION
      "v1.44.2"
      GIT_URL
      "https://github.com/libuv/libuv.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DBUILD_TESTING=OFF")

    project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS)

    project_third_party_append_build_shared_lib_var(
      "libuv" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS BUILD_SHARED_LIBS)

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "libuv"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS GIT_PATCH_FILES
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_PATCH_FILE})
    endif()

    set(Libuv_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
    find_configure_package(
      PACKAGE
      Libuv
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "libuv-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_GIT_URL}")

    if(NOT Libuv_FOUND)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
        project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_BUILD_DIR}")
      endif()
      echowithcolor(
        COLOR
        RED
        "-- Dependency(${PROJECT_NAME}): Libuv is required, we can not find prebuilt for libuv and can not find git to clone the sources"
      )
      message(FATAL_ERROR "Libuv not found")
    endif()
  endif()
  project_third_party_libuv_import()
else()
  project_third_party_libuv_import()
endif()
