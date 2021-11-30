# This is grpc, an asynchronous resolver library.
# https://github.com/grpc/grpc.git
# git@github.com:grpc/grpc.git
# https://grpc.io/

include_guard(GLOBAL)

# =========== third party grpc ==================
macro(PROJECT_THIRD_PARTY_GRPC_IMPORT)
  if(TARGET gRPC::grpc++_alts
     OR TARGET gRPC::grpc++
     OR TARGET gRPC::grpc)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME)
    if(TARGET gRPC::gpr)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::gpr)
    endif()
    if(TARGET gRPC::grpc)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc)
    endif()
    if(TARGET gRPC::grpc++)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc++)
    endif()
    if(TARGET gRPC::grpc++_alts)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc++_alts)
    endif()

    message(
      STATUS
        "Dependency(${PROJECT_NAME}): grpc using target ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME} (version: ${gRPC_VERSION})"
    )
    if(CMAKE_CROSSCOMPILING)
      # Just like find_program(_gRPC_CPP_PLUGIN grpc_cpp_plugin) in CMakeLists.txt in grpc
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE grpc_csharp_plugin)
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE grpc_node_plugin)
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECT_C_PLUGIN_EXECUTABLE grpc_objective_c_plugin)
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE grpc_php_plugin)
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE grpc_python_plugin)
      find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE grpc_ruby_plugin)
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): grpc executables for crosscompiling:
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECT_C_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECT_C_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE}
          ")
    else()
      if(TARGET grpc_cpp_plugin)
        project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE
                                                  grpc_cpp_plugin)
      else()
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
      endif()
      if(TARGET grpc_csharp_plugin)
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE grpc_csharp_plugin)
      endif()
      if(TARGET grpc_node_plugin)
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE grpc_node_plugin)
      endif()
      if(TARGET grpc_objective_c_plugin)
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECT_C_PLUGIN_EXECUTABLE grpc_objective_c_plugin)
      endif()
      if(TARGET grpc_php_plugin)
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE grpc_php_plugin)
      endif()
      if(TARGET grpc_python_plugin)
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE grpc_python_plugin)
      endif()
      if(TARGET grpc_ruby_plugin)
        find_program(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE grpc_ruby_plugin)
      endif()
    endif()
  endif()
endmacro()

