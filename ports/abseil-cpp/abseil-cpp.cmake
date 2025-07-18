# STL like library
# https://github.com/abseil/abseil-cpp.git
# git@github.com:abseil/abseil-cpp.git

include_guard(DIRECTORY)

# =========== third party abseil-cpp ==================
macro(PROJECT_THIRD_PARTY_ABSEIL_IMPORT)
  if(absl_FOUND)
    message(STATUS "Dependency(${PROJECT_NAME}): abseil-cpp found")
  endif()
endmacro()

if(NOT absl_FOUND)
  find_package(absl QUIET)
  project_third_party_abseil_import()

  if(NOT absl_FOUND)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION)

      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20250127.1")
      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20200225.3")
        elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20220623.2")
        endif()
      elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "15")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION "20240722.1")
      endif()
    endif()

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_TESTING=OFF" "-DABSL_BUILD_TESTING=OFF"
          "-DABSL_ENABLE_INSTALL=ON")
      # abseil do not set export, which may lead to unresolved external symbol
      #[[
      if(MSVC)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF"
             "-DABSL_BUILD_DLL=OFF")
      else()
      ]]
      project_third_party_append_build_shared_lib_var(
        "abseil" "GRPC" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS BUILD_SHARED_LIBS)
      # endif()

      project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS)

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()

    project_third_party_port_declare(abseil PORT_PREFIX "GRPC" GIT_URL "https://github.com/abseil/abseil-cpp.git")

    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "abseil-cpp"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION}")

    # Build host architecture flatc first
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_HOST_BUILDING AND CMAKE_CROSSCOMPILING)
      project_third_party_crosscompiling_host(
        "abseil"
        "${CMAKE_CURRENT_LIST_DIR}/crosscompiling-host"
        PORT_PREFIX
        "GRPC"
        RESULT_VARIABLE
        ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_HOST_BUILD_RESULT
        TEST_PATH
        "absl/base/config.h")
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_HOST_BUILD_RESULT EQUAL 0)
        message(FATAL_ERROR "Build host architecture abseil-cpp failed")
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_PATCH_FILE}")
    endif()

    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_INHERIT_OPTIONS
        CMAKE_INHERIT_BUILD_ENV CMAKE_INHERIT_FIND_ROOT_PATH CMAKE_INHERIT_BUILD_ENV_DISABLE_C_FLAGS)
    # Some versions of MSVC have problems with ABSL_HAVE_STD_ANY,ABSL_HAVE_STD_OPTIONAL,ABSL_HAVE_STD_VARIANT. We use
    # the settings from upstream.
    if(MSVC)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_INHERIT_OPTIONS
           CMAKE_INHERIT_BUILD_ENV_DISABLE_C_STANDARD CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS)
    endif()
    find_configure_package(
      PACKAGE
      absl
      BUILD_WITH_CMAKE
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_INHERIT_OPTIONS}
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "abseil-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_GRPC_ABSEIL_GIT_URL}")

    if(absl_FOUND)
      project_third_party_abseil_import()
    endif()
  endif()
else()
  project_third_party_abseil_import()
endif()
