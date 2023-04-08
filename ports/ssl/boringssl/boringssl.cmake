# BoringSSL requires go and perl, we don't support it now.

include_guard(DIRECTORY)

macro(PROJECT_THIRD_PARTY_BORINGSSL_IMPORT)
  if(OPENSSL_FOUND OR OpenSSL_FOUND)
    if(NOT OPENSSL_VERSION AND EXISTS "${OPENSSL_INCLUDE_DIR}/openssl/base.h")
      function(from_hex HEX DEC)
        string(TOUPPER "${HEX}" HEX)
        set(_res 0)
        string(LENGTH "${HEX}" _strlen)

        while(_strlen GREATER 0)
          math(EXPR _res "${_res} * 16")
          string(SUBSTRING "${HEX}" 0 1 NIBBLE)
          string(SUBSTRING "${HEX}" 1 -1 HEX)
          if(NIBBLE STREQUAL "A")
            math(EXPR _res "${_res} + 10")
          elseif(NIBBLE STREQUAL "B")
            math(EXPR _res "${_res} + 11")
          elseif(NIBBLE STREQUAL "C")
            math(EXPR _res "${_res} + 12")
          elseif(NIBBLE STREQUAL "D")
            math(EXPR _res "${_res} + 13")
          elseif(NIBBLE STREQUAL "E")
            math(EXPR _res "${_res} + 14")
          elseif(NIBBLE STREQUAL "F")
            math(EXPR _res "${_res} + 15")
          else()
            math(EXPR _res "${_res} + ${NIBBLE}")
          endif()

          string(LENGTH "${HEX}" _strlen)
        endwhile()

        set(${DEC}
            ${_res}
            PARENT_SCOPE)
      endfunction()
      file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/base.h" openssl_version_str
           REGEX "^#[\t ]*define[\t ]+OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-fA-F])+.*")
      if(openssl_version_str)
        string(
          REGEX
          REPLACE
            "^.*OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F][0-9a-fA-F])([0-9a-fA-F]).*$"
            "\\1;\\2;\\3;\\4;\\5"
            OPENSSL_VERSION_LIST
            "${openssl_version_str}")
        list(GET OPENSSL_VERSION_LIST 0 OPENSSL_VERSION_MAJOR)
        list(GET OPENSSL_VERSION_LIST 1 OPENSSL_VERSION_MINOR)
        from_hex("${OPENSSL_VERSION_MINOR}" OPENSSL_VERSION_MINOR)
        list(GET OPENSSL_VERSION_LIST 2 OPENSSL_VERSION_FIX)
        from_hex("${OPENSSL_VERSION_FIX}" OPENSSL_VERSION_FIX)
        list(GET OPENSSL_VERSION_LIST 3 OPENSSL_VERSION_PATCH)

        if(NOT OPENSSL_VERSION_PATCH STREQUAL "00")
          from_hex("${OPENSSL_VERSION_PATCH}" _tmp)
          # 96 is the ASCII code of 'a' minus 1
          math(EXPR OPENSSL_VERSION_PATCH_ASCII "${_tmp} + 96")
          unset(_tmp)
          # Once anyone knows how OpenSSL would call the patch versions beyond 'z' this should be updated to handle
          # that, too. This has not happened yet so it is simply ignored here for now.
          string(ASCII "${OPENSSL_VERSION_PATCH_ASCII}" OPENSSL_VERSION_PATCH_STRING)
        endif()

        set(OPENSSL_VERSION
            "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX}${OPENSSL_VERSION_PATCH_STRING}")
        file(
          APPEND "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h"
          "/** For CMake: FindOpenSSL.cmake
${openssl_version_str}
**/")
      else()
        # Since OpenSSL 3.0.0, the new version format is MAJOR.MINOR.PATCH and a new OPENSSL_VERSION_STR macro contains
        # exactly that
        file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/base.h" OPENSSL_VERSION_STR
             REGEX "^#[\t ]*define[\t ]+OPENSSL_VERSION_STR[\t ]+\"([0-9])+\\.([0-9])+\\.([0-9])+\".*")
        string(REGEX REPLACE "^.*OPENSSL_VERSION_STR[\t ]+\"([0-9]+\\.[0-9]+\\.[0-9]+)\".*$" "\\1" OPENSSL_VERSION_STR
                             "${OPENSSL_VERSION_STR}")

        set(OPENSSL_VERSION "${OPENSSL_VERSION_STR}")

        file(
          APPEND "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h"
          "/** For CMake: FindOpenSSL.cmake
${OPENSSL_VERSION_STR}
**/")
        unset(OPENSSL_VERSION_STR)
      endif()
    endif()
    message(STATUS "Dependency(${PROJECT_NAME}): boringssl found.(openssl: ${OPENSSL_VERSION})")
    unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME)

    if(TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto)
      if(TARGET OpenSSL::Crypto)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::Crypto)

        if(TARGET Libunwind::libunwind)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES
                                                                      Libunwind::libunwind)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME Libunwind::libunwind)
        endif()
        if(TARGET ZLIB::ZLIB)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES ZLIB::ZLIB)
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME ZLIB::ZLIB)
        endif()
        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES Threads::Threads
                                                                      ${CMAKE_DL_LIBS})
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME Threads::Threads ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES ${CMAKE_DL_LIBS})
          list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME ${CMAKE_DL_LIBS})
        endif()
      endif()
      if(TARGET OpenSSL::SSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::SSL)

        if(TARGET Libunwind::libunwind)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES Libunwind::libunwind)
        endif()
        if(TARGET ZLIB::ZLIB)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES ZLIB::ZLIB)
        endif()
        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES Threads::Threads
                                                                      ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::SSL ADD_LIBRARIES ${CMAKE_DL_LIBS})
        endif()
      endif()
    else()
      if(NOT OPENSSL_LIBRARIES)
        set(OPENSSL_LIBRARIES
            ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY}
            CACHE INTERNAL "Fix cmake module path for boringssl" FORCE)
      endif()
      if(OPENSSL_LIBRARIES)
        add_library(OpenSSL::Crypto UNKNOWN IMPORTED)
        set_target_properties(OpenSSL::Crypto PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
        set_target_properties(OpenSSL::Crypto PROPERTIES IMPORTED_LOCATION ${OPENSSL_CRYPTO_LIBRARIES})
        add_library(OpenSSL::SSL UNKNOWN IMPORTED)
        set_target_properties(OpenSSL::SSL PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
        set_target_properties(OpenSSL::SSL PROPERTIES IMPORTED_LOCATION ${OPENSSL_SSL_LIBRARIES} OpenSSL::Crypto)

        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::Crypto OpenSSL::SSL)
      endif()
    endif()
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows" AND "bcrypt" IN_LIST ATFRAMEWORK_CMAKE_TOOLSET_SYSTEM_LIBRARIES)
      if(MSVC)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME "bcrypt.lib")
      else()
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_DEPEND_NAME "bcrypt")
      endif()
    endif()

    find_program(
      OPENSSL_EXECUTABLE
      NAMES bssl bssl.exe
      PATHS "${OPENSSL_INCLUDE_DIR}/../bin" "${OPENSSL_INCLUDE_DIR}/../" ${OPENSSL_INCLUDE_DIR}
      NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH)

    if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL)
      set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_USE_BORINGSSL
          TRUE
          CACHE BOOL "Cache ssl selector and directly use boringssl next time")
    endif()
  endif()
