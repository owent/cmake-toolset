include_guard(DIRECTORY)
# =========== third party libcurl ==================

macro(PROJECT_THIRD_PARTY_LIBCURL_IMPORT)
  if(CURL_FOUND)
    if(TARGET CURL::libcurl
       OR TARGET CURL::libcurl_static
       OR TARGET CURL::libcurl_shared)
      set(PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES CURL::libcurl CURL::libcurl_static CURL::libcurl_shared)
      if(LIBRESSL_FOUND
         AND TARGET LibreSSL::Crypto
         AND TARGET LibreSSL::SSL)
        foreach(PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES})
          if(TARGET PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME)
            project_build_tools_patch_imported_link_interface_libraries(
              ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME} REMOVE_LIBRARIES "OpenSSL::SSL;OpenSSL::Crypto" ADD_LIBRARIES
              "LibreSSL::SSL;LibreSSL::Crypto")
          endif()
        endforeach()
      endif()
      if(TARGET CURL::libcurl)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME CURL::libcurl)
      elseif(TARGET CURL::libcurl_static AND TARGET CURL::libcurl_shared)
        project_third_party_check_build_shared_lib("libcurl" ""
                                                   ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_USE_SHARED)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_USE_SHARED)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME CURL::libcurl_shared)
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME CURL::libcurl_static)
        endif()
      elseif(TARGET CURL::libcurl_static)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME CURL::libcurl_static)
      elseif(TARGET CURL::libcurl_shared)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME CURL::libcurl_shared)
      endif()
      project_build_tools_patch_default_imported_config(${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES})
      foreach(PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES})
        if(NOT TARGET PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME)
          continue()
        endif()
        get_target_property(PROJECT_THIRD_PARTY_LIBCURL_ALIAS_TARGET ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME}
                            ALIASED_TARGET)
        if(PROJECT_THIRD_PARTY_LIBCURL_ALIAS_TARGET)
          unset(PROJECT_THIRD_PARTY_LIBCURL_ALIAS_TARGET)
          continue()
        endif()
        get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_ORIGIN_INTERFACE_LINK_LIBRARIES
                            ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME} INTERFACE_LINK_LIBRARIES)
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_ORIGIN_INTERFACE_LINK_LIBRARIES)
          foreach(LIBCURL_DEP_LINK_NAME
                  ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_ORIGIN_INTERFACE_LINK_LIBRARIES})
            if(IS_ABSOLUTE "${LIBCURL_DEP_LINK_NAME}")
              if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME AND LIBCURL_DEP_LINK_NAME MATCHES "cares")
                list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES
                     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CARES_LINK_NAME}")
              elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME AND LIBCURL_DEP_LINK_NAME MATCHES "zstd")
                list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES
                     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME}")
              elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_NAME AND LIBCURL_DEP_LINK_NAME MATCHES
                                                                              "libz\\.|zlib")
                list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES
                     "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_NAME}")
              elseif(LIBCURL_DEP_LINK_NAME MATCHES "nghttp2|nghttp3|ngtcp2")
                message(
                  "Libcurl: ignore ${LIBCURL_DEP_LINK_NAME} we will use Libnghttp2::libnghttp2 or Libngtcp2::libngtcp2_crypto_openssl/libngtcp2_crypto_quictls"
                )
              else()
                list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES
                     "${LIBCURL_DEP_LINK_NAME}")
              endif()
            else()
              list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES
                   "${LIBCURL_DEP_LINK_NAME}")
            endif()
          endforeach()

          set_target_properties(
            ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME}
            PROPERTIES INTERFACE_LINK_LIBRARIES
                       "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES}")
          unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCHED_INTERFACE_LINK_LIBRARIES)
        endif()
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_ORIGIN_INTERFACE_LINK_LIBRARIES)
        unset(PROJECT_THIRD_PARTY_LIBCURL_ALIAS_TARGET)
      endforeach()
    else()
      add_library(CURL::libcurl UNKNOWN IMPORTED)
      if(CURL_INCLUDE_DIRS)
        set_target_properties(CURL::libcurl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${CURL_INCLUDE_DIRS})
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES)
        set_target_properties(
          CURL::libcurl
          PROPERTIES IMPORTED_LOCATION ${CURL_LIBRARIES}
                     INTERFACE_LINK_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES})
      endif()
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LINK_NAME CURL::libcurl)
    endif()

    if(TARGET Libnghttp2::libnghttp2)
      foreach(PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES})
        if(TARGET PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME)
          project_build_tools_patch_imported_link_interface_libraries(${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME}
                                                                      ADD_LIBRARIES Libnghttp2::libnghttp2)
        endif()
      endforeach()

    endif()
    if(Libngtcp2::libngtcp2_crypto_openssl)
      foreach(PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES})
        if(TARGET PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME)
          project_build_tools_patch_imported_link_interface_libraries(${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME}
                                                                      ADD_LIBRARIES Libngtcp2::libngtcp2_crypto_openssl)
        endif()
      endforeach()

    endif()
    if(Libngtcp2::libngtcp2_crypto_quictls)
      foreach(PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME ${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAMES})
        if(TARGET PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME)
          project_build_tools_patch_imported_link_interface_libraries(${PROJECT_THIRD_PARTY_LIBCURL_TARGET_NAME}
                                                                      ADD_LIBRARIES Libngtcp2::libngtcp2_crypto_quictls)
        endif()
      endforeach()
    endif()

    if(CMAKE_CROSSCOMPILING)
      if(CURL_EXECUTABLE)
        unset(CURL_EXECUTABLE)
        unset(CURL_EXECUTABLE CACHE)
      endif()
      set(CURL_CROSSING_FIND_PATHS "${PROJECT_THIRD_PARTY_HOST_INSTALL_DIR}/bin")
      if(CMAKE_STAGING_PREFIX)
        list(APPEND CURL_CROSSING_FIND_PATHS "${CMAKE_STAGING_PREFIX}/bin")
      endif()
      if(CMAKE_HOST_PROGRAM_PATH)
        list(APPEND CURL_CROSSING_FIND_PATHS "${CMAKE_HOST_PROGRAM_PATH}")
      endif()
      if(CMAKE_HOST_SYSTEM_PROGRAM_PATH)
        list(APPEND CURL_CROSSING_FIND_PATHS "${CMAKE_HOST_SYSTEM_PROGRAM_PATH}")
      endif()
      find_program(
        CURL_EXECUTABLE
        NAMES curl curl.exe
        PATHS ${CURL_CROSSING_FIND_PATHS} NO_PACKAGE_ROOT_PATH
        NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_FIND_ROOT_PATH)
      if(CURL_EXECUTABLE)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BIN_CURL "${CURL_EXECUTABLE}")
        if(TARGET CURL::curl)
          set_target_properties(CURL::curl PROPERTIES IMPORTED_LOCATION "${CURL_EXECUTABLE}")
        else()
          add_library(CURL::curl UNKNOWN IMPORTED)
          set_target_properties(CURL::curl PROPERTIES IMPORTED_LOCATION "${CURL_EXECUTABLE}")
        endif()
      endif()
    elseif(TARGET CURL::curl)
      get_target_property(CURL_EXECUTABLE CURL::curl IMPORTED_LOCATION)
      if(CURL_EXECUTABLE AND EXISTS ${CURL_EXECUTABLE})
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BIN_CURL "${CURL_EXECUTABLE}")
      else()
        get_target_property(CURL_EXECUTABLE CURL::curl IMPORTED_LOCATION_NOCONFIG)
        if(CURL_EXECUTABLE AND EXISTS ${CURL_EXECUTABLE})
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BIN_CURL "${CURL_EXECUTABLE}")
        endif()
      endif()
    else()
      find_program(
        CURL_EXECUTABLE
        NAMES curl curl.exe
        PATHS "${CURL_INCLUDE_DIRS}/../bin" "${CURL_INCLUDE_DIRS}/../" ${CURL_INCLUDE_DIRS}
        NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)
      if(CURL_EXECUTABLE AND EXISTS ${CURL_EXECUTABLE})
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BIN_CURL "${CURL_EXECUTABLE}")
        add_executable(CURL::curl IMPORTED)
        set_target_properties(CURL::curl PROPERTIES IMPORTED_LOCATION_RELEASE "${CURL_EXECUTABLE}")
      endif()
    endif()
  endif()
