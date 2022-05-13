include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LUA_IMPORT)
  if(TARGET lua::liblua-dynamic)
    message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua::liblua-dynamic")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua::liblua-dynamic)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua-dynamic)
    endif()
  elseif(TARGET lua::liblua-static)
    message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua::liblua-static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua::liblua-static)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua-static)
    endif()
  elseif(TARGET lua::liblua)
    message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua::liblua")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua::liblua)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua)
    endif()
  elseif(TARGET unofficial-lua::lua)
    message(STATUS "Dependency(${PROJECT_NAME}): Lua found target unofficial-lua::lua")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME unofficial-lua::lua)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES unofficial-lua::lua)
    endif()
  elseif(TARGET lua)
    message(STATUS "Dependency(${PROJECT_NAME}): Lua found target lua")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua)
  elseif(LUA_FOUND)
    add_library(lua::liblua UNKNOWN IMPORTED)
    set_target_properties(lua::liblua PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${LUA_INCLUDE_DIR}")
    set_target_properties(lua::liblua PROPERTIES IMPORTED_LOCATION "${LUA_LIBRARIES}")

    if(ANDROID)
      list(APPEND PROJECT_THIRD_PARTY_LUA_LIB_DEPEND_LIBS "log" "m" "c")
    elseif(UNIX)
      set(PROJECT_THIRD_PARTY_LUA_TEST_BACKUP_CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES})

      set(CMAKE_REQUIRED_LIBRARIES "${PROJECT_THIRD_PARTY_LUA_TEST_BACKUP_CMAKE_REQUIRED_LIBRARIES};m")
      check_cxx_source_compiles("#include <cstdio>
    int main() { return 0; }" PROJECT_THIRD_PARTY_LUA_TEST_LINK_M)
      if(PROJECT_THIRD_PARTY_LUA_TEST_LINK_M)
        list(APPEND PROJECT_THIRD_PARTY_LUA_LIB_DEPEND_LIBS "m")
      endif()

      set(CMAKE_REQUIRED_LIBRARIES "${PROJECT_THIRD_PARTY_LUA_TEST_BACKUP_CMAKE_REQUIRED_LIBRARIES};dl")
      check_cxx_source_compiles("#include <cstdio>
    int main() { return 0; }" PROJECT_THIRD_PARTY_LUA_TEST_LINK_DL)
      if(PROJECT_THIRD_PARTY_LUA_TEST_LINK_DL)
        list(APPEND PROJECT_THIRD_PARTY_LUA_LIB_DEPEND_LIBS "dl")
      endif()
    endif()

    if(PROJECT_THIRD_PARTY_LUA_LIB_DEPEND_LIBS)
      set_target_properties(lua::liblua PROPERTIES INTERFACE_LINK_LIBRARIES
                                                   "${PROJECT_THIRD_PARTY_LUA_LIB_DEPEND_LIBS}")
    endif()

    unset(PROJECT_THIRD_PARTY_LUA_TEST_BACKUP_CMAKE_REQUIRED_LIBRARIES)
    unset(PROJECT_THIRD_PARTY_LUA_LIB_DEPEND_LIBS)
    echowithcolor(
      COLOR
      GREEN
      "-- Dependency(${PROJECT_NAME}): Lua found ${LUA_VERSION_STRING}(module) and redirect to target lua::liblua(${LUA_LIBRARIES})"
    )
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua::liblua)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua)
    endif()
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME)
    project_build_tools_patch_default_imported_config(lua::liblua-dynamic lua::liblua-static lua::liblua lua::lua
                                                      lua::luac)
  endif()
endmacro()

# Try to use unofficial-lua-config.cmake in vcpkg
if(VCPKG_TOOLCHAIN
   AND NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  find_package(unofficial-lua QUIET CONFIG)
endif()

# Try to use lua-config.cmake
if(NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  find_package(lua QUIET CONFIG)
endif()

# Try to use FindLua.cmake
if(NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  find_package(Lua QUIET MODULE)
endif()

if(NOT TARGET lua::liblua-static
   AND NOT TARGET lua::liblua-dynamic
   AND NOT TARGET lua::liblua
   AND NOT TARGET unofficial-lua::lua
   AND NOT TARGET lua
   AND NOT LUA_FOUND)
  project_third_party_port_declare(
    lua
    VERSION
    "v5.4.4"
    GIT_URL
    "https://github.com/lua/lua.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
  if(WIN32
     OR MINGW
     OR CYGWIN)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS "-DCMAKE_DEBUG_POSTFIX=-dbg"
         "-DCMAKE_RELWITHDEBINFO_POSTFIX=-reldbg")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR)
    project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR "lua"
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION})
  endif()

  project_third_party_append_build_shared_lib_var("lua" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS
                                                  BUILD_SHARED_LIBS)
  project_third_party_append_build_static_lib_var("lua" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS
                                                  BUILD_STATIC_LIBS)

  if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR}")
    file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR}")
  endif()
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_ARGS
      GIT_BRANCH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}" GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL}")
  if(CMAKE_CROSSCOMPILING)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}.cross.patch")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_ARGS GIT_PATCH_FILES
           "${CMAKE_CURRENT_LIST_DIR}/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}.cross.patch")
    else()
      message(FATAL_ERROR "Must apply patch to disable call of system() on android/ios")
    endif()
  endif()

  find_configure_package(
    PACKAGE
    lua
    FIND_PACKAGE_FLAGS
    CONFIG
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_INHERIT_FIND_ROOT_PATH
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS}
    "-DLUA_TOP_SOURCE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
    PROJECT_DIRECTORY
    "${CMAKE_CURRENT_LIST_DIR}/build-script"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR}"
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_ARGS})

  if(NOT TARGET lua::liblua-dynamic
     AND NOT TARGET lua::liblua-static
     AND NOT TARGET lua::liblua
     AND NOT TARGET unofficial-lua::lua
     AND NOT TARGET lua
     AND NOT LUA_FOUND)
    message(FATAL_ERROR "-- Dependency(${PROJECT_NAME}): lua not found")
  endif()
  project_third_party_lua_import()
else()
  project_third_party_lua_import()
endif()
