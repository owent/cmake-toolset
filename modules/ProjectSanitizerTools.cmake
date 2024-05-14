# .rst: ProjectSanitizerTools
# ----------------
#
# build tools
#

include_guard(GLOBAL)

function(project_build_tools_sanitizer_get_name OUTPUT_VAR)
  foreach(COMPILE_OR_LINK_FLAG ${ARGN})
    if(COMPILE_OR_LINK_FLAG MATCHES "fsanitize=([^ \t\r\n]+)")
      set(${OUTPUT_VAR}
          "${CMAKE_MATCH_1}"
          PARENT_SCOPE)
      return()
    endif()
  endforeach()
  set(${OUTPUT_VAR}
      ""
      PARENT_SCOPE)
endfunction()

function(project_build_tools_sanitizer_try_get_static_link OUTPUT_VAR)
  unset(SANITIZER_NAME)
  project_build_tools_sanitizer_get_name(SANITIZER_NAME ${ARGN})
  if(NOT SANITIZER_NAME)
    set(${OUTPUT_VAR}
        ""
        PARENT_SCOPE)
    return()
  endif()

  string(TOUPPER "${SANITIZER_NAME}" SANITIZER_NAME_UPPER)
  if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_STATIC_LINK_${SANITIZER_NAME_UPPER})
    set(${OUTPUT_VAR}
        "${ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_STATIC_LINK_${SANITIZER_NAME_UPPER}}"
        PARENT_SCOPE)
    return()
  endif()

  unset(SANITIZER_TRY_STATIC_LIB)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
    if(SANITIZER_NAME STREQUAL "address")
      set(SANITIZER_TRY_STATIC_LIB "-static-libasan")
    elseif(SANITIZER_NAME STREQUAL "memory")
      set(SANITIZER_TRY_STATIC_LIB "-static-libmsan")
    elseif(SANITIZER_NAME STREQUAL "undefined")
      set(SANITIZER_TRY_STATIC_LIB "-static-libubsan")
    elseif(SANITIZER_NAME STREQUAL "thread")
      set(SANITIZER_TRY_STATIC_LIB "-static-libtsan")
    elseif(SANITIZER_NAME STREQUAL "hwaddress")
      set(SANITIZER_TRY_STATIC_LIB "-static-libhwasan")
    elseif(SANITIZER_NAME STREQUAL "dataflow")
      set(SANITIZER_TRY_STATIC_LIB "-static-libdfsan")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang")
    set(SANITIZER_TRY_STATIC_LIB "-static-libsan")
  else()
    if(SANITIZER_NAME STREQUAL "address")
      set(SANITIZER_TRY_STATIC_LIB "-static-libsan" "-static-libasan")
    elseif(SANITIZER_NAME STREQUAL "memory")
      set(SANITIZER_TRY_STATIC_LIB "-static-libsan")
    elseif(SANITIZER_NAME STREQUAL "undefined")
      set(SANITIZER_TRY_STATIC_LIB "-static-libsan" "-static-libubsan")
    elseif(SANITIZER_NAME STREQUAL "thread")
      set(SANITIZER_TRY_STATIC_LIB "-static-libsan" "-static-libtsan")
    elseif(SANITIZER_NAME STREQUAL "hwaddress")
      set(SANITIZER_TRY_STATIC_LIB "-static-libsan" "-static-libhwasan")
    elseif(SANITIZER_NAME STREQUAL "dataflow")
      set(SANITIZER_TRY_STATIC_LIB "-static-libsan")
    endif()
  endif()

  include(CheckCXXSourceCompiles)
  include(CMakePushCheckState)

  cmake_push_check_state()

  find_package(Threads)
  if(CMAKE_USE_PTHREADS_INIT)
    list(APPEND CMAKE_REQUIRED_LIBRARIES Threads::Threads)
    if(CMAKE_USE_PTHREADS_INIT)
      set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -pthread")
    endif()
  endif()

  set(CMAKE_REQUIRED_FLAGS_BACKUP "${CMAKE_REQUIRED_FLAGS}")
  foreach(TRY_STATIC_LIB ${SANITIZER_TRY_STATIC_LIB})
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS_BACKUP} ${TRY_STATIC_LIB}")

    check_cxx_source_compiles("int main() { return 0; }"
                              ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_STATIC_LINK_${SANITIZER_NAME_UPPER})
    if(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_STATIC_LINK_${SANITIZER_NAME_UPPER})
      unset(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_STATIC_LINK_${SANITIZER_NAME_UPPER} CACHE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_STATIC_LINK_${SANITIZER_NAME_UPPER}
          "${TRY_STATIC_LIB}"
          CACHE INTERNAL "Sanitizer static link flag for ${SANITIZER_NAME}")
      break()
    endif()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_STATIC_LINK_${SANITIZER_NAME_UPPER} CACHE)
  endforeach()

  cmake_pop_check_state()

  if(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_STATIC_LINK_${SANITIZER_NAME_UPPER})
    set(${OUTPUT_VAR}
        "${ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_STATIC_LINK_${SANITIZER_NAME_UPPER}}"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VAR}
        ""
        PARENT_SCOPE)
  endif()
