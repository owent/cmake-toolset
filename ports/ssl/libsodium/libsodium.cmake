include_guard(GLOBAL)

# =========== third party libsodium ==================

macro(PROJECT_THIRD_PARTY_LIBSODIUM_IMPORT)
  if(TARGET sodium) # Official Findsodium.cmake
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): Libsodium found target sodium")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LINK_NAME sodium)
  elseif(TARGET unofficial-sodium::sodium) # vcpkg porting
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): Libsodium found target unofficial-sodium::sodium")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LINK_NAME unofficial-sodium::sodium)
  elseif(TARGET libsodium::libsodium) # Our porting
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): Libsodium found target libsodium::libsodium")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LINK_NAME libsodium::libsodium)
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LINK_NAME)
    project_build_tools_patch_default_imported_config(
      sodium unofficial-sodium::sodium unofficial-sodium::sodium_config_public libsodium::libsodium
      libsodium::libsodium_config_public)
  endif()
endmacro()

# Try to use lua-config.cmake
if(NOT TARGET sodium
   AND NOT TARGET unofficial-sodium::sodium
   AND NOT TARGET libsodium::libsodium)
  find_package(sodium QUIET)
  if(NOT TARGET sodium)
    find_package(libsodium QUIET CONFIG)
    if(NOT TARGET unofficial-sodium::sodium AND NOT TARGET libsodium::libsodium)
      find_package(unofficial-sodium QUIET CONFIG)
    endif()
  endif()
  if(TARGET sodium
     OR TARGET unofficial-sodium::sodium
     OR TARGET libsodium::libsodium)
    project_third_party_libsodium_import()
  endif()
endif()

# Build libsodium
if(NOT TARGET sodium
   AND NOT TARGET unofficial-sodium::sodium
   AND NOT TARGET libsodium::libsodium)
  project_third_party_port_declare(
    libsodium
    VERSION
    "1.0.18-RELEASE"
    GIT_URL
    "https://github.com/jedisct1/libsodium.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DBUILD_TESTING=OFF")

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE
      "${CMAKE_CURRENT_LIST_DIR}/xxhash-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_VERSION}.patch")

  # Redirect source path
  list(
    APPEND
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_OPTIONS
    "-DLIBSODIUM_SOURCE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SRC_DIRECTORY_NAME}"
  )
  project_third_party_append_build_shared_lib_var(
    "libsodium" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_OPTIONS BUILD_SHARED_LIBS)

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE}")
  endif()

  find_configure_package(
    PACKAGE
    libsodium
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SRC_DIRECTORY_NAME}"
    PROJECT_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SRC_DIRECTORY_NAME}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_GIT_URL}")

  if(TARGET xxHash::xxhash)
    project_third_party_xxhash_import()
  endif()
else()
  project_third_party_libsodium_import()
endif()
