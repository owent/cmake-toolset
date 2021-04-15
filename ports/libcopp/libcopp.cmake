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

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_DIR)
      project_third_party_get_build_dir(
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_DIR "libcopp"
        ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION})
    endif()
    if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_DIR}")
      file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_DIR}")
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_REPOSITORY_DIR
        "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libcopp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_VERSION}"
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

    if(ANDROID)
      if(CMAKE_ANDROID_ARCH_ABI MATCHES "^armeabi(-v7a)?$")
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "arm"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL arm64-v8a)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "arm64"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "i386"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL x86_64)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "x86_64"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL mips)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "mips32"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL mips64)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "mips64"
            CACHE STRING "set system platform for libcopp." FORCE)
      else()
        message(FATAL_ERROR "Invalid Android ABI: ${CMAKE_ANDROID_ARCH_ABI}.")
      endif()
    elseif(CMAKE_OSX_ARCHITECTURES)
      if(CMAKE_OSX_ARCHITECTURES MATCHES "armv7(s?)")
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "arm"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_OSX_ARCHITECTURES MATCHES "arm64.*")
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "arm64"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_OSX_ARCHITECTURES MATCHES)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "i386"
            CACHE STRING "set system platform for libcopp." FORCE)
      elseif(CMAKE_OSX_ARCHITECTURES STREQUAL x86_64)
        set(LIBCOPP_FCONTEXT_OS_PLATFORM
            "x86_64"
            CACHE STRING "set system platform for libcopp." FORCE)
      else()
        message(FATAL_ERROR "Invalid OSX ABI: ${CMAKE_OSX_ARCHITECTURES}.")
      endif()
    endif()

    add_subdirectory("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_REPOSITORY_DIR}"
                     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCOPP_BUILD_DIR}")

    project_third_party_libcopp_import()
  endif()
else()
  project_third_party_libcopp_import()
endif()