endmacro()

macro(PROJECT_THIRD_PARTY_CRYPTO_BORINGSSL_PREPEND_STANDARD_LIBRARIES VAR_NAME OTHER_FLAGS)
  if(${VAR_NAME})
    set(${VAR_NAME} "${OTHER_FLAGS} ${${VAR_NAME}}")
  else()
    set(${VAR_NAME} "${OTHER_FLAGS}")
  endif()
endmacro()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME)
  find_package(Perl REQUIRED)
  find_program(GO_EXECUTABLE go go.exe)
  if(NOT GO_EXECUTABLE)
    message(FATAL_ERROR "go is required to build boringssl")
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_DEFAULT_BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_SHARED_LIBS=OFF" "-DGO_EXECUTABLE=${GO_EXECUTABLE}"
      "-DPERL_EXECUTABLE=${PERL_EXECUTABLE}")
  if(CMAKE_CROSSCOMPILING)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_DEFAULT_BUILD_OPTIONS "-DOPENSSL_NO_ASM=ON")
  endif()
  project_third_party_port_declare(
    boringssl
    PORT_PREFIX
    "CRYPTO"
    VERSION
    "b9232f9e27e5668bc0414879dcdedb2a59ea75f2"
    GIT_URL
    "https://github.com/google/boringssl.git"
    BUILD_OPTIONS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_DEFAULT_BUILD_OPTIONS})

  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_FILE "${CMAKE_CURRENT_LIST_DIR}" "boringssl"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_VERSION}")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_BUILD_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_FILE}")
  endif()
  # Just like in CMakeLists.txt in boringssl
  unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT CMAKE_CROSSCOMPILING)
    find_package(PkgConfig)
    if(PkgConfig_FOUND)
      message(STATUS "Try to use ${PKG_CONFIG_EXECUTABLE} to load libunwind-generic for boringssl")
      pkg_check_modules(LIBUNWIND libunwind-generic)
      if(LIBUNWIND_FOUND)
        message(
          STATUS
            "libunwind-generic for boringssl found.
        VERSION: ${LIBUNWIND_VERSION}
        PREFIX: ${LIBUNWIND_PREFIX}
        CFLAGS: ${LIBUNWIND_CFLAGS}
        INCLUDE_DIRS: ${LIBUNWIND_INCLUDE_DIRS}
        LDFLAGS: ${LIBUNWIND_LDFLAGS}")
        string(REPLACE ";" " " ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND
                       " ${LIBUNWIND_LDFLAGS}")
        if(TARGET ZLIB::ZLIB)
          set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND
              "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND} -lz")
        endif()
      endif()
    endif()
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
  set(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY})
  set(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE})
  set(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ${CMAKE_FIND_ROOT_PATH_MODE_PACKAGE})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND)
    set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_STANDARD_LIBRARIES
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND}")
    set(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_STANDARD_LIBRARIES
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND}")
  endif()
  list(APPEND CMAKE_STAGING_PREFIX "${PROJECT_THIRD_PARTY_INSTALL_DIR}")
  find_configure_package(
    PACKAGE
    OpenSSL
    PORT_PREFIX
    "CRYPTO"
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_INHERIT_FIND_ROOT_PATH
    CMAKE_INHERIT_SYSTEM_LINKS
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_SRC_DIRECTORY_NAME}"
    PROJECT_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_SRC_DIRECTORY_NAME}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_GIT_URL}")
  list(POP_BACK CMAKE_STAGING_PREFIX)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ${ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_LIBRARY})
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ${ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE})
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ${ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_PACKAGE})
  unset(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM)
  unset(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_LIBRARY)
  unset(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE)
  unset(ATFRAMEWORK_CMAKE_TOOLSET_BACKUP_CMAKE_FIND_ROOT_PATH_MODE_PACKAGE)
  unset(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPTO_BORINGSSL_PATCH_LIBUNWIND)
  unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_CXX_STANDARD_LIBRARIES)
  unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_INHERIT_CMAKE_C_STANDARD_LIBRARIES)
  unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_PACKAGE)
  unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_INCLUDE)
  unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_LIBRARY)
  unset(PROJECT_BUILD_TOOLS_CMAKE_PATCH_OVERWRITE_CMAKE_FIND_ROOT_PATH_MODE_PROGRAM)

  if(OPENSSL_FOUND OR OpenSSL_FOUND)
    project_third_party_boringssl_import()
  else()
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): build boringssl failed.")
    message(FATAL_ERROR "boringssl is required.")
  endif()
endif()
