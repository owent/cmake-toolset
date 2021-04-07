# This is grpc, an asynchronous resolver library.
# https://github.com/grpc/grpc.git
# git@github.com:grpc/grpc.git
# https://grpc.io/

if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.10")
  include_guard(GLOBAL)
endif()

# =========== third party grpc ==================
macro(PROJECT_THIRD_PARTY_GRPC_IMPORT)
  if(TARGET gRPC::grpc++_alts)
    message(
      STATUS "grpc using target(${PROJECT_NAME}): gRPC::grpc++_alts (version: ${gRPC_VERSION})")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc++_alts)
  elseif(TARGET gRPC::grpc++)
    message(STATUS "grpc using target(${PROJECT_NAME}): gRPC::grpc++ (version: ${gRPC_VERSION})")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc++)
  elseif(TARGET gRPC::grpc)
    message(STATUS "grpc using target(${PROJECT_NAME}): gRPC::grpc (version: ${gRPC_VERSION})")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_LINK_NAME gRPC::grpc)
  endif()
endmacro()

if(NOT TARGET gRPC::grpc++_alts
   AND NOT TARGET gRPC::grpc++
   AND NOT TARGET gRPC::grpc)
  if(VCPKG_TOOLCHAIN)
    find_package(gRPC QUIET)
    project_third_party_grpc_import()
  endif()

  if(NOT TARGET gRPC::grpc++_alts
     AND NOT TARGET gRPC::grpc++
     AND NOT TARGET gRPC::grpc)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_DEFAULT_VERSION "v1.36.4")

    findconfigurepackage(
      PACKAGE
      gRPC
      BUILD_WITH_CMAKE
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_FLAGS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" # "-DBUILD_SHARED_LIBS=OFF"
      "-DgRPC_INSTALL=ON"
      "-DCMAKE_BUILD_TYPE=Release"
      "-DgRPC_ABSL_PROVIDER=package"
      "-DgRPC_CARES_PROVIDER=package"
      "-DgRPC_PROTOBUF_PROVIDER=package"
      "-DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG"
      "-DgRPC_RE2_PROVIDER=package"
      "-DgRPC_SSL_PROVIDER=package"
      "-DgRPC_ZLIB_PROVIDER=package"
      "-DgRPC_GFLAGS_PROVIDER=none"
      "-DgRPC_BENCHMARK_PROVIDER=none"
      "-DgRPC_BUILD_TESTS=OFF"
      "-DgRPC_BUILD_CODEGEN=${gRPC_BUILD_CODEGEN}"
      "-DCMAKE_CROSSCOMPILING:BOOL=${gRPC_CMAKE_CROSSCOMPILING}"
      MSVC_CONFIGURE
      ${gRPC_MSVC_CONFIGURE}
      WORKING_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${CMAKE_CURRENT_BINARY_DIR}/deps/grpc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_DEFAULT_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
      PREFIX_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "grpc-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_DEFAULT_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_DEFAULT_VERSION}"
      GIT_URL
      "https://github.com/grpc/grpc.git")

    if(TARGET gRPC::grpc++_alts
       OR TARGET gRPC::grpc++
       OR TARGET gRPC::grpc)
      project_third_party_grpc_import()
    else()
      message(FATAL_ERROR "grpc build failed.")
    endif()
  endif()
else()
  project_third_party_grpc_import()
endif()
