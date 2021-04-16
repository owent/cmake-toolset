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
      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS
                                                     "4.9.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.33.2")
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION "v1.37.0")
      endif()
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_GIT_URL
          "https://github.com/grpc/grpc.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR)
      project_third_party_get_build_dir(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_DIR "grpc"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_VERSION})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DgRPC_INSTALL=ON")
    endif()
    project_third_party_append_find_root_args(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS)
    project_third_party_append_build_shared_lib_var(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS BUILD_SHARED_LIBS)

    list(
      APPEND
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
      "-DCMAKE_BUILD_TYPE=${gRPC_MSVC_CONFIGURE}"
      "-DgRPC_GFLAGS_PROVIDER=none"
      "-DgRPC_BENCHMARK_PROVIDER=none"
      "-DgRPC_BUILD_TESTS=OFF"
      "-DgRPC_BUILD_CODEGEN=${gRPC_BUILD_CODEGEN}"
      "-DCMAKE_CROSSCOMPILING:BOOL=${gRPC_CMAKE_CROSSCOMPILING}")

    if(absl_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DgRPC_ABSL_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_ABSL_PROVIDER=module"
           "-DgRPC_ABSL_PROVIDER=none")
    endif()
    if(TARGET c-ares::cares
       OR TARGET c-ares::cares_static
       OR TARGET c-ares::cares_shared
       OR CARES_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DgRPC_CARES_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_CARES_PROVIDER=module"
           "-DgRPC_CARES_PROVIDER=none")
    endif()
    if(TARGET protobuf::protoc
       OR TARGET protobuf::libprotobuf
       OR TARGET protobuf::libprotobuf-lite)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DgRPC_PROTOBUF_PROVIDER=package" "-DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_PROTOBUF_PROVIDER=module"
           "-DgRPC_PROTOBUF_PROVIDER=none")
    endif()
    if(TARGET re2::re2)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DgRPC_RE2_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_RE2_PROVIDER=module"
           "-DgRPC_RE2_PROVIDER=none")
    endif()
    if(TARGET ZLIB::ZLIB)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DgRPC_ZLIB_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_ZLIB_PROVIDER=module"
           "-DgRPC_ZLIB_PROVIDER=none")
    endif()
    if(OPENSSL_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DgRPC_SSL_PROVIDER=package")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           # "-DgRPC_SSL_PROVIDER=module"
           "-DgRPC_SSL_PROVIDER=none")
    endif()
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DCMAKE_DEBUG_POSTFIX=d")
    endif()

    if(NOT "${PROJECT_PREBUILT_PLATFORM_NAME}" STREQUAL "${PROJECT_PREBUILT_HOST_PLATFORM_NAME}"
       AND Protobuf_PROTOC_EXECUTABLE)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_GRPC_BUILD_OPTIONS
           "-DProtobuf_PROTOC_EXECUTABLE=${Protobuf_PROTOC_EXECUTABLE}")

    endif()

    if(MINGW)
      set(PATCH_BACKUP_CMAKE_C_STANDARD_LIBRARIES ${CMAKE_C_STANDARD_LIBRARIES})
      set(PATCH_BACKUP_CMAKE_CXX_STANDARD_LIBRARIES ${CMAKE_CXX_STANDARD_LIBRARIES})
      add_compiler_flags_to_var_unique(
        CMAKE_C_STANDARD_LIBRARIES
        "-lcrypt32"
        "-liphlpapi"
        "-lpsapi"
        "-luserenv"
        "-lws2_32"
        "-lgcc")
      add_compiler_flags_to_var_unique(
        CMAKE_CXX_STANDARD_LIBRARIES
        "-lcrypt32"
        "-liphlpapi"
        "-lpsapi"
        "-luserenv"
        "-lws2_32"
        "-lgcc")
    elseif(APPLE)
      set(PATCH_BACKUP_CMAKE_C_STANDARD_LIBRARIES ${CMAKE_C_STANDARD_LIBRARIES})
      set(PATCH_BACKUP_CMAKE_CXX_STANDARD_LIBRARIES ${CMAKE_CXX_STANDARD_LIBRARIES})
      add_compiler_flags_to_var_unique(CMAKE_C_STANDARD_LIBRARIES "-lresolv")
      add_compiler_flags_to_var_unique(CMAKE_CXX_STANDARD_LIBRARIES "-lresolv")
    endif()

    find_configure_package(
      PACKAGE
      gRPC
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_FIND_ROOT_PATH
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
    if(PATCH_BACKUP_CMAKE_C_STANDARD_LIBRARIES)
      set(CMAKE_C_STANDARD_LIBRARIES ${PATCH_BACKUP_CMAKE_C_STANDARD_LIBRARIES})
      unset(PATCH_BACKUP_CMAKE_C_STANDARD_LIBRARIES)
    endif()
    if(PATCH_BACKUP_CMAKE_CXX_STANDARD_LIBRARIES)
      set(CMAKE_CXX_STANDARD_LIBRARIES ${PATCH_BACKUP_CMAKE_CXX_STANDARD_LIBRARIES})
      unset(PATCH_BACKUP_CMAKE_CXX_STANDARD_LIBRARIES)
    endif()

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
