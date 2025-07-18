# This is grpc, an asynchronous resolver library.
# https://github.com/grpc/grpc.git
# git@github.com:grpc/grpc.git
# https://grpc.io/

include_guard(DIRECTORY)

# =========== third party grpc ==================
function(PROJECT_THIRD_PARTY_GRPC_FIND_PLUGIN VAR_NAME PLUGIN_NAME WITH_TARGET)
  if(${WITH_TARGET} AND TARGET gRPC::${PLUGIN_NAME})
    project_build_tools_get_imported_location(${VAR_NAME} gRPC::${PLUGIN_NAME})
  else()
    find_program(${VAR_NAME} ${PLUGIN_NAME})
    if(NOT ${VAR_NAME} AND VCPKG_INSTALLED_DIR)
      if(VCPKG_HOST_TRIPLET)
        message(
          STATUS
            "Dependency(${PROJECT_NAME}): grpc try to find ${PLUGIN_NAME} in ${VCPKG_INSTALLED_DIR}/${VCPKG_HOST_TRIPLET}/tools/grpc"
        )
        find_program(
          ${VAR_NAME} ${PLUGIN_NAME}
          PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_HOST_TRIPLET}/tools/grpc"
          NO_DEFAULT_PATH)
      else()
        message(
          STATUS
            "Dependency(${PROJECT_NAME}): grpc try to find ${PLUGIN_NAME} in ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/grpc"
        )
        find_program(
          ${VAR_NAME} ${PLUGIN_NAME}
          PATHS "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/grpc"
          NO_DEFAULT_PATH)
      endif()
    endif()
  endif()
  if(${VAR_NAME})
    set(${VAR_NAME}
        ${${VAR_NAME}}
        PARENT_SCOPE)
  endif()
endfunction()

macro(PROJECT_THIRD_PARTY_GRPC_IMPORT)
  if(TARGET gRPC::grpc++_alts
     OR TARGET gRPC::grpc++
     OR TARGET gRPC::grpc)
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME)
    if(TARGET gRPC::grpc++_error_details)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc++_error_details)
    endif()
    if(TARGET gRPC::grpc++_reflection)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc++_reflection)
    endif()
    if(TARGET gRPC::grpcpp_channelz)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpcpp_channelz)
    endif()
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

    if(CMAKE_CROSSCOMPILING)
      # Just like find_program(_gRPC_CPP_PLUGIN grpc_cpp_plugin) in CMakeLists.txt in grpc
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE
                                           grpc_cpp_plugin OFF)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE
                                           grpc_csharp_plugin OFF)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE
                                           grpc_node_plugin OFF)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECTIVE_C_PLUGIN_EXECUTABLE
                                           grpc_objective_c_plugin OFF)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE
                                           grpc_php_plugin OFF)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE
                                           grpc_python_plugin OFF)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE
                                           grpc_ruby_plugin OFF)
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): grpc executables for crosscompiling:
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECTIVE_C_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECTIVE_C_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE}
  ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE}
          ")
    else()
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE
                                           grpc_cpp_plugin ON)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CSHARP_PLUGIN_EXECUTABLE
                                           grpc_csharp_plugin ON)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_NODE_PLUGIN_EXECUTABLE
                                           grpc_node_plugin ON)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_OBJECTIVE_C_PLUGIN_EXECUTABLE
                                           grpc_objective_c_plugin ON)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PHP_PLUGIN_EXECUTABLE
                                           grpc_php_plugin ON)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_PYTHON_PLUGIN_EXECUTABLE
                                           grpc_python_plugin ON)
      project_third_party_grpc_find_plugin(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_RUBY_PLUGIN_EXECUTABLE
                                           grpc_ruby_plugin ON)
    endif()
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME)
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): gRPC found and using targets.(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME})"
      )
    endif()
  endif()
endmacro()

