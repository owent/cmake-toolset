# The C++ OpenTelemetry client.
# https://github.com/open-telemetry/opentelemetry-cpp

include_guard(DIRECTORY)

# =========== third party opentelemetry-cpp ==================
macro(PROJECT_THIRD_PARTY_OPENTELEMETRY_CPP_IMPORT)
  if(TARGET opentelemetry-cpp::api)
    message(STATUS "Dependency(${PROJECT_NAME}): opentelemetry-cpp found target opentelemetry-cpp::api")
  endif()
  if(TARGET opentelemetry-cpp::sdk)
    message(STATUS "Dependency(${PROJECT_NAME}): opentelemetry-cpp found target opentelemetry-cpp::sdk")
  endif()
  if(OPENTELEMETRY_CPP_LIBRARIES)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_LINK_NAMES ${OPENTELEMETRY_CPP_LIBRARIES})
    set(_IMPLICIT_OPENTELEMETRY_CPP_TARGETS opentelemetry-cpp::resources opentelemetry-cpp::proto
                                            opentelemetry-cpp::otlp_recordable)
    foreach(_IMPLICIT_OPENTELEMETRY_CPP_TARGET IN LISTS _IMPLICIT_OPENTELEMETRY_CPP_TARGETS)
      if(TARGET ${_IMPLICIT_OPENTELEMETRY_CPP_TARGET}
         AND NOT ("${_IMPLICIT_OPENTELEMETRY_CPP_TARGET}" IN_LIST
                  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_LINK_NAMES))
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_LINK_NAMES
             ${_IMPLICIT_OPENTELEMETRY_CPP_TARGET})
      endif()
    endforeach()
    unset(_IMPLICIT_OPENTELEMETRY_CPP_TARGET)
    unset(_IMPLICIT_OPENTELEMETRY_CPP_TARGETS)

    project_build_tools_patch_default_imported_config(
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_LINK_NAMES})
  endif()
endmacro()

