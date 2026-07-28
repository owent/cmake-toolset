include_guard(DIRECTORY)

# =========== third party libsodium ==================
function(PROJECT_THIRD_PARTY_LIBSODIUM_IMPORT)
  if(TARGET sodium) # Official Findsodium.cmake
    message(STATUS "Dependency(${PROJECT_NAME}): Libsodium found target sodium")
    project_third_party_export_port_set(libsodium LINK_NAME sodium)
  elseif(TARGET unofficial-sodium::sodium) # vcpkg porting
    message(STATUS "Dependency(${PROJECT_NAME}): Libsodium found target unofficial-sodium::sodium")
    project_third_party_export_port_set(libsodium LINK_NAME unofficial-sodium::sodium)
  elseif(TARGET libsodium::libsodium) # Our porting
    message(STATUS "Dependency(${PROJECT_NAME}): Libsodium found target libsodium::libsodium")
    project_third_party_export_port_set(libsodium LINK_NAME libsodium::libsodium)
  endif()
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LINK_NAME)
    project_build_tools_patch_default_imported_config(
      sodium unofficial-sodium::sodium unofficial-sodium::sodium_config_public libsodium::libsodium
      libsodium::libsodium_config_public)
  endif()
endfunction()

project_third_party_check_build_shared_lib("libsodium" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_USE_SHARED)

set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LOCAL_INSTALL_FOUND FALSE)
if(MSVC AND NOT MINGW)
  include("${CMAKE_CURRENT_LIST_DIR}/libsodium-msvc.cmake")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_USE_SHARED)
    set(sodium_USE_STATIC_LIBS FALSE)
  else()
    set(sodium_USE_STATIC_LIBS TRUE)
  endif()
  if(NOT VCPKG_TOOLCHAIN)
    project_third_party_libsodium_msvc_import(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LOCAL_INSTALL_FOUND)
  endif()
endif()

if(NOT TARGET sodium
   AND NOT TARGET unofficial-sodium::sodium
   AND NOT TARGET libsodium::libsodium)
  if(VCPKG_TOOLCHAIN)
    find_package(unofficial-sodium QUIET CONFIG)
    if(NOT TARGET unofficial-sodium::sodium)
      find_package(sodium QUIET)
    endif()
  elseif(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LOCAL_INSTALL_FOUND)
    find_package(sodium QUIET)
    if(NOT TARGET sodium)
      find_package(libsodium QUIET CONFIG)
      if(NOT TARGET unofficial-sodium::sodium AND NOT TARGET libsodium::libsodium)
        find_package(unofficial-sodium QUIET CONFIG)
      endif()
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
    "1.0.22-RELEASE"
    GIT_URL
    "https://github.com/jedisct1/libsodium.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DBUILD_TESTING=OFF")

  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "libsodium"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_VERSION}")

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SRC_DIRECTORY_NAME}")

  # libsodium does not ship a CMakeLists.txt. On MSVC we build native vcxproj via MSBuild; on Unix we use autotools.
  if(MSVC AND NOT MINGW)
    project_third_party_libsodium_msvc_build()
  else()
    # ============ Unix/Linux/macOS/MinGW: autotools (configure + make) ============
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS "--disable-dependency-tracking")

    if(NOT MINGW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS "--disable-pie")
    endif()

    project_third_party_append_build_shared_lib_var(
      "libsodium" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_OPTIONS BUILD_SHARED_LIBS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_USE_SHARED)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS "--enable-shared"
           "--disable-static")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS "--disable-shared"
           "--enable-static")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      libsodium
      BUILD_WITH_CONFIGURE
      AUTOGEN_CONFIGURE
      "bash"
      "./autogen.sh"
      CONFIGURE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SRC_DIRECTORY_NAME}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_GIT_URL}")

    # For static builds, patch export.h
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_USE_SHARED)
      if(EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/export.h")
        file(READ "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/export.h"
             ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_EXPORT_H_CONTENT)
        string(REPLACE "#ifdef SODIUM_STATIC" "#if 1" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_EXPORT_H_CONTENT
                       "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_EXPORT_H_CONTENT}")
        file(WRITE "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/export.h"
             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_EXPORT_H_CONTENT}")
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_EXPORT_H_CONTENT)
      endif()
    endif()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_CONFIGURE_OPTIONS)
  endif()

  # Try to find and import again after build
  if(NOT TARGET sodium
     AND NOT TARGET unofficial-sodium::sodium
     AND NOT TARGET libsodium::libsodium)
    find_package(sodium QUIET)
    if(NOT TARGET sodium)
      find_package(libsodium QUIET CONFIG)
    endif()
  endif()

  if(TARGET sodium
     OR TARGET unofficial-sodium::sodium
     OR TARGET libsodium::libsodium)
    project_third_party_libsodium_import()
  else()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
      project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}")
    endif()
  endif()

  unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR)
else()
  project_third_party_libsodium_import()
endif()

unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_LOCAL_INSTALL_FOUND)
