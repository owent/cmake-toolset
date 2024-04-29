include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_TBB_IMPORT)
  if(TARGET TBB::tbb)
    message(STATUS "Dependency(${PROJECT_NAME}): tbb using target TBB::tbb")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_NAME TBB::tbb)
    project_build_tools_patch_default_imported_config(TBB::tbb)
  endif()
endmacro()

if(NOT TARGET TBB::tbb)
  find_package(TBB QUIET)
  project_third_party_tbb_import()

  if(NOT TARGET TBB::tbb AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_NAME)
    project_third_party_port_declare(
      TBB
      VERSION
      "v2021.12.0"
      GIT_URL
      "https://github.com/oneapi-src/oneTBB.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DTBB_TEST=OFF"
      "-DTBB_EXAMPLES=OFF"
      "-DTBB_STRICT=OFF"
      "-DCMAKE_MSVC_RUNTIME_LIBRARY=${CMAKE_MSVC_RUNTIME_LIBRARY}")
    if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
      include(CheckCSourceCompiles)
      cmake_push_check_state()
      list(APPEND CMAKE_REQUIRED_LINK_OPTIONS "-Wl,--undefined-version")
      message(STATUS "Test -Wl,--undefined-version")
      check_c_source_compiles("int main() { return 0; }"
                              ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_TEST_UNDEFINED_VERSION)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_TEST_UNDEFINED_VERSION)
        if(ATFRAMEWORK_CMAKE_TOOLSET_LINKER_OPTIONS)
          string(REPLACE ";" "|" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_FLAGS
                         "${ATFRAMEWORK_CMAKE_TOOLSET_LINKER_OPTIONS}|-Wl,--undefined-version")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS
               "-DTBB_LIB_LINK_FLAGS=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_LINK_FLAGS}")
        else()
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS
               "-DTBB_LIB_LINK_FLAGS=-Wl,--undefined-version")
        endif()
      endif()
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_TEST_UNDEFINED_VERSION CACHE)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_TEST_UNDEFINED_VERSION)
      cmake_pop_check_state()
    endif()
    project_third_party_try_patch_file(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}"
                                       "tbb" "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_VERSION}")

    project_third_party_append_build_shared_lib_var("TBB" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      TBB
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      LIST_SEPARATOR
      "|"
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_SRC_DIRECTORY_NAME}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_GIT_URL}")

    if(TARGET TBB::tbb)
      project_third_party_tbb_import()
    endif()
  endif()
else()
  project_third_party_tbb_import()
endif()

if(NOT TARGET TBB::tbb)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TBB_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Can not build tbb.")
endif()