if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
  if(VCPKG_TOOLCHAIN)
    find_package(opentelemetry-cpp QUIET CONFIG)
    project_third_party_opentelemetry_cpp_import()
  endif()

  if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES)
    project_third_party_port_declare(opentelemetry_cpp VERSION "v1.10.0" GIT_URL
                                     "https://github.com/open-telemetry/opentelemetry-cpp.git")

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}"
      "opentelemetry-cpp" "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION MATCHES "^v(.*)")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_STANDARD_VERSION "${CMAKE_MATCH_1}")
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_STANDARD_VERSION
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_VERSION}")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
          "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
          "-Dprotobuf_MODULE_COMPATIBLE=ON"
          "-DBUILD_TESTING=OFF"
          "-DWITH_EXAMPLES=OFF"
          "-DWITH_EXAMPLES_HTTP=OFF"
          "-DOPENTELEMETRY_INSTALL=ON")

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_STANDARD_VERSION VERSION_GREATER "1.4.1")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_ASYNC_EXPORT_PREVIEW=ON")
      endif()

      # Require at least C++17. C++20 is needed to avoid gsl::span
      if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL)
        if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
          if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL OFF)
          endif()
        elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
          if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL OFF)
          endif()
        elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
          # Microsoft.GSL seems to has some problems with default copy constructor and STL(libc++) on macOS. We always
          # disable it. if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.3")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL OFF)
          # endif()
        elseif(MSVC)
          if(MSVC_VERSION LESS 1916)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL OFF)
          endif()
        endif()
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_GSL
         AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MICROSOFT_GSL_LINK_NAME)
        # Opentelemetry do noy support gsl::span of gsl-lite
        if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GSL_LINK_NAME MATCHES "gsl::gsl-lite")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_GSL ON)
        endif()
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ETW AND WIN32)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ETW ON)
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_JAEGER)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_JAEGER OFF)
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DZLIB_ROOT=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_COMPRESSION_ZLIB_ROOT_DIR}")
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ABSEIL AND absl_FOUND)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ABSEIL ON)
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_PREVIEW)
        # TODO FIXME, @see https://github.com/open-telemetry/opentelemetry-cpp/issues/1027
        if(COMPILER_OPTIONS_TEST_RTTI AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_STANDARD_VERSION
                                          VERSION_LESS "1.4.1")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_PREVIEW ON)
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_PREVIEW OFF)
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_STANDARD_VERSION VERSION_GREATER_EQUAL "1.7.0")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_EXEMPLAR_PREVIEW ON)
          else()
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_EXEMPLAR_PREVIEW OFF)
          endif()
        endif()
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_STANDARD_VERSION VERSION_GREATER_EQUAL "1.9.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP_SSL_PREVIEW ON)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP_SSL_TLS_PREVIEW ON)
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP_SSL_PREVIEW OFF)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP_SSL_TLS_PREVIEW OFF)
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_LOGS_PREVIEW)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_LOGS_PREVIEW ON)
      endif()

      # OTLP exporter depend host prebuilt protoc and gRPC
      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP
         AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC)
        if(TARGET gRPC::grpc++_alts
           OR TARGET gRPC::grpc++
           OR TARGET gRPC::grpc)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP ON)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_GRPC ON)
        endif()
        if(TARGET CURL::libcurl OR CURL_FOUND)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP ON)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP ON)
        endif()
      endif()

      if(TARGET CURL::libcurl AND TARGET nlohmann_json::nlohmann_json)
        get_target_property(nlohmann_json_INC_DIR nlohmann_json::nlohmann_json INTERFACE_INCLUDE_DIRECTORIES)
        if(nlohmann_json_INC_DIR)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES
               ${nlohmann_json_INC_DIR})
        endif()
        unset(nlohmann_json_INC_DIR)
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ELASTICSEARCH)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ELASTICSEARCH ON)
        endif()
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZIPKIN)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZIPKIN ON)
        endif()
      endif()

      if(TARGET nlohmann_json::nlohmann_json)
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZPAGES)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZPAGES ON)
        endif()
      endif()

      if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_PROMETHEUS AND TARGET
                                                                                                 prometheus-cpp::core)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_PROMETHEUS ON)
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES "third_party/opentelemetry-proto")

    # The abseil in opentelemetry-cpp do not support compiler with c++20
    if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL)
      # See https://github.com/microsoft/GSL#supported-compilers
      if(MSVC AND MSVC_VERSION GREATER_EQUAL 1924)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL ON)
      elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL ON)
      elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL ON)
        # Microsoft.GSL seems to has some problems with default copy constructor and STL(libc++) on macOS. We always
        # disable it.

        # elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL
        # "10.3") set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL ON)
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_STL)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_STL=ON")
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_GSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_GSL=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES "third_party/ms-gsl")
      endif()
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_STL=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ABSEIL)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ABSEIL=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ABSEIL=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_PREVIEW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_METRICS_PREVIEW=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_METRICS_PREVIEW=OFF")
    endif()
    if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_EXEMPLAR_PREVIEW)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_METRICS_EXEMPLAR_PREVIEW)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_METRICS_EXEMPLAR_PREVIEW=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
             "-DWITH_METRICS_EXEMPLAR_PREVIEW=OFF")
      endif()
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP_SSL_PREVIEW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           "-DWITH_OTLP_HTTP_SSL_PREVIEW=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           "-DWITH_OTLP_HTTP_SSL_PREVIEW=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP_SSL_TLS_PREVIEW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           "-DWITH_OTLP_HTTP_SSL_TLS_PREVIEW=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
           "-DWITH_OTLP_HTTP_SSL_TLS_PREVIEW=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_LOGS_PREVIEW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_LOGS_PREVIEW=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_LOGS_PREVIEW=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_OTLP=ON"
           "-DProtobuf_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
           "-DPROTOBUF_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_GRPC)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_OTLP_GRPC=ON"
             "-DgRPC_CPP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE}"
             "-D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
      endif()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_OTLP_HTTP)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_OTLP_HTTP=ON")
      endif()
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_OTLP=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ETW)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ETW=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ETW=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_JAEGER)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_JAEGER=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_JAEGER=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ELASTICSEARCH)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ELASTICSEARCH=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ELASTICSEARCH=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZIPKIN)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ZIPKIN=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ZIPKIN=OFF")
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_ZPAGES)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ZPAGES=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_ZPAGES=OFF")
    endif()
    if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_NO_GETENV)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_NO_GETENV)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_NO_GETENV=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_NO_GETENV=OFF")
      endif()
    endif()
    if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_API_ONLY)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_API_ONLY)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_API_ONLY=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_API_ONLY=OFF")
      endif()
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_WITH_PROMETHEUS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_PROMETHEUS=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DWITH_PROMETHEUS=OFF")
    endif()

    project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES)
      list(REMOVE_DUPLICATES ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES)
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS
        "-DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_INCLUDE_DIRECTORIES}"
      )
    endif()

    # opentelemetry do not support export DLL APIs now
    if(WIN32
       OR MINGW
       OR CYGWIN)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF")
    else()
      project_third_party_append_build_shared_lib_var(
        "opentelemetry_cpp" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS BUILD_SHARED_LIBS)
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_PATCH_FILE}")
    endif()

    if(WIN32
       OR MINGW
       OR CYGWIN)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES "tools/vcpkg")

      add_compiler_define_to_var(OPENTELEMETRY_CPP_PATCH_FLAGS "NOMINMAX")
      set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS " ${OPENTELEMETRY_CPP_PATCH_FLAGS}")
      set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS " ${OPENTELEMETRY_CPP_PATCH_FLAGS}")
    endif()

    # After all actived submodules, it's allowed to reset url of submodule
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_RESET_SUBMODULE_URLS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_SUB_MODULES GIT_RESET_SUBMODULE_URLS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_RESET_SUBMODULE_URLS})
    endif()

    find_configure_package(
      PACKAGE
      opentelemetry-cpp
      BUILD_WITH_CMAKE
      FIND_PACKAGE_FLAGS
      CONFIG
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_FIND_ROOT_PATH
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

    if(WIN32
       OR MINGW
       OR CYGWIN)
      unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS)
      unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS)
      unset(OPENTELEMETRY_CPP_PATCH_FLAGS)
    endif()

    if(TARGET opentelemetry-cpp::api OR TARGET opentelemetry-cpp::sdk)
      project_third_party_opentelemetry_cpp_import()
    endif()
  endif()
else()
  project_third_party_opentelemetry_cpp_import()
endif()

if(NOT TARGET opentelemetry-cpp::api AND NOT TARGET opentelemetry-cpp::sdk)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_OPENTELEMETRY_CPP_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build opentelemetry-cpp failed.")
endif()
