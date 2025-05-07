include_guard(DIRECTORY)

# =========== third party yaml-cpp ==================
macro(PROJECT_THIRD_PARTY_YAML_CPP_IMPORT)
  if(TARGET yaml-cpp::yaml-cpp)
    message(STATUS "Dependency(${PROJECT_NAME}): yaml-cpp using target yaml-cpp::yaml-cpp")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME yaml-cpp::yaml-cpp)
  elseif(TARGET yaml-cpp)
    message(STATUS "Dependency(${PROJECT_NAME}): yaml-cpp using target yaml-cpp")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME yaml-cpp)
  endif()
endmacro()

if(VCPKG_TOOLCHAIN)
  find_package(yaml-cpp QUIET)
  project_third_party_yaml_cpp_import()
endif()

# =========== third party yaml-cpp ==================
if(NOT TARGET yaml-cpp::yaml-cpp
   AND NOT TARGET yaml-cpp
   AND (NOT YAML_CPP_INCLUDE_DIR OR NOT YAML_CPP_LIBRARIES))

  project_third_party_port_declare(
    yaml-cpp
    VERSION
    "0.8.0"
    GIT_URL
    "https://github.com/jbeder/yaml-cpp.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DYAML_CPP_BUILD_TESTS=OFF"
    "-DYAML_CPP_INSTALL=ON")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION VERSION_GREATER_EQUAL "0.8.0")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_TAG_NAME
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION}")
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_TAG_NAME
        "yaml-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION}")
  endif()

  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "yaml-cpp"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION}")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_BUILD_OPTIONS GIT_PATCH_FILES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_PATCH_FILE})
  endif()

  find_configure_package(
    PACKAGE
    yaml-cpp
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_INHERIT_FIND_ROOT_PATH
    CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_STANDARD
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_YAML_CPP_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "yaml-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_TAG_NAME}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_TAG_NAME}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_GIT_URL}")

  if(NOT TARGET yaml-cpp::yaml-cpp
     AND NOT TARGET yaml-cpp
     AND (NOT YAML_CPP_INCLUDE_DIR OR NOT YAML_CPP_LIBRARIES))
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
      project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_YAML_CPP_BUILD_DIR}")
    endif()
    echowithcolor(
      COLOR
      RED
      "-- Dependency(${PROJECT_NAME}): yaml-cpp is required, we can not find prebuilt for yaml-cpp and can not build it from git repository"
    )
    message(FATAL_ERROR "yaml-cpp not found")
  endif()

  project_third_party_yaml_cpp_import()
else()
  project_third_party_yaml_cpp_import()
endif()
