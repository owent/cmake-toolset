# The C++ OpenTelemetry client.
# https://github.com/open-telemetry/opentelemetry-cpp

include_guard(GLOBAL)

# =========== third party opentelemetry-cpp ==================
macro(PROJECT_THIRD_PARTY_OPENTELEMETRY_CPP_IMPORT)
  if(TARGET opentelemetry-cpp::api)
    message(STATUS "Dependency(${PROJECT_NAME}): Target opentelemetry-cpp::api found")
    project_build_tools_patch_default_imported_config(opentelemetry-cpp::api)
  endif()
  if(TARGET opentelemetry-cpp::sdk)
    message(STATUS "Dependency(${PROJECT_NAME}): Target opentelemetry-cpp::sdk found")
    project_build_tools_patch_default_imported_config(opentelemetry-cpp::sdk)
  endif()
endmacro()

if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
  if(VCPKG_TOOLCHAIN)
    find_package(opentelemetry-cpp QUIET CONFIG)
    project_third_party_opentelemetry_cpp_import()
  endif()

  if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION "v0.5.0")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_GIT_URL
          "https://github.com/open-telemetry/opentelemetry-cpp.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_DIR)
      project_third_party_get_build_dir(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_DIR "opentelemetry-cpp"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_TESTING=OFF" "-DWITH_EXAMPLES=OFF"
          "-DWITH_STL=ON")
      if(absl_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_ABSEIL=ON")
      endif()

      if(TARGET gRPC::grpc++_alts
         OR TARGET gRPC::grpc++
         OR TARGET gRPC::grpc)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_OTLP=ON")
      endif()

      if(TARGET CURL::libcurl)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_ZIPKIN=ON")
      endif()

      # TODO "-DWITH_PROMETHEUS=ON"

      if(TARGET CURL::libcurl AND TARGET nlohmann_json::nlohmann_json)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_ELASTICSEARCH=ON")
      endif()
    endif()
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           "-DCMAKE_DEBUG_POSTFIX=d")
    endif()
    project_third_party_append_find_root_args(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      opentelemetry-cpp
      BUILD_WITH_CMAKE
      FIND_PACKAGE_FLAGS
      CONFIG
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "opentelemetry-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_GIT_URL}")

    if(TARGET opentelemetry-cpp::api OR TARGET opentelemetry-cpp::sdk)
      project_third_party_opentelemetry_cpp_import()
    endif()
  endif()
else()
  project_third_party_opentelemetry_cpp_import()
endif()

if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build opentelemetry-cpp failed.")
endif()
