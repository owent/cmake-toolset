include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_LIBCOPP_IMPORT)
  if(TARGET libcopp::cotask)
    echowithcolor(COLOR GREEN
                  "-- Dependency(${PROJECT_NAME}): libcopp using target: libcopp::cotask")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES libcopp::cotask)
  elseif(TARGET cotask)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): libcopp using target: cotask")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PUBLIC_LINK_NAMES cotask)
  endif()
endmacro()

if(NOT TARGET libcopp::cotask AND NOT cotask)
  if(VCPKG_TOOLCHAIN)
    find_package(libcopp QUIET CONFIG)
    project_third_party_libcopp_import()
  endif()

  if(NOT TARGET libcopp::cotask AND NOT cotask)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION "v2")
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_GIT_URL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_GIT_URL
          "https://github.com/owt5008137/libcopp.git")
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_REPOSITORY_DIR
        "${PROJECT_3RD_PARTY_PACKAGE_DIR}/libcopp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION}"
    )

    project_git_clone_repository(
      URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_GIT_URL}"
      REPO_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_REPOSITORY_DIR}"
      BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION}"
      CHECK_PATH
      "CMakeLists.txt")

    set(LIBCOPP_USE_DYNAMIC_LIBRARY
        ${ATFRAMEWORK_USE_DYNAMIC_LIBRARY}
        CACHE BOOL "Build dynamic libraries of libcopp" FORCE)
    add_subdirectory(
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_REPOSITORY_DIR}"
      "${CMAKE_CURRENT_BINARY_DIR}/dependency-buildtree/libcopp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION}/build_jobs_${PROJECT_PREBUILT_PLATFORM_NAME}"
    )

    project_third_party_libcopp_import()
  endif()
else()
  project_third_party_libcopp_import()
endif()
