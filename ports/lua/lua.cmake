include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LUA_IMPORT)
  if(BUILD_SHARED_LIBS OR ATFRAMEWORK_USE_DYNAMIC_LIBRARY)
    if(TARGET lua::liblua-dynamic)
      echowithcolor(COLOR GREEN "-- Dependency: Lua found.(Target: lua::liblua-dynamic)")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES lua::liblua-dynamic)
      if(NOT TARGET lua)
        add_library(lua ALIAS lua::liblua-dynamic)
      endif()
    endif()
  else()
    if(TARGET lua::liblua-static)
      echowithcolor(COLOR GREEN "-- Dependency: Lua found.(Target: lua::liblua-static)")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES lua::liblua-static)
      if(NOT TARGET lua)
        add_library(lua ALIAS lua::liblua-static)
      endif()
    endif()
  endif()
endmacro()

if(NOT TARGET lua::liblua-static AND NOT TARGET lua::liblua-dynamic)
  set(PROJECT_THIRD_PARTY_LUA_VERSION "v5.4.3")
  set(PROJECT_THIRD_PARTY_LUA_REPO_DIR
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/lua-${PROJECT_THIRD_PARTY_LUA_VERSION}")
  set(PROJECT_THIRD_PARTY_LUA_REPO_URL "https://github.com/lua/lua.git")
  set(PROJECT_THIRD_PARTY_LUA_BUILD_DIR
      "${CMAKE_BINARY_DIR}/deps/lua-${PROJECT_THIRD_PARTY_LUA_VERSION}")

  if(NOT EXISTS ${PROJECT_THIRD_PARTY_LUA_BUILD_DIR})
    file(MAKE_DIRECTORY ${PROJECT_THIRD_PARTY_LUA_BUILD_DIR})
  endif()
  project_git_clone_repository(
    URL
    ${PROJECT_THIRD_PARTY_LUA_REPO_URL}
    REPO_DIRECTORY
    ${PROJECT_THIRD_PARTY_LUA_REPO_DIR}
    DEPTH
    200
    BRANCH
    ${PROJECT_THIRD_PARTY_LUA_VERSION}
    WORKING_DIRECTORY
    ${PROJECT_THIRD_PARTY_PACKAGE_DIR}
    CHECK_PATH
    "luaconf.h")
  add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/build-script" ${PROJECT_THIRD_PARTY_LUA_BUILD_DIR})
  project_third_party_lua_import()
else()
  project_third_party_lua_import()
endif()
