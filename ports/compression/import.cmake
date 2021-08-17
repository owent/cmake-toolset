include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/zlib.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/lz4.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/snappy.cmake")

# zstd depends zlib and lz4
include("${CMAKE_CURRENT_LIST_DIR}/zstd.cmake")
