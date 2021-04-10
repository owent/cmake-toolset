include_guard(GLOBAL)

# =========== third party yaml-cpp ==================
macro(PROJECT_THIRD_PARTY_YAML_CPP_IMPORT)
  if(TARGET yaml-cpp::yaml-cpp)
    message(STATUS "Dependency(${PROJECT_NAME}): yaml-cpp using target yaml-cpp::yaml-cpp")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME yaml-cpp::yaml-cpp)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME})
  elseif(TARGET yaml-cpp)
    message(STATUS "Dependency(${PROJECT_NAME}): yaml-cpp using target yaml-cpp")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME yaml-cpp)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_LINK_NAME})
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

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION "0.6.3")
  endif()
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_GIT_URL)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_GIT_URL
        "https://github.com/jbeder/yaml-cpp.git")
  endif()

  findconfigurepackage(
    PACKAGE
    yaml-cpp
    BUILD_WITH_CMAKE
    CMAKE_INHIRT_BUILD_ENV
    CMAKE_FLAGS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=YES"
    "-DYAML_CPP_BUILD_TESTS=OFF"
    "-DYAML_CPP_INSTALL=ON"
    MSVC_CONFIGURE
    "${CMAKE_BUILD_TYPE}"
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/yaml-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "yaml-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION}"
    GIT_BRANCH
    "yaml-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_YAML_CPP_GIT_URL}")

  if(NOT TARGET yaml-cpp::yaml-cpp
     AND NOT TARGET yaml-cpp
     AND (NOT YAML_CPP_INCLUDE_DIR OR NOT YAML_CPP_LIBRARIES))
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