if(NOT TARGET gRPC::grpc++_alts
   AND NOT TARGET gRPC::grpc++
   AND NOT TARGET gRPC::grpc)
  if(VCPKG_TOOLCHAIN)
    find_package(gRPC QUIET)
    find_package(grpc QUIET)
    project_third_party_grpc_import()
  endif()

  if(NOT TARGET gRPC::grpc++_alts
     AND NOT TARGET gRPC::grpc++
     AND NOT TARGET gRPC::grpc)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION)
      # This is related to abseil-cpp
      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.33.2")
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.42.0")
      endif()
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL "https://github.com/grpc/grpc.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR)
      project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR "grpc"
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION})
    endif()

    # Build host architecture grpc first
    if(CMAKE_CROSSCOMPILING)
      project_third_party_get_host_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR "grpc"
                                             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION})
      file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS "${CMAKE_COMMAND}"
                                                                      "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-host")
      message(STATUS "Dependency(${PROJECT_NAME}): Try to build grpc fo host architecture when crossing compiling")
      project_build_tools_append_cmake_host_options(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS)
      # Vcpkg
      if(DEFINED VCPKG_HOST_CRT_LINKAGE OR DEFINED CACHE{VCPKG_HOST_CRT_LINKAGE})
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
             "-DVCPKG_CRT_LINKAGE=${VCPKG_HOST_CRT_LINKAGE}")
      elseif(DEFINED VCPKG_CRT_LINKAGE OR DEFINED CACHE{VCPKG_CRT_LINKAGE})
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
             "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}")
      endif()
      # Shared or static
      project_third_party_append_build_shared_lib_var(
        "grpc" "GRPC" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS BUILD_SHARED_LIBS)

      # cmake-toolset
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
        "-DPROJECT_THIRD_PARTY_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
        "-DPROJECT_THIRD_PARTY_HOST_INSTALL_DIR=${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}"
        "-DPROJECT_THIRD_PARTY_PACKAGE_DIR=${PROJECT_THIRD_PARTY_PACKAGE_DIR}")
      if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE
         OR DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE})
        list(
          APPEND
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
          "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE}"
        )
      endif()

      foreach(CMD_ARG IN LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS)
        add_compiler_flags_to_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS_CMD "\"${CMD_ARG}\"")
      endforeach()

      # Build host
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH
         OR CMAKE_HOST_UNIX
         OR MSYS)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-host/run-build-host.sh.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}/run-build-host.sh" @ONLY NEWLINE_STYLE LF)

        # build
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}/run-build-host.sh"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-host/run-build-host.ps1.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}/run-build-host.ps1" @ONLY NEWLINE_STYLE CRLF)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-host/run-build-host.bat.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}/run-build-host.bat" @ONLY NEWLINE_STYLE CRLF)

        # build
        execute_process(
          COMMAND
            "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass -NonInteractive
            -NoLogo -File "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}/run-build-host.ps1"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
                                                                        "-DgRPC_INSTALL=ON")
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE
        "${CMAKE_CURRENT_LIST_DIR}/grpc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION}.patch")

    # Some versions has problem when linking with MSVC
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF")
    else()
      project_third_party_append_build_shared_lib_var(
        "grpc" "GRPC" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS BUILD_SHARED_LIBS)
    endif()

    list(
      APPEND
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
      "-DCMAKE_BUILD_TYPE=${gRPC_MSVC_CONFIGURE}"
      "-DgRPC_INSTALL_CSHARP_EXT=OFF"
      "-DgRPC_GFLAGS_PROVIDER=none"
      "-DgRPC_BENCHMARK_PROVIDER=none"
      "-DgRPC_BUILD_TESTS=OFF"
      "-DgRPC_BUILD_CODEGEN=${gRPC_BUILD_CODEGEN}")
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_MSVC_STATIC_RUNTIME=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_MSVC_STATIC_RUNTIME=OFF")
    endif()

    if(absl_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_ABSL_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_ABSL_PROVIDER=module"
           "-DgRPC_ABSL_PROVIDER=none")
    endif()
    if(TARGET c-ares::cares
       OR TARGET c-ares::cares_static
       OR TARGET c-ares::cares_shared
       OR CARES_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_CARES_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_CARES_PROVIDER=module"
           "-DgRPC_CARES_PROVIDER=none")
    endif()
    if(TARGET protobuf::protoc
       OR TARGET protobuf::libprotobuf
       OR TARGET protobuf::libprotobuf-lite)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_PROTOBUF_PROVIDER=package"
           "-DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_PROTOBUF_PROVIDER=module"
           "-DgRPC_PROTOBUF_PROVIDER=none")
    endif()
    if(TARGET re2::re2)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_RE2_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_RE2_PROVIDER=module"
           "-DgRPC_RE2_PROVIDER=none")
    endif()
    if(TARGET ZLIB::ZLIB)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_ZLIB_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_ZLIB_PROVIDER=module"
           "-DgRPC_ZLIB_PROVIDER=none")
    endif()
    if(OPENSSL_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_SSL_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_SSL_PROVIDER=module"
           "-DgRPC_SSL_PROVIDER=none")
    endif()
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DCMAKE_DEBUG_POSTFIX=d")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC)
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
        "-D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
        "-DProtobuf_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
        "-DPROTOBUF_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
    endif()

    # Other flags for find_configure_package
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS DISABLE_PARALLEL_BUILD)
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      gRPC
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_SYSTEM_LINKS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS}
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "grpc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL}")

    if(TARGET gRPC::grpc++_alts
       OR TARGET gRPC::grpc++
       OR TARGET gRPC::grpc)
      project_third_party_grpc_import()
    else()
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): grpc build failed.")
    endif()
  endif()
else()
  project_third_party_grpc_import()
endif()
