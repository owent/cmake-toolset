# An xUnit test framework.
# https://github.com/google/googletest/
# git@github.com:google/googletest.git

include_guard(GLOBAL)

# =========== third party GTest ==================
macro(PROJECT_THIRD_PARTY_GTEST_IMPORT)
  if(TARGET GTest::gtest)
    message(STATUS "Dependency(${PROJECT_NAME}): Target GTest::gtest found")
    project_build_tools_patch_default_imported_config(GTest::gtest)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GTEST_LINK_NAME GTest::gtest)
  elseif(TARGET GTest::GTest)
    message(STATUS "Dependency(${PROJECT_NAME}): Target GTest::GTest found")
    project_build_tools_patch_default_imported_config(GTest::GTest)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GTEST_LINK_NAME GTest::GTest)
  endif()
  if(TARGET GTest::gtest_main)
    message(STATUS "Dependency(${PROJECT_NAME}): Target GTest::gtest_main found")
    project_build_tools_patch_default_imported_config(GTest::gtest_main)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GTEST_MAIN_LINK_NAME GTest::gtest_main)
  elseif(TARGET GTest::Main)
    message(STATUS "Dependency(${PROJECT_NAME}): Target GTest::Main found")
    project_build_tools_patch_default_imported_config(GTest::Main)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GTEST_MAIN_LINK_NAME GTest::Main)
  endif()
  if(TARGET GTest::gmock)
    message(STATUS "Dependency(${PROJECT_NAME}): Target GTest::gmock found")
    project_build_tools_patch_default_imported_config(GTest::gmock)
  endif()
  if(TARGET GTest::gmock_main)
    message(STATUS "Dependency(${PROJECT_NAME}): Target GTest::gmock_main found")
    project_build_tools_patch_default_imported_config(GTest::gmock_main)
  endif()
endmacro()

if(NOT TARGET GTest::gtest
   AND NOT TARGET GTest::gtest_main
   AND NOT TARGET GTest::GTest
   AND NOT TARGET GTest::Main)
  if(VCPKG_TOOLCHAIN)
    find_package(GTest QUIET CONFIG)
    project_third_party_gtest_import()
  endif()

  if(NOT TARGET GTest::gtest
     AND NOT TARGET GTest::gtest_main
     AND NOT TARGET GTest::GTest
     AND NOT TARGET GTest::Main)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_VERSION "release-1.10.0")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GIT_URL "https://github.com/google/googletest.git")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_DIR)
      project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_DIR "gtest"
                                        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_VERSION})
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_OPTIONS "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
                                                                    "-DBUILD_GMOCK=ON" "-DINSTALL_GTEST=ON")
    endif()
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_OPTIONS "-DCMAKE_DEBUG_POSTFIX=d")
    endif()
    project_third_party_append_build_shared_lib_var(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_OPTIONS
                                                    BUILD_SHARED_LIBS)

    find_configure_package(
      PACKAGE
      GTest
      BUILD_WITH_CMAKE
      FIND_PACKAGE_FLAGS
      CONFIG
      CMAKE_INHIRT_BUILD_ENV
      CMAKE_INHIRT_FIND_ROOT_PATH
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "gtest-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GTEST_GIT_URL}")

    if(TARGET GTest::gtest
       OR TARGET GTest::gtest_main
       OR TARGET GTest::GTest
       OR TARGET GTest::Main)
      project_third_party_gtest_import()
    endif()
  endif()
else()
  project_third_party_gtest_import()
endif()

if(NOT TARGET GTest::gtest
   AND NOT TARGET GTest::gtest_main
   AND NOT TARGET GTest::GTest
   AND NOT TARGET GTest::Main
   AND NOT TARGET GTest::gmock
   AND NOT TARGET GTest::gmock_main)
  message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Build GTest failed.")
endif()
