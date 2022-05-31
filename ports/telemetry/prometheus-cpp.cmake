# Prometheus Data Model implement for C++
# https://github.com/jupp0r/prometheus-cpp

include_guard(GLOBAL)

# =========== third party prometheus-cpp ==================
macro(PROJECT_THIRD_PARTY_PROMETHEUS_CPP_IMPORT)
  if(TARGET prometheus-cpp::core)
    set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_LINK_NAME prometheus-cpp::core)
    if(TARGET prometheus-cpp::pull)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_LINK_NAME prometheus-cpp::pull)
    endif()
    if(TARGET prometheus-cpp::push)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_LINK_NAME prometheus-cpp::push)
    endif()
    message(
      STATUS
        "Dependency(${PROJECT_NAME}): prometheus-cpp found target ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_LINK_NAME}"
    )
    project_build_tools_patch_default_imported_config(prometheus-cpp::core prometheus-cpp::pull prometheus-cpp::push)
  endif()
endmacro()

if(NOT TARGET prometheus-cpp::core)
  find_package(prometheus-cpp QUIET CONFIG)
  project_third_party_prometheus_cpp_import()
  if(NOT TARGET prometheus-cpp::core)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS
          "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DENABLE_TESTING=OFF" "-DUSE_THIRDPARTY_LIBRARIES=OFF"
          "-DRUN_IWYU=OFF" "-DENABLE_WARNINGS_AS_ERRORS=OFF")
      if(TARGET ZLIB::ZLIB)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS "-DENABLE_COMPRESSION=ON")
      endif()
      if(TARGET civetweb::civetweb-cpp OR TARGET civetweb::civetweb)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS "-DENABLE_PULL=ON")
      endif()
      if(CURL_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS "-DENABLE_PUSH=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_APPEND_DEFAULT_BUILD_OPTIONS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS
             ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_APPEND_DEFAULT_BUILD_OPTIONS})
      endif()
    endif()
    project_third_party_port_declare(prometheus_cpp VERSION "v1.0.1" GIT_URL
                                     "https://github.com/jupp0r/prometheus-cpp.git")

    project_third_party_append_build_shared_lib_var(
      "prometheus_cpp" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS BUILD_SHARED_LIBS)

    # Other flags for find_configure_package
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS DISABLE_PARALLEL_BUILD)
    endif()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_SUB_MODULES)
    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_RESET_SUBMODULE_URLS)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_SUB_MODULES GIT_RESET_SUBMODULE_URLS
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_RESET_SUBMODULE_URLS})
    endif()

    find_configure_package(
      PACKAGE
      prometheus-cpp
      FIND_PACKAGE_FLAGS
      CONFIG
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_SYSTEM_LINKS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "prometheus-cpp-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_VERSION}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_GIT_URL}"
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PROMETHEUS_CPP_SUB_MODULES})

    project_third_party_prometheus_cpp_import()
  endif()
else()
  project_third_party_prometheus_cpp_import()
endif()

if(NOT TARGET prometheus-cpp::core)
  message(FATAL_ERROR "-- Dependency(${PROJECT_NAME}): prometheus-cpp not found")
endif()
