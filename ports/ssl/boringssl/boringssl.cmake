# BoringSSL requires go and perl, we don't support it now.

include_guard(GLOBAL)

macro(PROJECT_THIRD_PARTY_BORINGSSL_IMPORT)
  if(OPENSSL_FOUND OR OpenSSL_FOUND)
    echowithcolor(COLOR GREEN "-- Dependency(${PROJECT_NAME}): boringssl found.(openssl: ${OPENSSL_VERSION})")
    if(TARGET OpenSSL::SSL OR TARGET OpenSSL::Crypto)
      if(TARGET OpenSSL::Crypto)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::Crypto)

        if(TARGET Threads::Threads)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES Threads::Threads
                                                                      ${CMAKE_DL_LIBS})
        elseif(CMAKE_DL_LIBS)
          project_build_tools_patch_imported_link_interface_libraries(OpenSSL::Crypto ADD_LIBRARIES ${CMAKE_DL_LIBS})
        endif()
      endif()
      if(TARGET OpenSSL::SSL)
        list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME OpenSSL::SSL)

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
            CACHE INTERNAL "Fix cmake module path for openssl" FORCE)
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

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_CRYPT_LINK_NAME)
  find_package(Perl REQUIRED)
  find_program(GO_EXECUTABLE go go.exe)
  if(NOT GO_EXECUTABLE)
    message(FATAL_ERROR "go is required to build boringssl")
  endif()

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_DEFAULT_BUILD_OPTIONS
      "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" "-DBUILD_SHARED_LIBS=OFF" "-DGO_EXECUTABLE=${GO_EXECUTABLE}"
      "-DPERL_EXECUTABLE=${PERL_EXECUTABLE}")
  if(CMAKE_CROSSCOMPILING)
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_DEFAULT_BUILD_OPTIONS "-DOPENSSL_NO_ASM=ON")
  endif()
  project_third_party_port_declare(
    boringssl
    VERSION
    "479adf98d54a21c1d154aac59b2ce120e1d1a6d6"
    GIT_URL
    "https://github.com/google/boringssl.git"
    BUILD_OPTIONS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_DEFAULT_BUILD_OPTIONS})

  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_PATCH_FILE
      "${CMAKE_CURRENT_LIST_DIR}/boringssl-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_VERSION}.patch")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_PATCH_FILE}")
    list(APPEND ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_BUILD_OPTIONS GIT_PATCH_FILES
         "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_PATCH_FILE}")
  endif()

  find_configure_package(
    PACKAGE
    OpenSSL
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_FLAGS
    ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_BUILD_OPTIONS}
    WORKING_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    BUILD_DIRECTORY
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_BUILD_DIR}"
    PREFIX_DIRECTORY
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_SRC_DIRECTORY_NAME}"
    PROJECT_DIRECTORY
    "${PROJECT_THIRD_PARTY_PACKAGE_DIR}/${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_SRC_DIRECTORY_NAME}"
    GIT_BRANCH
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_VERSION}"
    GIT_URL
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_BORINGSSL_GIT_URL}")

  if(OPENSSL_FOUND OR OpenSSL_FOUND)
    project_third_party_boringssl_import()
  else()
    echowithcolor(COLOR RED "-- Dependency(${PROJECT_NAME}): build boringssl failed.")
  endif()
endif()