endmacro()

if(NOT TARGET CURL::libcurl
   OR TARGET CURL::libcurl_static
   OR TARGET CURL::libcurl_shared)
  find_package(CURL QUIET)
  project_third_party_libcurl_import()

  if(NOT CURL_FOUND)
    set(Libcurl_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})
    set(LIBCURL_ROOT ${PROJECT_THIRD_PARTY_INSTALL_DIR})

    set(CURL_ROOT ${LIBCURL_ROOT})

    project_third_party_port_declare(
      libcurl
      VERSION
      "8.5.0"
      GIT_URL
      "https://github.com/curl/curl.git"
      BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
      "-DBUILD_TESTING=OFF")

    string(REPLACE "." "_" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_GIT_TAG
                   "curl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION}")

    if(ANDROID)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DBUILD_SHARED_LIBS=OFF")
    else()
      project_third_party_append_build_shared_lib_var(
        "libcurl" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS BUILD_SHARED_LIBS)
    endif()

    if(CMAKE_CROSSCOMPILING)
      if(ANDROID
         OR APPLE
         OR IOS
         OR UNIX)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DHAVE_POLL_FINE_EXITCODE=0"
             "-DHAVE_POLL_FINE_EXITCODE__TRYRUN_OUTPUT=0")
      endif()
    endif()

    if(OPENSSL_FOUND)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION VERSION_GREATER_EQUAL "7.81.0")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DCURL_USE_OPENSSL=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DCMAKE_USE_OPENSSL=ON")
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL OR OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS
             "-DOPENSSL_ROOT_DIR=${PROJECT_THIRD_PARTY_INSTALL_DIR}" "-DOPENSSL_VERSION=${OPENSSL_VERSION}")
      elseif(
        OPENSSL_ROOT_DIR
        AND (TARGET OpenSSL::SSL
             OR TARGET OpenSSL::Crypto
             OR OPENSSL_LIBRARIES))
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS
             "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}")
      endif()
      if(DEFINED OPENSSL_USE_STATIC_LIBS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS
             "-DOPENSSL_USE_STATIC_LIBS=${OPENSSL_USE_STATIC_LIBS}")
      endif()
    elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_MBEDTLS_FOUND)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION VERSION_GREATER_EQUAL "7.81.0")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DCURL_USE_MBEDTLS=ON")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DCMAKE_USE_MBEDTLS=ON")
      endif()
      if(MbedTLS_ROOT)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DMbedTLS_ROOT=${MbedTLS_ROOT}")
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_DISABLE_ARES)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DENABLE_THREADED_RESOLVER=ON")
    else()
      if(TARGET c-ares::cares
         OR TARGET c-ares::cares_static
         OR TARGET c-ares::cares_shared
         OR CARES_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DENABLE_ARES=ON")
      endif()
    endif()

    if(zstd_DIR OR Zstd_DIR)
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DCURL_ZSTD=ON")
      if(zstd_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DZstd_DIR=${zstd_DIR}")
      elseif(Zstd_DIR)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DZstd_DIR=${Zstd_DIR}")
      endif()
      project_build_tools_get_imported_location(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_WITH_ZSTD_LIBRARY
                                                ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME})
      get_target_property(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_WITH_ZSTD_INCLUDE_DIRS
                          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZSTD_LINK_NAME} INTERFACE_INCLUDE_DIRECTORIES)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_WITH_ZSTD_LIBRARY
         AND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_WITH_ZSTD_INCLUDE_DIRS)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS
             "-DZstd_INCLUDE_DIR=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_WITH_ZSTD_INCLUDE_DIRS}"
             "-DZstd_LIBRARY=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_WITH_ZSTD_LIBRARY}")
      endif()
    endif()

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION VERSION_GREATER_EQUAL "7.71.0")
      if(TARGET Libnghttp3::libnghttp3 AND (TARGET Libngtcp2::libngtcp2_crypto_openssl
                                            OR TARGET Libngtcp2::libngtcp2_crypto_quictls))
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DUSE_NGTCP2=ON")
      endif()
      # The link order of libcurl has some problems and will link error with nghttp2 when building static library.
      if(TARGET Libnghttp2::libnghttp2)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DUSE_NGHTTP2=ON")
      endif()

      #[[
      # TODO HTTP/3 with quiche
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION VERSION_GREATER_EQUAL "7.83.0")
        # TODO HTTP/3 with msquic
      endif()
      #]]
    endif()

    # At last, patch file
    project_third_party_try_patch_file(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "libcurl"
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION}")

    if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCH_FILE
       AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCH_FILE}")
      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS GIT_PATCH_FILES
           "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_PATCH_FILE}")
    endif()

    find_configure_package(
      PACKAGE
      CURL
      FIND_PACKAGE_FLAGS
      CONFIG
      BUILD_WITH_CMAKE
      CMAKE_INHERIT_BUILD_ENV
      CMAKE_INHERIT_BUILD_ENV_DISABLE_CXX_FLAGS
      CMAKE_INHERIT_FIND_ROOT_PATH
      CMAKE_INHERIT_SYSTEM_LINKS
      CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_OPTIONS}
      WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
      BUILD_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_DIR}"
      PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
      SRC_DIRECTORY_NAME
      "libcurl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_VERSION}"
      GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_GIT_TAG}"
      GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_GIT_URL}")

    if(NOT CURL_FOUND)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
        project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_BUILD_DIR}")
      endif()
      echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): libcurl is required")
      message(FATAL_ERROR "libcurl not found")
    endif()

    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES)
    if(TARGET CURL::libcurl
       OR TARGET CURL::libcurl_static
       OR TARGET CURL::libcurl_shared)
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_FOUND_NAMES)
      foreach(TEST_TARGET TARGET CURL::libcurl CURL::libcurl_static CURL::libcurl_shared)
        if(TARGET ${TEST_TARGET})
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_FOUND_NAMES ${TEST_TARGET})
        endif()
      endforeach()

      message(
        STATUS
          "Dependency(${PROJECT_NAME}): libcurl found target: ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_FOUND_NAMES}"
      )
      unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_FOUND_NAMES)
      unset(TEST_TARGET)
    else()
      message(STATUS "Dependency(${PROJECT_NAME}): libcurl found.(${CURL_INCLUDE_DIRS}|${CURL_LIBRARIES})")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TEST_SRC
          "#include <curl/curl.h>
            #include <stdio.h>

            int main () {
                curl_global_init(CURL_GLOBAL_ALL)\;
                printf(\"libcurl version: %s\", LIBCURL_VERSION)\;
                return 0\;
            }")

      file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/try_run_libcurl_test.c"
           ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TEST_SRC})

      if(MSVC)
        try_compile(
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_RESULT ${CMAKE_CURRENT_BINARY_DIR}
          "${CMAKE_CURRENT_BINARY_DIR}/try_run_libcurl_test.c"
          CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CURL_INCLUDE_DIRS}
          LINK_LIBRARIES ${CURL_LIBRARIES}
          OUTPUT_VARIABLE ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_DYN_MSG)
      else()
        try_run(
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_RESULT
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_RESULT ${CMAKE_CURRENT_BINARY_DIR}
          "${CMAKE_CURRENT_BINARY_DIR}/try_run_libcurl_test.c"
          CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CURL_INCLUDE_DIRS} LINK_LIBRARIES ${CURL_LIBRARIES}
          COMPILE_OUTPUT_VARIABLE ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_DYN_MSG
          RUN_OUTPUT_VARIABLE ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT)
      endif()

      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_RESULT)
        echowithcolor(COLOR YELLOW "-- Libcurl: Dynamic symbol test in ${CURL_LIBRARIES} failed, try static symbols")
        if(MSVC)
          if(ZLIB_FOUND)
            list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES ${ZLIB_LIBRARIES})
          endif()

          try_compile(
            ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_RESULT ${CMAKE_CURRENT_BINARY_DIR}
            "${CMAKE_CURRENT_BINARY_DIR}/try_run_libcurl_test.c"
            CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${CURL_INCLUDE_DIRS}
            COMPILE_DEFINITIONS /D CURL_STATICLIB
            LINK_LIBRARIES ${CURL_LIBRARIES} ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES}
            OUTPUT_VARIABLE ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_STA_MSG)
        else()
          get_filename_component(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LIBDIR ${CURL_LIBRARIES} DIRECTORY)
          find_package(PkgConfig)
          if(PKG_CONFIG_FOUND AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LIBDIR}/pkgconfig/libcurl.pc")
            pkg_check_modules(LIBCURL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LIBDIR}/pkgconfig/libcurl.pc")
            list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES ${LIBCURL_STATIC_LIBRARIES})
            list(REMOVE_ITEM ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES curl)
            message(
              STATUS
                "Libcurl use static link with ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES} in ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_LIBDIR}"
            )
          else()
            if(OPENSSL_FOUND)
              list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES ${OPENSSL_LIBRARIES})
            else()
              list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES ssl crypto)
            endif()
            if(ZLIB_FOUND)
              list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES ${ZLIB_LIBRARIES})
            else()
              list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES z)
            endif()
          endif()

          try_run(
            ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_RESULT
            ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_RESULT ${CMAKE_CURRENT_BINARY_DIR}
            "${CMAKE_CURRENT_BINARY_DIR}/try_run_libcurl_test.c"
            CMAKE_FLAGS -DCMAKE_INCLUDE_DIRECTORIES_BEFORE=${CURL_INCLUDE_DIRS}
            COMPILE_DEFINITIONS -DCURL_STATICLIB LINK_LIBRARIES ${CURL_LIBRARIES}
                                ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES} -lpthread
            COMPILE_OUTPUT_VARIABLE ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_STA_MSG
            RUN_OUTPUT_VARIABLE ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES pthread)
        endif()
        if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_RESULT)
          message(STATUS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_DYN_MSG})
          message(STATUS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_COMPILE_STA_MSG})
          message(FATAL_ERROR "Libcurl: try compile with ${CURL_LIBRARIES} failed")
        else()
          message(STATUS "Libcurl: use static symbols")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT)
            message(STATUS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT})
          endif()

          add_library(CURL::libcurl UNKNOWN IMPORTED)
          set_target_properties(CURL::libcurl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${CURL_INCLUDE_DIRS}
                                                         INTERFACE_COMPILE_DEFINITIONS "CURL_STATICLIB=1")
          set_target_properties(
            CURL::libcurl
            PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX"
                       IMPORTED_LOCATION ${CURL_LIBRARIES}
                       INTERFACE_LINK_LIBRARIES ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_STATIC_LINK_NAMES})
        endif()
      else()
        message(STATUS "Libcurl: use dynamic symbols")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT)
          message(STATUS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT})
        endif()

        add_library(CURL::libcurl UNKNOWN IMPORTED)
        set_target_properties(CURL::libcurl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${CURL_INCLUDE_DIRS})
        set_target_properties(CURL::libcurl PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C;CXX" IMPORTED_LOCATION
                                                                                                 ${CURL_LIBRARIES})
      endif()
    endif()
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBCURL_TRY_RUN_OUT)

    project_third_party_libcurl_import()
  endif()
else()
  project_third_party_libcurl_import()
endif()
