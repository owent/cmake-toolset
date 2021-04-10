include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LUA_IMPORT)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    if(TARGET lua::liblua-dynamic)
      echowithcolor(COLOR GREEN
                    "-- Dependency(${PROJECT_NAME}): Lua found target lua::liblua-dynamic")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES lua::liblua-dynamic)
      if(NOT TARGET lua)
        if(TARGET lua_DYNAMIC)
          add_library(lua ALIAS lua_DYNAMIC)
        else()
          add_library(lua ALIAS lua::liblua-dynamic)
        endif()
      endif()
    endif()
  else()
    if(TARGET lua::liblua-static)
      echowithcolor(COLOR GREEN
                    "-- Dependency(${PROJECT_NAME}): Lua found target lua::liblua-static")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES lua::liblua-static)
      if(NOT TARGET lua)
        if(TARGET lua_STATIC)
          add_library(lua ALIAS lua_STATIC)
        else()
          add_library(lua ALIAS lua::liblua-static)
        endif()
      endif()
    endif()
  endif()
endmacro()

if(NOT TARGET lua::liblua-static AND NOT TARGET lua::liblua-dynamic)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION "v5.4.3")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL "https://github.com/lua/lua.git")
  endif()

  if(NOT
     EXISTS
     "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
  )
    file(
      MAKE_DIRECTORY
      "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
    )
  endif()
  project_git_clone_repository(
    URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_GIT_URL}"
    REPO_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
    BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
    CHECK_PATH
    "luaconf.h")
  add_subdirectory(
    "${CMAKE_CURRENT_LIST_DIR}/build-script"
    "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/lua-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_VERSION}"
  )
  project_third_party_lua_import()
else()
  project_third_party_lua_import()
endif()

if(NOT TARGET lua)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): lua not found.")
endif()
