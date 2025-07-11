include_guard(DIRECTORY)

# =========== third party libwebsockets ==================
function(PROJECT_THIRD_PARTY_LIBWEBSOCKETS_PATCH_IMPORTED_TARGET TARGET_NAME)
  unset(PATCH_REMOVE_RULES)
  unset(PATCH_ADD_TARGETS)
  if(TARGET OpenSSL::SSL
     OR TARGET OpenSSL::Crypto
     OR TARGET LibreSSL::TLS
     OR TARGET MbedTLS::mbedtls
     OR TARGET mbedtls_static
     OR TARGET mbedtls)
    list(APPEND PATCH_REMOVE_RULES "(lib)?crypto" "(lib)?ssl")
    list(APPEND PATCH_ADD_TARGETS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME})
  endif()

  if(TARGET uv_a
     OR TARGET uv
     OR TARGET libuv)
    list(APPEND PATCH_REMOVE_RULES "(lib)?uv(_a)?")
    list(APPEND PATCH_ADD_TARGETS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME})
  endif()
  if(PATCH_REMOVE_RULES OR PATCH_ADD_TARGETS)
    project_build_tools_patch_imported_link_interface_libraries(${TARGET_NAME} REMOVE_LIBRARIES ${PATCH_REMOVE_RULES}
                                                                ADD_LIBRARIES ${PATCH_ADD_TARGETS})
  endif()
endfunction()

macro(PROJECT_THIRD_PARTY_LIBWEBSOCKETS_IMPORT)
  if(TARGET websockets)
    project_third_party_libwebsockets_patch_imported_target(websockets)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LINK_NAME)
      message(STATUS "Dependency(${PROJECT_NAME}): libwebsockets found target websockets")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LINK_NAME websockets)
    endif()
  endif()
  if(TARGET websockets_shared)
    project_third_party_libwebsockets_patch_imported_target(websockets_shared)
    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LINK_NAME)
      message(STATUS "Dependency(${PROJECT_NAME}): libwebsockets found target websockets_shared")
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LINK_NAME websockets_shared)
    endif()
  endif()
endmacro()

