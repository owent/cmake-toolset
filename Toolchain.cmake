foreach(TOOLCHAIN_FILE ${ATFRAMEWORK_CHAINLOAD_TOOLCHAIN_FILE})
  include("${TOOLCHAIN_FILE}")
endforeach()

include("${CMAKE_CURRENT_LIST_DIR}/Import.cmake")
