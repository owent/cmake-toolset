include_guard(DIRECTORY)

option(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS
       "Allow build protobuf as dynamic(May cause duplicate symbol[File already exists in database])" ON)
if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_STANDALONE_UPB)
  option(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_STANDALONE_UPB
         "Use the version of protobuf which is compatiable with standalone upb" OFF)
endif()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION)
  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION)
    if(absl_FOUND AND absl_VERSION VERSION_GREATER_EQUAL "20230125")
      #[[ upb generator in protobuf v26 will crash, and so we do not use it
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_STANDALONE_UPB)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v25.2")
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v28.2")
      endif()
      ]]
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v28.2")
    else()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.21.12")
    endif()

    if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
      if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.5.1")
      endif()
    elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
      if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "3.3")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.5.1")
      elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "6.0") # With std::to_string
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.13.0")
      endif()
    elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
      if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "5.0")
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.5.1")
      elseif(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0") # With std::to_string
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.13.0")
      endif()
    elseif(MSVC)
      if(MSVC_VERSION LESS 1900)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION "v3.5.1")
      endif()
    endif()
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_BUILD_OPTIONS TRUE)
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_BUILD_OPTIONS FALSE)
  endif()
  project_third_party_port_declare(
    protobuf
    VERSION
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_DEFAULT_VERSION}"
    GIT_URL
    "https://github.com/protocolbuffers/protobuf.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-Dprotobuf_BUILD_TESTS=OFF"
    "-Dprotobuf_BUILD_EXAMPLES=OFF")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION MATCHES "^v(.*)")
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION "${CMAKE_MATCH_1}")
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION}")
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ENABLE_BUILD_OPTIONS)
    project_build_tools_auto_append_postfix(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
    if(CMAKE_DEBUG_POSTFIX)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
           "-Dprotobuf_DEBUG_POSTFIX=${CMAKE_DEBUG_POSTFIX}")
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_MSVC_STATIC_RUNTIME=ON")
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_MSVC_STATIC_RUNTIME=OFF")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_ALLOW_SHARED_LIBS)
      project_third_party_append_build_shared_lib_var(
        "protobuf" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS protobuf_BUILD_SHARED_LIBS
        BUILD_SHARED_LIBS)
    else()
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_BUILD_SHARED_LIBS=OFF"
           "-DBUILD_SHARED_LIBS=OFF")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_APPEND_DEFAULT_BUILD_OPTIONS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_APPEND_DEFAULT_BUILD_OPTIONS})
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION VERSION_GREATER_EQUAL "3.21.0")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_MODULE_COMPATIBLE=ON")
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_STANDARD_VERSION VERSION_GREATER_EQUAL "3.22.0" AND absl_FOUND)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_ABSL_PROVIDER=package")
    endif()

    if(NOT COMPILER_OPTIONS_TEST_RTTI)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS "-Dprotobuf_DISABLE_RTTI=ON")
    endif()

    project_third_party_append_find_root_args(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_BUILD_OPTIONS)
  endif()

  if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_DIR)
    project_third_party_get_host_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_BUILD_DIR "protobuf"
                                           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_VERSION})
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_REPOSITORY_DIR
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_SRC_DIRECTORY_NAME}")

  if(PROTOBUF_HOST_ROOT)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR ${PROTOBUF_HOST_ROOT})
  else()
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROTOBUF_HOST_ROOT_DIR "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}")
  endif()
endif()
