# ABSL
# CARES
# Protobuf
# RE2
# SSL
# ZLIB

include_guard(GLOBAL)

if(CMAKE_CROSSCOMPILING)
  set(gRPC_BUILD_CODEGEN OFF)
  set(gRPC_CMAKE_CROSSCOMPILING ON)
else()
  set(gRPC_BUILD_CODEGEN ON)
  set(gRPC_CMAKE_CROSSCOMPILING OFF)
endif()

set(gRPC_MSVC_CONFIGURE ${CMAKE_BUILD_TYPE})

include("${CMAKE_CURRENT_LIST_DIR}/abseil-cpp.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/grpc.cmake")

# upb plugin is optional  and can only be imported after grpc
