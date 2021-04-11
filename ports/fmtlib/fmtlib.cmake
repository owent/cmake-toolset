include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_FMTLIB_IMPORT)
  if(TARGET fmt::fmt-header-only)
    message(STATUS "Dependency(${PROJECT_NAME}): fmtlib using target fmt::fmt-header-only")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_LINK_NAME fmt::fmt-header-only)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_LINK_NAME})
  elseif(TARGET fmt::fmt)
    message(STATUS "Dependency(${PROJECT_NAME}): fmtlib using target fmt::fmt")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_LINK_NAME fmt::fmt)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES
         ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_LINK_NAME})
  else()
    message(STATUS "Dependency(${PROJECT_NAME}): fmtlib support disabled")
  endif()
endmacro()

if(NOT TARGET fmt::fmt-header-only
   AND NOT TARGET fmt::fmt
   AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TEST_STD_FORMAT)
  if(VCPKG_TOOLCHAIN)
    find_package(fmt QUIET)
    project_third_party_fmtlib_import()
  endif()

  if(NOT TARGET fmt::fmt-header-only
     AND NOT TARGET fmt::fmt
     AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TEST_STD_FORMAT)
    include(CheckCXXSourceCompiles)
    if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TEST_STD_FORMAT)
      check_cxx_source_compiles(
        "#include <format>
         #include <iostream>
         #include <string>
         int main() {
             std::cout<< std::format(\"The answer is {}.\", 42)<< std::endl;
             char buffer[64] = {0};
             const auto result = std::format_to_n(buffer, sizeof(buffer), \"{} {}: {}\", \"Hello\", \"World!\", 42);
             std::cout << \"Buffer: \" << buffer << \",Untruncated output size = \" << result.size << std::endl;
             return 0;
         }"
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TEST_STD_FORMAT)
    endif()

    # =========== third party fmtlib ==================
    if(NOT TARGET fmt::fmt-header-only
       AND NOT TARGET fmt::fmt
       AND NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_TEST_STD_FORMAT)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION "7.1.3")
      endif()
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_GIT_URL)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_GIT_URL
            "https://github.com/fmtlib/fmt.git")
      endif()
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_BUILD_OPTIONS)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_BUILD_OPTIONS
            "-DCMAKE_POSITION_INDEPENDENT_CODE=YES" "-DFMT_DOC=OFF" "-DFMT_INSTALL=ON"
            "-DFMT_TEST=OFF" "-DFMT_FUZZ=OFF" "-DFMT_CUDA_TEST=OFF")
      endif()
      project_third_party_append_build_shared_lib_var(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_BUILD_OPTIONS BUILD_SHARED_LIBS)

      set(FMT_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
      set(Fmt_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
      set(fmt_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})

      findconfigurepackage(
        PACKAGE
        fmt
        BUILD_WITH_CMAKE
        CMAKE_INHIRT_BUILD_ENV
        CMAKE_INHIRT_BUILD_ENV_DISABLE_C_FLAGS
        CMAKE_INHIRT_BUILD_ENV_DISABLE_ASM_FLAGS
        CMAKE_FLAGS
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_BUILD_OPTIONS}
        WORKING_DIRECTORY
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
        BUILD_DIRECTORY
        "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/fmt-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
        PREFIX_DIRECTORY
        "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
        SRC_DIRECTORY_NAME
        "fmt-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION}"
        GIT_BRANCH
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_VERSION}"
        GIT_URL
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_FMTLIB_GIT_URL}")

      if(fmt_FOUND)
        project_third_party_fmtlib_import()
      endif()
    endif()
  endif()
else()
  project_third_party_fmtlib_import()
endif()