endfunction()

function(project_build_tools_sanitizer_try_get_shared_link OUTPUT_VAR)
  unset(SANITIZER_NAME)
  project_build_tools_sanitizer_get_name(SANITIZER_NAME ${ARGN})
  if(NOT SANITIZER_NAME)
    set(${OUTPUT_VAR}
        ""
        PARENT_SCOPE)
    return()
  endif()

  string(TOUPPER "${SANITIZER_NAME}" SANITIZER_NAME_UPPER)
  if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_SHARED_LINK_${SANITIZER_NAME_UPPER})
    set(${OUTPUT_VAR}
        "${ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_SHARED_LINK_${SANITIZER_NAME_UPPER}}"
        PARENT_SCOPE)
    return()
  endif()

  unset(SANITIZER_TRY_SHARED_LIB)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID STREQUAL "GNU")
    if(SANITIZER_NAME STREQUAL "address")
      set(SANITIZER_TRY_SHARED_LIB "-lasan")
    elseif(SANITIZER_NAME STREQUAL "memory")
      set(SANITIZER_TRY_SHARED_LIB "-lmsan")
    elseif(SANITIZER_NAME STREQUAL "undefined")
      set(SANITIZER_TRY_SHARED_LIB "-lubsan")
    elseif(SANITIZER_NAME STREQUAL "thread")
      set(SANITIZER_TRY_SHARED_LIB "-ltsan")
    elseif(SANITIZER_NAME STREQUAL "hwaddress")
      set(SANITIZER_TRY_SHARED_LIB "-lhwasan")
    elseif(SANITIZER_NAME STREQUAL "dataflow")
      set(SANITIZER_TRY_SHARED_LIB "-ldfsan")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|AppleClang")
    set(SANITIZER_TRY_SHARED_LIB "-shared-libsan")
  else()
    if(SANITIZER_NAME STREQUAL "address")
      set(SANITIZER_TRY_SHARED_LIB "-shared-libsan" "-lasan")
    elseif(SANITIZER_NAME STREQUAL "memory")
      set(SANITIZER_TRY_SHARED_LIB "-shared-libsan")
    elseif(SANITIZER_NAME STREQUAL "undefined")
      set(SANITIZER_TRY_SHARED_LIB "-shared-libsan" "-lubsan")
    elseif(SANITIZER_NAME STREQUAL "thread")
      set(SANITIZER_TRY_SHARED_LIB "-shared-libsan" "-ltsan")
    elseif(SANITIZER_NAME STREQUAL "hwaddress")
      set(SANITIZER_TRY_SHARED_LIB "-shared-libsan" "-lhwasan")
    elseif(SANITIZER_NAME STREQUAL "dataflow")
      set(SANITIZER_TRY_SHARED_LIB "-shared-libsan")
    endif()
  endif()

  include(CheckCXXSourceCompiles)
  include(CMakePushCheckState)

  cmake_push_check_state()

  find_package(Threads)
  if(CMAKE_USE_PTHREADS_INIT)
    list(APPEND CMAKE_REQUIRED_LIBRARIES Threads::Threads)
    if(CMAKE_USE_PTHREADS_INIT)
      set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -pthread")
    endif()
  endif()

  set(CMAKE_REQUIRED_FLAGS_BACKUP "${CMAKE_REQUIRED_FLAGS}")
  foreach(TRY_SHARED_LIB ${SANITIZER_TRY_SHARED_LIB})
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS_BACKUP} ${TRY_SHARED_LIB}")

    check_cxx_source_compiles("int main() { return 0; }"
                              ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_SHARED_LINK_${SANITIZER_NAME_UPPER})
    if(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_SHARED_LINK_${SANITIZER_NAME_UPPER})
      unset(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_SHARED_LINK_${SANITIZER_NAME_UPPER} CACHE)
      set(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_SHARED_LINK_${SANITIZER_NAME_UPPER}
          "${TRY_SHARED_LIB}"
          CACHE INTERNAL "Sanitizer shared link flag for ${SANITIZER_NAME}")
      break()
    endif()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_TEST_SHARED_LINK_${SANITIZER_NAME_UPPER} CACHE)
  endforeach()

  cmake_pop_check_state()

  if(ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_SHARED_LINK_${SANITIZER_NAME_UPPER})
    set(${OUTPUT_VAR}
        "${ATFRAMEWORK_CMAKE_TOOLSET_SANITIZER_SHARED_LINK_${SANITIZER_NAME_UPPER}}"
        PARENT_SCOPE)
  else()
    set(${OUTPUT_VAR}
        ""
        PARENT_SCOPE)
  endif()
endfunction()