if(NOT TARGET gRPC::grpc++_alts
   AND NOT TARGET gRPC::grpc++
   AND NOT TARGET gRPC::grpc)
  find_package(gRPC QUIET)
  find_package(grpc QUIET)
  project_third_party_grpc_import()

  if(NOT TARGET gRPC::grpc++_alts
     AND NOT TARGET gRPC::grpc++
     AND NOT TARGET gRPC::grpc)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_UPB_LINK_NAME)
      message(FATAL_ERROR "upb should be included after grpc")
    endif()
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION)
      # This is related to abseil-cpp
      if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.33.2")
        elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.43.2")
        endif()
      elseif(MSVC)
        if(MSVC_VERSION LESS 1930)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.68.2")
        endif()
      endif()

      # TODO MSVC can only use C++17 in find_configure_package() below, we should remove the CMAKE_CXX_STANDARD patch
      # after gRPC support MSVC with higher standard.
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION)
        if(absl_FOUND AND absl_VERSION VERSION_GREATER_EQUAL "20230125")
          # MSVC 1944 con not compile src/core/resolver/xds/xds_config.h in 1.73.1(std::variant), so we use 1.70.2
          if(MSVC AND MSVC_VERSION LESS 1945)
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.70.2")
          elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "15")
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.68.2")
          else()
            set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.73.1")
          endif()
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.54.3")
        endif()
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
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING AND CMAKE_CROSSCOMPILING)
      project_third_party_get_host_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR "grpc"
                                             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION})
      get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR
                             "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_DIR}" DIRECTORY)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}/crosscompiling-grpc-host")
      file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
          "${CMAKE_COMMAND}" "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-grpc-host")
      message(STATUS "Dependency(${PROJECT_NAME}): Try to build grpc fo host architecture when crossing compiling")
      project_build_tools_append_cmake_host_options(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS)
      # Vcpkg
      if(DEFINED VCPKG_HOST_CRT_LINKAGE)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
             "-DVCPKG_CRT_LINKAGE=${VCPKG_HOST_CRT_LINKAGE}")
      elseif(DEFINED VCPKG_CRT_LINKAGE)
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
      if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE)
        list(
          APPEND
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS
          "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE}"
          "-DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_JOBS}"
        )
      endif()

      foreach(CMD_ARG IN LISTS ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS)
        # string(REPLACE ";" "\\;" CMD_ARG_UNESCAPE "${CMD_ARG}")
        set(CMD_ARG_UNESCAPE "${CMD_ARG}")
        project_build_tools_append_space_one_flag_to_var(
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS_PWSH "\"${CMD_ARG_UNESCAPE}\"")
        string(REPLACE "\$" "\\\$" CMD_ARG_UNESCAPE "${CMD_ARG_UNESCAPE}")
        project_build_tools_append_space_one_flag_to_var(
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_BUILD_FLAGS_BASH "\"${CMD_ARG_UNESCAPE}\"")
      endforeach()
      unset(CMD_ARG_UNESCAPE)

      # Build host
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_PWSH
         OR CMAKE_HOST_UNIX
         OR MSYS)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-grpc-host/run-build-host.sh.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}/run-build-host.sh" @ONLY NEWLINE_STYLE LF)

        # build
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}/run-build-host.sh"
          WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      else()
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-grpc-host/run-build-host.ps1.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}/run-build-host.ps1" @ONLY
          NEWLINE_STYLE CRLF)
        configure_file(
          "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-grpc-host/run-build-host.bat.in"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}/run-build-host.bat" @ONLY
          NEWLINE_STYLE CRLF)

        # build
        execute_process(
          COMMAND
            "${ATFRAMEWORK_CMAKE_TOOLSET_PWSH}" -NoProfile -InputFormat None -ExecutionPolicy Bypass -NonInteractive
            -NoLogo -File "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}/run-build-host.ps1"
          WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_HOST_TOOL_BUILD_DIR}"
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
    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "grpc"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION}")

    # Some versions has problem when linking with MSVC
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF")
    else()
      project_third_party_append_build_shared_lib_var(
        "grpc" "GRPC" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS BUILD_SHARED_LIBS)
    endif()

    if(NOT gRPC_MSVC_CONFIGURE)
      if(ABSEIL_CPP_MSVC_CONFIGURE)
        set(gRPC_MSVC_CONFIGURE ${ABSEIL_CPP_MSVC_CONFIGURE})
      else()
        set(gRPC_MSVC_CONFIGURE "${CMAKE_BUILD_TYPE}")
      endif()
    endif()
    if(CMAKE_CROSSCOMPILING)
      set(gRPC_BUILD_CODEGEN OFF)
    else()
      set(gRPC_BUILD_CODEGEN ON)
    endif()

    list(
      APPEND
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
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
    if(TARGET upb::upb)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_UPB_PROVIDER=package")
    endif()
    if(OPENSSL_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS "-DgRPC_SSL_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_SSL_PROVIDER=module"
           "-DgRPC_SSL_PROVIDER=none")
    endif()

    project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC)
      list(
        APPEND
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
        "-D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
        "-DProtobuf_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}"
        "-DPROTOBUF_PROTOC_EXECUTABLE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BIN_PROTOC}")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE}")
      message(
        STATUS
          "Dependency(${PROJECT_NAME}): grpc use patch file ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_PATCH_FILE}."
      )
    endif()

    # Patch CMAKE_CXX_STANDARD
    if(CMAKE_CXX_STANDARD)
      if(CMAKE_CXX_STANDARD GREATER 20)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BACKUP_CXX_STANDARD ${CMAKE_CXX_STANDARD})
        set(CMAKE_CXX_STANDARD 20)
      endif()
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
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL}"
      GIT_ENABLE_SUBMODULE)
    # Restore C++ standard options
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BACKUP_CXX_STANDARD)
      set(CMAKE_CXX_STANDARD ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BACKUP_CXX_STANDARD})
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BACKUP_CXX_STANDARD)
    endif()

    if(TARGET gRPC::grpc++_alts
       OR TARGET gRPC::grpc++
       OR TARGET gRPC::grpc)
      project_third_party_grpc_import()
    else()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
        project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR}")
      endif()
      message(FATAL_ERROR "Dependency(${PROJECT_NAME}): grpc build failed.")
    endif()
  endif()
else()
  project_third_party_grpc_import()
endif()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_CPP_PLUGIN_EXECUTABLE)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): grpc build success but failed to find grpc_cpp_plugin.")
endif()
