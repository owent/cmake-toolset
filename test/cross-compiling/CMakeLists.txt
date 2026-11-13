cmake_minimum_required(VERSION 3.16)

project(cmake-toolset-cross-compiling-test LANGUAGES NONE)
enable_testing()

if(CMAKE_HOST_WIN32)
  find_package(Git QUIET)
  get_filename_component(CMAKE_TOOLSET_TEST_GIT_DIR "${GIT_EXECUTABLE}" DIRECTORY)
  find_program(
    CMAKE_TOOLSET_TEST_BASH
    NAMES bash
    PATHS "${CMAKE_TOOLSET_TEST_GIT_DIR}/../bin"
    NO_DEFAULT_PATH)
else()
  find_program(CMAKE_TOOLSET_TEST_BASH NAMES bash)
endif()

if(CMAKE_TOOLSET_TEST_BASH)
  find_program(
    CMAKE_TOOLSET_TEST_NINJA
    NAMES ninja
    NO_CMAKE_FIND_ROOT_PATH)
  if(CMAKE_TOOLSET_TEST_NINJA)
    add_test(NAME cmake-toolset.android-wrapper-generators
             COMMAND "${CMAKE_TOOLSET_TEST_BASH}" "${CMAKE_CURRENT_LIST_DIR}/android-wrapper.sh"
                     "${CMAKE_CURRENT_BINARY_DIR}/wrapper" "${CMAKE_COMMAND}")
  endif()
  if(CMAKE_HOST_WIN32)
    set(CMAKE_TOOLSET_TEST_GENERATOR_OPTIONS -G "${CMAKE_GENERATOR}")
    if(CMAKE_GENERATOR_PLATFORM)
      list(APPEND CMAKE_TOOLSET_TEST_GENERATOR_OPTIONS -A "${CMAKE_GENERATOR_PLATFORM}")
    endif()
    if(CMAKE_GENERATOR_TOOLSET)
      list(APPEND CMAKE_TOOLSET_TEST_GENERATOR_OPTIONS -T "${CMAKE_GENERATOR_TOOLSET}")
    endif()
    add_test(
      NAME cmake-toolset.openssl-cross-environment
      COMMAND "${CMAKE_COMMAND}" -S "${CMAKE_CURRENT_LIST_DIR}/openssl" -B "${CMAKE_CURRENT_BINARY_DIR}/openssl"
              ${CMAKE_TOOLSET_TEST_GENERATOR_OPTIONS} "-DATFRAMEWORK_CMAKE_TOOLSET_BASH=${CMAKE_TOOLSET_TEST_BASH}")
  endif()
endif()
