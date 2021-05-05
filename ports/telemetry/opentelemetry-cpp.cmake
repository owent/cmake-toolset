# The C++ OpenTelemetry client.
# https://github.com/open-telemetry/opentelemetry-cpp

include_guard(GLOBAL)

# =========== third party opentelemetry-cpp ==================
macro(PROJECT_THIRD_PARTY_OPENTELEMETRY_CPP_IMPORT)
  if(TARGET opentelemetry-cpp::api)
    message(STATUS "Dependency(${PROJECT_NAME}): Target opentelemetry-cpp::api found")
  endif()
  if(TARGET opentelemetry-cpp::sdk)
    message(STATUS "Dependency(${PROJECT_NAME}): Target opentelemetry-cpp::sdk found")
  endif()
endmacro()

if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
  if(VCPKG_TOOLCHAIN)
    find_package(opentelemetry-cpp QUIET CONFIG)
    project_third_party_opentelemetry_cpp_import()
  endif()

  if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION "v0.5.0")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE
          "${CMAKE_CURRENT_LIST_DIR}/opentelemetry-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION}.patch"
      )
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
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_TESTING=OFF" "-DWITH_EXAMPLES=OFF")

      # Require at least C++17. C++20 is needed to avoid gsl::span
      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "7.0.0")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
               "-DWITH_STL=ON")
        endif()
      elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "6.0.0")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
               "-DWITH_STL=ON")
        endif()
      elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8.0.0")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
               "-DWITH_STL=ON")
        endif()
      elseif(MSVC)
        if(MSVC_VERSION GREATER_EQUAL 1914)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
               "-DWITH_STL=ON")
        endif()
      endif()
      if(absl_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_ABSEIL=ON")
      endif()

      # TODO OTLP exporter depend host built protoc and gRPC
      if(NOT CMAKE_CROSSCOMPILING
         AND (TARGET gRPC::grpc++_alts
              OR TARGET gRPC::grpc++
              OR TARGET gRPC::grpc))
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_OTLP=ON")
      endif()

      # TODO "-DWITH_PROMETHEUS=ON"

      if(TARGET CURL::libcurl AND TARGET nlohmann_json::nlohmann_json)
        get_target_property(nlohmann_json_INC_DIR nlohmann_json::nlohmann_json
                            INTERFACE_INCLUDE_DIRECTORIES)
        if(nlohmann_json_INC_DIR)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES
               ${nlohmann_json_INC_DIR})
        endif()
        unset(nlohmann_json_INC_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_ELASTICSEARCH=ON" "-DWITH_ZIPKIN=ON")
      endif()
    endif()
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           "-DCMAKE_DEBUG_POSTFIX=d")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES)
      list(REMOVE_DUPLICATES
           ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES)
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
        "-DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES}"
      )
    endif()

    project_third_party_append_find_root_args(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS BUILD_SHARED_LIBS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           GIT_PATCH_FILES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE})
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES
        "third_party/opentelemetry-proto" "third_party/ms-gsl")

    if(MINGW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES "tools/vcpkg")
    endif()

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
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_GIT_URL}"
      GIT_ENABLE_SUBMODULE
      GIT_SUBMODULE_PATHS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES})

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