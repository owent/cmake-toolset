# JSON for Modern C++
# https://github.com/nlohmann/json
# https://json.nlohmann.me/

include_guard(DIRECTORY)

# =========== third party nlohmann_json ==================
macro(PROJECT_THIRD_PARTY_NLOHMANN_JSON_IMPORT)
  if(TARGET nlohmann_json::nlohmann_json)
    message(STATUS "Dependency(${PROJECT_NAME}): Target nlohmann_json::nlohmann_json found")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_LINK_NAME nlohmann_json::nlohmann_json)
  endif()
endmacro()

if(NOT TARGET nlohmann_json::nlohmann_json)
  find_package(nlohmann_json QUIET CONFIG)
  project_third_party_nlohmann_json_import()

  if(NOT TARGET nlohmann_json::nlohmann_json)
    project_third_party_port_declare(
      nlohmann_json
      VERSION
      "v3.11.2"
      GIT_URL
      "https://github.com/nlohmann/json.git"
      BUILD_OPTIONS
      "-DJSON_Install=ON"
      "-DJSON_BuildTests=OFF")

    project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      "nlohmann_json" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_OPTIONS BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      nlohmann_json
      BUILD_WITH_CMAKE
      FIND_PACKAGE_FLAGS
      CONFIG
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS
      CMAKE_INHERIT_FIND_ROOT_PATH
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
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_NLOHMANN_JSON_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build nlohmann_json failed.")
endif()