if(NOT Libwebsockets_FOUND
   AND NOT TARGET websockets
   AND NOT TARGET websockets_shared)
  find_package(libwebsockets QUIET CONFIG)
  project_third_party_libwebsockets_import()

  if(NOT Libwebsockets_FOUND
     AND NOT TARGET websockets
     AND NOT TARGET websockets_shared)
    find_package(Libwebsockets QUIET CONFIG)
    project_third_party_libwebsockets_import()
    if(NOT Libwebsockets_FOUND)
      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION "v4.3.5")
      endif()

      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_URL)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_URL "https://github.com/warmcat/libwebsockets.git")
      endif()

      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR)
        project_third_party_get_build_dir(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR "libwebsockets"
                                          ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION})
      endif()

      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_REPOSITORY_DIR
          "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/libwebsockets-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION}"
      )

      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_OPTIONS
          URL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_URL}" REPO_DIRECTORY
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_REPOSITORY_DIR}" TAG
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION}")

      if(EXISTS
         "${CMAKE_CURRENT_LIST_DIR}/libwebsockets-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION}.patch")
        list(
          APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_OPTIONS PATCH_FILES
          "${CMAKE_CURRENT_LIST_DIR}/libwebsockets-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VERSION}.patch"
        )
      endif()
      project_git_clone_repository(${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_GIT_OPTIONS})

      if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR})
        file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR})
      endif()

      if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS)
        project_build_tools_get_cmake_build_type_for_lib(
          ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE)
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
            ${CMAKE_COMMAND}
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_REPOSITORY_DIR}"
            "-Wno-dev"
            "-DCMAKE_INSTALL_PREFIX=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
            "-DCMAKE_BUILD_TYPE=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE}"
            "-DCMAKE_DEBUG_POSTFIX=-dbg"
            "-DCMAKE_RELWITHDEBINFO_POSTFIX=-reldbg"
            "-DCMAKE_RELEASE_POSTFIX=-rel"
            "-DLWS_STATIC_PIC=ON"
            "-DLWS_LINK_TESTAPPS_DYNAMIC=OFF"
            "-DLWS_SUPPRESS_DEPRECATED_API_WARNINGS=ON"
            "-DLWS_WITHOUT_DAEMONIZE=ON"
            "-DLWS_WITHOUT_TESTAPPS=ON"
            "-DLWS_WITHOUT_TEST_CLIENT=ON"
            "-DLWS_WITHOUT_TEST_PING=ON"
            "-DLWS_WITHOUT_TEST_SERVER=ON"
            "-DLWS_WITHOUT_TEST_SERVER_EXTPOLL=ON"
            "-DLWS_WITH_PLUGINS=ON"
            "-DLWS_WITHOUT_EXTENSIONS=OFF")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_APPEND_DEFAULT_BUILD_OPTIONS)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
               ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_APPEND_DEFAULT_BUILD_OPTIONS})
        endif()
      else()
        set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
            ${CMAKE_COMMAND} "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_REPOSITORY_DIR}" "-Wno-dev"
            "-DCMAKE_INSTALL_PREFIX=${PROJECT_THIRD_PARTY_INSTALL_DIR}"
            ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS})
      endif()
      if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
             "-DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON")
      endif()

      # See libwebsockets/contrib/cross-w64.cmake
      if(MINGW
         OR IOS
         OR ANDROID)
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS " -Wno-error")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS " -Wno-error")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS_RELEASE " -O2")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS_RELEASE " -O2")

        if(ANDROID AND CMAKE_ANDROID_ARCH_ABI STREQUAL arm64-v8a)
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
              "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS_VALUE} -DARM64=1 -D__LP64__=1 -Os -g3 -fpie -mstrict-align -fPIC -ffunction-sections -fdata-sections -Wno-pointer-sign"
          )
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
              "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS_VALUE} -DARM64=1 -D__LP64__=1 -Os -g3 -fpie -mstrict-align -fPIC -ffunction-sections -fdata-sections -Wno-pointer-sign"
          )
        endif()
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN)
        if(NOT DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VISIBILITY_HIDDEN
           AND NOT DEFINED CACHE{ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VISIBILITY_HIDDEN})
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VISIBILITY_HIDDEN
              ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_DEFAULT_VISIBILITY_HIDDEN})
        endif()
      endif()

      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VISIBILITY_HIDDEN)
        if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_C_FLAGS
              "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS}")
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_CXX_FLAGS
              "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS}")
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
              "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS} -fvisibility=hidden")
          set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
              "${PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS} -fvisibility=hidden")
        endif()
      endif()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL
         OR OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0"
         OR CMAKE_SYSTEM_NAME STREQUAL "Windows"
         OR ANDROID)
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_C_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES}")
        set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_CXX_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES}")
        project_build_tools_append_space_flags_to_var_unique(
          PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_C_STANDARD_LIBRARIES
          ${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS})
        project_build_tools_append_space_flags_to_var_unique(
          PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_CXX_STANDARD_LIBRARIES
          ${ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LINKS})
      endif()
      project_build_tools_append_cmake_options_for_lib(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
                                                       DISABLE_ASM_FLAGS)
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_VISIBILITY_HIDDEN)
        if(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_C_FLAGS)
            set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_C_FLAGS}")
          else()
            unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS)
          endif()
          if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_CXX_FLAGS)
            set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS
                "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_CXX_FLAGS}")
          else()
            unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS)
          endif()
          unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_C_FLAGS)
          unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BACKUP_CMAKE_CXX_FLAGS)
        endif()
      endif()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL
         OR OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0"
         OR CMAKE_SYSTEM_NAME STREQUAL "Windows"
         OR ANDROID)
        unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_C_STANDARD_LIBRARIES)
        unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_CXX_STANDARD_LIBRARIES)
      endif()

      if(MINGW
         OR IOS
         OR ANDROID)
        unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS)
        unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS)
        unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_FLAGS_RELEASE)
        unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_FLAGS_RELEASE)
      endif()

      project_third_party_append_build_shared_lib_var(
        "libwebsockets" "" ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS LWS_WITH_SHARED
        BUILD_SHARED_LIBS)

      project_third_party_append_find_root_args(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS)

      list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DDISABLE_WERROR=ON")

      # Compile failed with libuv on mingw
      if(MINGW)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_LIBUV=OFF"
             "-DLWS_WITH_LWSWS=OFF" "-DLWS_WITH_PLUGINS=OFF")
      elseif(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LINK_NAME)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_LIBUV=ON")
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
               "-DLWS_LIBUV_INCLUDE_DIRS=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_INCLUDE_DIRS}")
        endif()
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES)
          # Prefer static library on windows
          #[[
          # if((CMAKE_SYSTEM_NAME STREQUAL "Windows"
          #     OR MINGW
          #     OR CYGWIN)
          #    AND TARGET uv_a)
          #   project_build_tools_get_imported_location(LWS_LIBUV_LIBRARIES uv_a)
          #   list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
          #        "-DLWS_LIBUV_LIBRARIES=${LWS_LIBUV_LIBRARIES}")
          # else()
          ]]
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
               "-DLWS_LIBUV_LIBRARIES=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBUV_LIBRARIES}")
          # endif()
        endif()
      endif()

      if(WIN32
         OR CYGWIN
         OR MINGW)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_PLUGINS=OFF")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_UNIX_SOCK=ON")
      endif()

      if(ZLIB_INCLUDE_DIRS AND ZLIB_LIBRARIES)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_ZLIB=ON"
             "-DLWS_WITH_BUNDLED_ZLIB=OFF" "-DLWS_ZLIB_INCLUDE_DIRS=${ZLIB_INCLUDE_DIRS}")
        list_append_unescape(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
                             "-DLWS_ZLIB_LIBRARIES=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_ZLIB_LINK_SELECT_NAME}")
      endif()
      if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_MBEDTLS)
        # libwebsockets do not support mbedtls 3
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_SSL=OFF")
        # list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_MBEDTLS=ON")
      elseif(OPENSSL_FOUND AND NOT LIBRESSL_FOUND)
        if(OPENSSL_ROOT_DIR
           AND (TARGET OpenSSL::SSL
                OR TARGET OpenSSL::Crypto
                OR OPENSSL_LIBRARIES))
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
               "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}" "-DOpenSSL_ROOT=${OPENSSL_ROOT_DIR}")
        endif()
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_INCLUDE_DIRS)
        unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_LIBRARIES)
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_BORINGSSL=ON")
        endif()
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL OR OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0")
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
               "-DOPENSSL_VERSION=${OPENSSL_VERSION}")
          # set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_INCLUDE_DIRS "${OPENSSL_INCLUDE_DIR}")
          # set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARY}
          # ${OPENSSL_CRYPTO_LIBRARY})
        endif()
        if(MSVC OR ANDROID)
          # Some version of libwebsockets have compiling problems.
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_SSL=ON"
               "-DLWS_WITH_CLIENT=ON")
          # set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_INCLUDE_DIRS "${OPENSSL_INCLUDE_DIR}")
          # set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_LIBRARIES ${OPENSSL_LIBRARIES})
        else()
          if(DEFINED OPENSSL_USE_STATIC_LIBS)
            list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
                 "-DOPENSSL_USE_STATIC_LIBS=${OPENSSL_USE_STATIC_LIBS}")
          endif()
        endif()

        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_INCLUDE_DIRS)
          list_append_unescape(
            ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
            "-DLWS_OPENSSL_INCLUDE_DIRS=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_INCLUDE_DIRS}"
          )
        endif()
        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_LIBRARIES)
          list_append_unescape(
            ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
            "-DLWS_OPENSSL_LIBRARIES=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_LWS_OPENSSL_LIBRARIES}")
        endif()
      elseif(LIBRESSL_FOUND)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DLWS_WITH_SSL=OFF")
      endif()
      if(NOT MSVC)
        file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.sh"
             "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh"
             "#!/bin/bash${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        project_third_party_generate_load_env_bash(
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-load-envs.sh")
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.sh"
          "export PATH=\"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}:\$PATH\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
        )
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh"
          "source \"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-load-envs.sh\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
          "set -x${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.sh"
          "source \"${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-load-envs.sh\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}"
          "set -x${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")

        project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.sh")
        project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh")

        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS
             "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
        if(CMAKE_AR)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS "-DCMAKE_AR=${CMAKE_AR}")
        endif()

        find_package(Threads)
        if(CMAKE_DL_LIBS)
          if(CMAKE_USE_PTHREADS_INIT)
            file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-load-envs.sh"
                 "export LDFLAGS=\"\$LDFLAGS -l${CMAKE_DL_LIBS} -pthread\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          else()
            file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-load-envs.sh"
                 "export LDFLAGS=\"\$LDFLAGS -l${CMAKE_DL_LIBS}\"${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          endif()
        endif()

        project_expand_list_for_command_line_to_file(
          BASH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.sh"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS}")
        project_expand_list_for_command_line_to_file(
          BASH "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh"
          "${CMAKE_COMMAND}" "--build" "." "-j${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PARALLEL_JOBS}")
        file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh"
             "if [[ $? -ne 0 ]]; then exit 1; fi${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
        project_expand_list_for_command_line_to_file(
          BASH
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh"
          "${CMAKE_COMMAND}"
          "--install"
          "."
          "--prefix"
          "${PROJECT_THIRD_PARTY_INSTALL_DIR}")

        # build & install
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.sh"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_BASH}"
                  "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.sh"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

      else()
        file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.bat" "")
        file(WRITE "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat" "")
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.bat"
          "set PATH=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}"
        )
        file(
          APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat"
          "set PATH=${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR};%PATH%${PROJECT_THIRD_PARTY_BUILDTOOLS_EOL}"
        )
        project_make_executable("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.bat")
        project_make_executable(
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat")

        project_expand_list_for_command_line_to_file(
          BAT "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.bat"
          "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_OPTIONS}")

        if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES
              ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE})
        else()
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES)
          if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE STREQUAL "Debug")
            list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES "Debug")
          endif()
          if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE STREQUAL "Release")
            list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES "Release")
          endif()
          if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE STREQUAL "RelWithDebInfo")
            list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES "RelWithDebInfo")
          endif()
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES
               ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_DEFAULT_BUILD_TYPE})
        endif()

        foreach(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPE
                ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPES})
          project_expand_list_for_command_line_to_file(
            BAT
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat"
            "${CMAKE_COMMAND}"
            "--build"
            "."
            "--config"
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPE}"
            "-j${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PARALLEL_JOBS}")
          file(APPEND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat"
               "IF %ERRORLEVEL% NEQ 0 ( exit %ERRORLEVEL% )${PROJECT_THIRD_PARTY_BUILDTOOLS_BASH_EOL}")
          project_expand_list_for_command_line_to_file(
            BAT
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat"
            "${CMAKE_COMMAND}"
            "--install"
            "."
            "--config"
            "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_TYPE}"
            "--prefix"
            "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
        endforeach()

        # build & install
        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-config.bat"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})

        execute_process(
          COMMAND "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}/run-build-release.bat"
          WORKING_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()

      find_package(Libwebsockets CONFIG)
      project_third_party_libwebsockets_import()
    endif()
  endif()
else()
  project_third_party_libwebsockets_import()
endif()

if(NOT Libwebsockets_FOUND
   AND NOT TARGET websockets
   AND NOT TARGET websockets_shared)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CI_MODE)
    project_build_tools_print_configure_log("${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBWEBSOCKETS_BUILD_DIR}")
  endif()
  message(FATAL_ERROR "-- Dependency(${PROJECT_NAME}): libwebsockets not found")
endif()
