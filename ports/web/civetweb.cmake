# Project mission is to provide easy to use, powerful, C (C/C++) embeddable web server with optional CGI, SSL and Lua support.
# https://github.com/civetweb/civetweb/

include_guard(GLOBAL)

# =========== third party civetweb ==================
function(PROJECT_THIRD_PARTY_CIVETWEB_PATCH_IMPORTED_TARGET TARGET_NAME)
  unset(PATCH_REMOVE_RULES)
  unset(PATCH_ADD_TARGETS)
  if(TARGET OpenSSL::SSL
     OR TARGET OpenSSL::Crypto
     OR TARGET LibreSSL::TLS)
    list(APPEND PATCH_REMOVE_RULES "(lib)?crypto" "(lib)?ssl")
    list(APPEND PATCH_ADD_TARGETS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME})
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAMES)
    list(APPEND PATCH_REMOVE_RULES "(lib)?lua(_a)?")
    list(APPEND PATCH_ADD_TARGETS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LUA_LINK_NAME})
  endif()
  if(PATCH_REMOVE_RULES OR PATCH_ADD_TARGETS)
    project_build_tools_patch_imported_link_interface_libraries(${TARGET_NAME} REMOVE_LIBRARIES ${PATCH_REMOVE_RULES}
                                                                ADD_LIBRARIES ${PATCH_ADD_TARGETS})
  endif()
  project_build_tools_patch_default_imported_config(${TARGET_NAME})
endfunction()

macro(PROJECT_THIRD_PARTY_CIVETWEB_IMPORT)
  if(TARGET civetweb::civetweb-cpp)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): civetweb found target civetweb::civetweb-cpp")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_LINK_NAME civetweb::civetweb-cpp)
  elseif(TARGET civetweb::civetweb)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): civetweb found target civetweb::civetweb")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_LINK_NAME civetweb::civetweb)
  endif()

  if(TARGET civetweb::civetweb-cpp)
    project_third_party_civetweb_patch_imported_target(civetweb::civetweb-cpp)
  endif()
  if(TARGET civetweb::civetweb)
    project_third_party_civetweb_patch_imported_target(civetweb::civetweb)
  endif()
endmacro()

if(NOT TARGET civetweb::civetweb-cpp AND NOT TARGET civetweb::civetweb)
  find_package(civetweb QUIET CONFIG)
  project_third_party_civetweb_import()
  if(NOT TARGET civetweb::civetweb-cpp AND NOT TARGET civetweb::civetweb)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_VERSION "v1.14")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_GIT_URL "https://github.com/civetweb/civetweb.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_DIR)
      project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_DIR "civetweb"
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_VERSION})
    endif()

    if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_DIR})
      file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_DIR})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
          "-DCIVETWEB_BUILD_TESTING=OFF"
          "-DCIVETWEB_ENABLE_DEBUG_TOOLS=OFF"
          "-DCIVETWEB_ENABLE_ASAN=OFF"
          "-DCIVETWEB_ENABLE_CXX=ON"
          "-DCIVETWEB_ENABLE_IPV6=ON"
          "-DCIVETWEB_ENABLE_WEBSOCKETS=ON")
      if(CMAKE_CROSSCOMPILING)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS
             "-DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF")
      endif()
      if(TARGET ZLIB::ZLIB)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS "-DCIVETWEB_ENABLE_ZLIB=ON")
      endif()
      if(OPENSSL_FOUND AND NOT LIBRESSL_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS "-DCIVETWEB_ENABLE_SSL=ON"
             "-DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS "-DCIVETWEB_ENABLE_SSL=OFF")
      endif()
      # TODO CIVETWEB_ENABLE_LUA,CIVETWEB_ENABLE_LUA_SHARED
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS "-DCIVETWEB_ENABLE_LUA=OFF")
    endif()
    project_third_party_append_build_shared_lib_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      civetweb
      FIND_PACKAGE_FLAGS
      CONFIG
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_FIND_ROOT_PATH
      CMAKE_INHIRT_SYSTEM_LINKS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "civetweb-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CIVETWEB_GIT_URL}")

    project_third_party_civetweb_import()
  endif()
else()
  project_third_party_civetweb_import()
endif()

if(NOT TARGET civetweb::civetweb-cpp AND NOT TARGET civetweb::civetweb)
  message(FATAL_ERROR "-- Dependency(${PROJECT_NAME}): civetweb not found")
endif()
