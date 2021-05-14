include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LUA_IMPORT)
  if(TARGET lua::liblua-dynamic)
    echowithcolor(COLOR GREEN
                  "-- Dependency(${PROJECT_NAME}): Lua found target lua::liblua-dynamic")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua::liblua-dynamic)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua-dynamic)
    endif()
  elseif(TARGET lua::liblua-static)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): Lua found target lua::liblua-static")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME lua::liblua-static)
    if(NOT TARGET lua)
      add_library(lua INTERFACE IMPORTED)
      set_target_properties(lua PROPERTIES INTERFACE_LINK_LIBRARIES lua::liblua-static)
    endif()
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME})
  endif()
  project_build_tools_patch_default_imported_config(lua::liblua-dynamic lua::liblua-static lua::lua
                                                    lua::luac)
endmacro()

if(NOT TARGET lua::liblua-static AND NOT TARGET lua::liblua-dynamic)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION "v5.4.3")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL "https://github.com/lua/lua.git")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR)
    project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR "lua"
                                      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION})
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS
        "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DCMAKE_DEBUG_POSTFIX=d")

    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS BUILD_SHARED_LIBS)
    project_third_party_append_build_static_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_OPTIONS BUILD_STATIC_LIBS)
  endif()

  if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR}")
    file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_BUILD_DIR}")
  endif()
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_ARGS
      GIT_BRANCH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}" GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL}")
  if(CMAKE_CROSSCOMPILING)
    if(EXISTS
       "${CMAKE_CURRENT_LIST_DIR}/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}.cross.patch"
    )
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_ARGS
        GIT_PATCH_FILES
        "${CMAKE_CURRENT_LIST_DIR}/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}.cross.patch"
      )
    else()
      message(FATAL_ERROR "Must apply patch to disable call of system() on android/ios")
    endif()
  endif()

  find_configure_package(
    PACKAGE
    lua
    BUILD_WITH_CMAKE
    CMAKE_INHIRT_BUILD_ENV
    CMAKE_INHIRT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_INHIRT_FIND_ROOT_PATH
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
     AND NOT TARGET lua::lua
     AND NOT TARGET lua::luac)
    echowithcolor(COLOR YELLOW "-- Dependency(${PROJECT_NAME}): lua not found")
  endif()
  project_third_party_lua_import()
else()
  project_third_party_lua_import()
endif()
