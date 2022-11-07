# ABSL
# CARES
# Protobuf
# RE2
# SSL
# ZLIB

include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/abseil-cpp.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/grpc.cmake")

# upb plugin is optional  and can only be imported after grpc
