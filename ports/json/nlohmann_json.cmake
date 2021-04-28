# JSON for Modern C++
# https://github.com/nlohmann/json
# https://json.nlohmann.me/

include_guard(GLOBAL)

# =========== third party nlohmann_json ==================
macro(PROJECT_THIRD_PARTY_NLOHMANN_JSON_IMPORT)
  if(TARGET nlohmann_json::nlohmann_json)
    message(STATUS "Dependency(${PROJECT_NAME}): Target nlohmann_json::nlohmann_json found")
    project_build_tools_patch_default_imported_config(nlohmann_json::nlohmann_json)
  endif()
endmacro()

if(NOT TARGET nlohmann_json::nlohmann_json)
  if(VCPKG_TOOLCHAIN)
    find_package(nlohmann_json QUIET CONFIG)
    project_third_party_nlohmann_json_import()
  endif()

  if(NOT TARGET nlohmann_json::nlohmann_json)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_VERSION "v3.9.1")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_GIT_URL
          "https://github.com/nlohmann/json.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_DIR)
      project_third_party_get_build_dir(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_DIR "nlohmann_json"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_VERSION})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS "-DJSON_Install=ON"
                                                                            "-DJSON_BuildTests=OFF")
    endif()
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS
           "-DCMAKE_DEBUG_POSTFIX=d")
    endif()
    project_third_party_append_find_root_args(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      nlohmann_json
      BUILD_WITH_CMAKE
      FIND_PACKAGE_FLAGS
      CONFIG
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "nlohmann_json-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_GIT_URL}")

    if(TARGET nlohmann_json::nlohmann_json)
      project_third_party_nlohmann_json_import()
    endif()
  endif()
else()
  project_third_party_nlohmann_json_import()
endif()

if(NOT TARGET nlohmann_json::nlohmann_json)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build nlohmann_json failed.")
endif()
