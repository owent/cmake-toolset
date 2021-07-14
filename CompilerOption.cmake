include_guard(GLOBAL)

# default configure, can be load multiple times and in different paths
# ######################################################################################################################
if(NOT DEFINED __COMPILER_OPTION_LOADED)
  include("${CMAKE_CURRENT_LIST_DIR}/modules/ProjectBuildTools.cmake")

  include(CheckCXXSourceCompiles)
  set(__COMPILER_OPTION_LOADED 1)
  cmake_policy(PUSH)
  cmake_policy(SET CMP0067 NEW)

  option(COMPILER_OPTION_MSVC_ZC_CPP
         "Add /Zc:__cplusplus for MSVC (let __cplusplus be equal to _MSVC_LANG) when it support." ON)
  option(COMPILER_OPTION_CLANG_ENABLE_LIBCXX "Try to use libc++ when using clang." ON)

  # See Windows.h for more details
  option(COMPILER_OPTION_WINDOWS_ENABLE_NOMINMAX "Add #define NOMINMAX." ON)
  option(COMPILER_OPTION_WINDOWS_ENABLE_WIN32_LEAN_AND_MEAN "Add #define WIN32_LEAN_AND_MEAN." OFF)

  # Auto inherit options from commandline
  foreach(COMPILER_OPTION_INHERIT_VAR_NAME
          ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX}
          ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM} ${PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON})
    if(DEFINED CACHE{${COMPILER_OPTION_INHERIT_VAR_NAME}})
      set(COMPILER_OPTION_INHERIT_${COMPILER_OPTION_INHERIT_VAR_NAME} "$CACHE{${COMPILER_OPTION_INHERIT_VAR_NAME}}")
    endif()
  endforeach()
  unset(COMPILER_OPTION_INHERIT_VAR_NAME)

  set(CMAKE_POSITION_INDEPENDENT_CODE
      ON
      CACHE BOOL "Enable IndependentCode")

  if(CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Available Build Type: ${CMAKE_CONFIGURATION_TYPES}")
  else()
    message(STATUS "Available Build Type: Unknown")
  endif()

  if(NOT CMAKE_BUILD_TYPE)
    # set(CMAKE_BUILD_TYPE "Debug")
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
  endif()

  # utility functions and macros
  macro(add_compiler_flags_to_var VARNAME)
    project_build_tools_append_space_flags_to_var(${VARNAME} "${ARGN}")
  endmacro()

  macro(add_compiler_flags_to_var_unique VARNAME)
    project_build_tools_append_space_flags_to_var_unique(${VARNAME} "${ARGN}")
  endmacro()

  macro(add_compiler_flags_to_inherit_var VARNAME)
    add_compiler_flags_to_var(${VARNAME} "${ARGN}")
    if("${VARNAME}" MATCHES "^CMAKE_")
      add_compiler_flags_to_var(COMPILER_OPTION_INHERIT_${VARNAME} "${ARGN}")
    endif()
  endmacro()

  macro(add_compiler_flags_to_inherit_var_unique VARNAME)
    add_compiler_flags_to_var_unique(${VARNAME} "${ARGN}")
    if("${VARNAME}" MATCHES "^CMAKE_")
      add_compiler_flags_to_var_unique(COMPILER_OPTION_INHERIT_${VARNAME} "${ARGN}")
    endif()
  endmacro()

  macro(add_list_flags_to_var VARNAME)
    list(APPEND ${VARNAME} "${ARGN}")
  endmacro()

  macro(add_list_flags_to_var_unique VARNAME)
    if(${VARNAME})
      foreach(def ${ARGN})
        if(NOT "${def}" IN_LIST ${VARNAME})
          list(APPEND ${VARNAME} "${def}")
        endif()
      endforeach()
    else()
      list(APPEND ${VARNAME} "${ARGN}")
    endif()
  endmacro()

  macro(add_list_flags_to_inherit_var VARNAME)
    add_list_flags_to_var(${VARNAME} "${ARGN}")
    if("${VARNAME}" MATCHES "^CMAKE_")
      add_list_flags_to_var(COMPILER_OPTION_INHERIT_${VARNAME} "${ARGN}")
    endif()
  endmacro()

  macro(add_list_flags_to_inherit_var_unique VARNAME)
    add_list_flags_to_var_unique(${VARNAME} "${ARGN}")
    if("${VARNAME}" MATCHES "^CMAKE_")
      add_list_flags_to_var_unique(COMPILER_OPTION_INHERIT_${VARNAME} "${ARGN}")
    endif()
  endmacro()

  macro(list_append_unescape VARNAME)
    string(REPLACE ";" "\\;" list_append_unescape_VAL "${ARGN}")
    if(list_append_unescape_VAL)
      list(APPEND ${VARNAME} "${list_append_unescape_VAL}")
    endif()
    unset(list_append_unescape_VAL)
  endmacro()

  macro(list_prepend_unescape VARNAME)
    string(REPLACE ";" "\\;" list_append_unescape_VAL "${ARGN}")
    if(list_append_unescape_VAL)
      list(PREPEND ${VARNAME} "${list_append_unescape_VAL}")
    endif()
    unset(list_append_unescape_VAL)
  endmacro()

  macro(add_compiler_define)
    foreach(def ${ARGN})
      if(MSVC)
        add_compile_options("/D ${def}")
      else()
        add_compile_options("-D${def}")
      endif()
    endforeach()
  endmacro()

  macro(add_compiler_define_to_var VARNAME)
    foreach(def ${ARGN})
      if(MSVC)
        if(${VARNAME})
          set(${VARNAME} "${${VARNAME}} /D${def}")
        else()
          set(${VARNAME} "/D${def}")
        endif()
      else()
        if(${VARNAME})
          set(${VARNAME} "${${VARNAME}} -D${def}")
        else()
          set(${VARNAME} "-D${def}")
        endif()
      endif()
    endforeach()
  endmacro()

  macro(add_linker_flags_for_runtime)
    foreach(def ${ARGN})
      if(CMAKE_EXE_LINKER_FLAGS)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${def}")
      else()
        set(CMAKE_EXE_LINKER_FLAGS "${def}")
      endif()
      if(CMAKE_MODULE_LINKER_FLAGS)
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${def}")
      else()
        set(CMAKE_MODULE_LINKER_FLAGS "${def}")
      endif()
      if(CMAKE_SHARED_LINKER_FLAGS)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${def}")
      else()
        set(CMAKE_SHARED_LINKER_FLAGS "${def}")
      endif()
    endforeach()
  endmacro()

  macro(add_linker_flags_for_all)
    foreach(def ${ARGN})
      add_linker_flags_for_runtime(${def})
      if(CMAKE_STATIC_LINKER_FLAGS)
        set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} ${def}")
      else()
        set(CMAKE_STATIC_LINKER_FLAGS "${def}")
      endif()
    endforeach()
  endmacro()

  macro(try_set_compiler_lang_standard VARNAME STDVERSION)
    if(NOT ${VARNAME})
      set(${VARNAME} ${STDVERSION})
    endif()
  endmacro()

  function(add_target_properties TARGET_NAME PROPERTY_NAME)
    get_target_property(PROPERTY_OLD_VALUES ${TARGET_NAME} ${PROPERTY_NAME})
    if(PROPERTY_OLD_VALUES)
      list(APPEND PROPERTY_OLD_VALUES "${ARGN}")
    else()
      set(PROPERTY_OLD_VALUES "${ARGN}")
    endif()
    set_target_properties(${TARGET_NAME} PROPERTIES ${PROPERTY_NAME} "${PROPERTY_OLD_VALUES}")
  endfunction()

  function(remove_target_properties TARGET_NAME PROPERTY_NAME)
    get_target_property(PROPERTY_OLD_VALUES ${TARGET_NAME} ${PROPERTY_NAME})
    if(PROPERTY_OLD_VALUES)
      foreach(def ${ARGN})
        list(REMOVE_ITEM PROPERTY_OLD_VALUES ${def})
      endforeach()
      set_target_properties(${TARGET_NAME} PROPERTIES ${PROPERTY_NAME} "${PROPERTY_OLD_VALUES}")
    endif()
  endfunction(remove_target_properties)

  function(add_target_link_flags TARGET_NAME)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
      add_target_properties(${TARGET_NAME} LINK_OPTIONS "${ARGN}")
    else()
      add_target_properties(${TARGET_NAME} LINK_FLAGS "${ARGN}")
    endif()
  endfunction()

  # ================== system checking ==================
  if(ANDROID)
    if(ANDROID_SYSTEM_LIBRARY_PATH AND EXISTS "${ANDROID_SYSTEM_LIBRARY_PATH}/usr/lib")
      add_compiler_flags_to_inherit_var_unique(CMAKE_SHARED_LINKER_FLAGS "-L${ANDROID_SYSTEM_LIBRARY_PATH}/usr/lib")
      add_compiler_flags_to_inherit_var_unique(CMAKE_MODULE_LINKER_FLAGS "-L${ANDROID_SYSTEM_LIBRARY_PATH}/usr/lib")
      add_compiler_flags_to_inherit_var_unique(CMAKE_EXE_LINKER_FLAGS "-L${ANDROID_SYSTEM_LIBRARY_PATH}/usr/lib")
    endif()
    if(ANDROID_LLVM_TOOLCHAIN_PREFIX)
      get_filename_component(ANDROID_LLVM_TOOLCHAIN_ROOT "${ANDROID_LLVM_TOOLCHAIN_PREFIX}" DIRECTORY)
      if(ANDROID_LLVM_TOOLCHAIN_ROOT AND EXISTS
                                         "${ANDROID_LLVM_TOOLCHAIN_ROOT}/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}")
        add_compiler_flags_to_inherit_var_unique(
          CMAKE_SHARED_LINKER_FLAGS
          "-L${ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}/"
          "-L${ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}/${ANDROID_PLATFORM_LEVEL}"
        )
        add_compiler_flags_to_inherit_var_unique(
          CMAKE_MODULE_LINKER_FLAGS
          "-L${ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}/"
          "-L${ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}/${ANDROID_PLATFORM_LEVEL}"
        )
        add_compiler_flags_to_inherit_var_unique(
          CMAKE_EXE_LINKER_FLAGS
          "-L${ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}/"
          "-L${ANDROID_NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/${ANDROID_TOOLCHAIN_NAME}/${ANDROID_PLATFORM_LEVEL}"
        )
      endif()
    endif()
  endif()

  # ================== compiler flags ==================
  # Auto compiler options, support gcc,MSVC,Clang,AppleClang
  if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    list(APPEND COMPILER_STRICT_EXTRA_CFLAGS -Wextra)
    list(APPEND COMPILER_STRICT_CFLAGS -Wall -Werror)

    include(CheckCCompilerFlag)
    check_c_compiler_flag(-rdynamic LD_FLAGS_RDYNAMIC_AVAILABLE)
    if(LD_FLAGS_RDYNAMIC_AVAILABLE)
      message(STATUS "Check Flag: -rdynamic -- yes")
      add_linker_flags_for_runtime(-rdynamic)
    else()
      message(STATUS "Check Flag: -rdynamic -- no")
    endif()

    # gcc 4.9 or upper add colorful output
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.9.0")
      add_compile_options(-fdiagnostics-color=auto)
    endif()
    # disable -Wno-unused-local-typedefs (which is often used in type_traits)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.8.0")
      # GCC < 4.8 doesn't support the address sanitizer -fsanitize=address require -lasan be placed before -lstdc++,
      # every target shoud add this
      add_compile_options(-Wno-unused-local-typedefs)
      message(STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} Found, -Wno-unused-local-typedefs added.")
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "5.0.0")
      try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
      if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 20)
      elseif(CMAKE_VERSION VERSION_GREATER_EQUAL "3.8.0")
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 17)
      else()
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 14)
      endif()
      message(
        STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c${CMAKE_C_STANDARD}/c++${CMAKE_CXX_STANDARD}.")
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.7.0")
      try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
      try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 14)
      message(
        STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c${CMAKE_C_STANDARD}/c++${CMAKE_CXX_STANDARD}.")
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "4.4.0")
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS -std=c++0x)
      message(STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c++0x.")
    endif()

  elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    list(APPEND COMPILER_STRICT_EXTRA_CFLAGS -Wextra)
    list(APPEND COMPILER_STRICT_CFLAGS -Wall -Werror)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "3.4")
      try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
      if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 20)
      elseif(CMAKE_VERSION VERSION_GREATER_EQUAL "3.8.0")
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 17)
      else()
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 14)
      endif()
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "3.3")
      try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
      try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 11)
    endif()
    message(
      STATUS "Clang Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c${CMAKE_C_STANDARD}/c++${CMAKE_CXX_STANDARD}.")
    if(CMAKE_CXX_FLAGS MATCHES "-stdlib=([A-Za-z0-9\\+]+)")
      message(STATUS "Clang use stdlib=${CMAKE_MATCH_1}(CMAKE_CXX_FLAGS)")
      if(CMAKE_MATCH_1 STREQUAL "libc++")
        set(COMPILER_CLANG_TEST_LIBCXX ON)
      else()
        set(COMPILER_CLANG_TEST_LIBCXX OFF)
      endif()
    else()
      # Test libc++ and libc++abi
      set(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
      set(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES})
      set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -stdlib=libc++")
      list(APPEND CMAKE_REQUIRED_LIBRARIES c++ c++abi)
      check_cxx_source_compiles(
        "#include <iostream>
         int main() {
           std::cout<< __cplusplus<< std::endl;
           return 0;
         }
        "
        COMPILER_CLANG_TEST_LIBCXX)
      set(CMAKE_REQUIRED_FLAGS ${COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_FLAGS})
      set(CMAKE_REQUIRED_LIBRARIES ${COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_LIBRARIES})
      unset(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_FLAGS)
      unset(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_LIBRARIES)
      if(COMPILER_OPTION_CLANG_ENABLE_LIBCXX AND COMPILER_CLANG_TEST_LIBCXX)
        add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS -stdlib=libc++)
        message(STATUS "Clang use stdlib=libc++")
        list(APPEND COMPILER_OPTION_EXTERN_CXX_LIBS c++ c++abi)
      else()
        check_cxx_source_compiles(
          "#include <cstddef>
           int main() {
             std::cout<< _LIBCPP_VERSION<< std::endl;
             return 0;
           }"
          COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBCXX)
        if(COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBCXX)
          set(COMPILER_CLANG_TEST_DEFAULT_STDLIB "libc++")
        else()
          check_cxx_source_compiles(
            "#include <cstddef>
             int main() {
               std::cout<< __GLIBCXX__<< std::endl;
               return 0;
             }"
            COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBSTDCXX)
          if(COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBSTDCXX)
            set(COMPILER_CLANG_TEST_DEFAULT_STDLIB "libstdc++")
          else()
            set(COMPILER_CLANG_TEST_DEFAULT_STDLIB "unknown")
          endif()
        endif()
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "3.9")
          message(STATUS "Clang use stdlib=default(${COMPILER_CLANG_TEST_DEFAULT_STDLIB})")
        else()
          add_compile_options(-D__STRICT_ANSI__)
          message(STATUS "Clang use stdlib=default(${COMPILER_CLANG_TEST_DEFAULT_STDLIB}) and add -D__STRICT_ANSI__")
        endif()
      endif()
    endif()

    # C++20 coroutine precondition
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "8.0")
      # @see https://en.cppreference.com/w/cpp/compiler_support Clang 6 and older will crash when visit local variable
      # of a c++20 coroutine stack It will use movaps of SSE to initialize local variables of a c++20 coroutine stack
      # but doesn't aligned to 16, which will cause crash. @see https://github.com/HJLebbink/asm-dude/wiki/MOVAPS for
      # details
      set(COMPILER_OPTIONS_TEST_STD_COROUTINE FALSE)
      set(COMPILER_OPTIONS_TEST_STD_COROUTINE_TS FALSE)
    endif()
  elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
    list(APPEND COMPILER_STRICT_EXTRA_CFLAGS -Wextra -Wno-implicit-fallthrough)
    list(APPEND COMPILER_STRICT_CFLAGS -Wall -Werror)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "6.0")
      try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
      if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 20)
      elseif(CMAKE_VERSION VERSION_GREATER_EQUAL "3.8.0")
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 17)
      else()
        try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 14)
      endif()
    elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "5.0")
      try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
      try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 11)
    endif()
    message(
      STATUS
        "AppleClang Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c${CMAKE_C_STANDARD}/c++${CMAKE_CXX_STANDARD}.")
    # Test libc++ and libc++abi
    if(CMAKE_CXX_FLAGS MATCHES "-stdlib=([A-Za-z0-9\\+]+)")
      message(STATUS "Clang use stdlib=${CMAKE_MATCH_1}(CMAKE_CXX_FLAGS)")
      if(CMAKE_MATCH_1 STREQUAL "libc++")
        set(COMPILER_CLANG_TEST_LIBCXX ON)
      else()
        set(COMPILER_CLANG_TEST_LIBCXX OFF)
      endif()
    else()
      set(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
      set(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_LIBRARIES ${CMAKE_REQUIRED_LIBRARIES})
      set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -stdlib=libc++")
      list(APPEND CMAKE_REQUIRED_LIBRARIES c++ c++abi)
      check_cxx_source_compiles(
        "#include <iostream>
         int main() {
           std::cout<< __cplusplus<< std::endl;
           return 0;
         }"
        COMPILER_CLANG_TEST_LIBCXX)
      set(CMAKE_REQUIRED_FLAGS ${COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_FLAGS})
      set(CMAKE_REQUIRED_LIBRARIES ${COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_LIBRARIES})
      unset(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_FLAGS)
      unset(COMPILER_CLANG_TEST_BAKCUP_CMAKE_REQUIRED_LIBRARIES)
      if(COMPILER_OPTION_CLANG_ENABLE_LIBCXX AND COMPILER_CLANG_TEST_LIBCXX)
        add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS -stdlib=libc++)
        message(STATUS "AppleClang use stdlib=libc++")
        list(APPEND COMPILER_OPTION_EXTERN_CXX_LIBS c++ c++abi)
      else()
        check_cxx_source_compiles(
          "#include <cstddef>
           int main() {
             std::cout<< _LIBCPP_VERSION<< std::endl;
             return 0;
           }"
          COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBCXX)
        if(COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBCXX)
          set(COMPILER_CLANG_TEST_DEFAULT_STDLIB "libc++")
        else()
          check_cxx_source_compiles(
            "#include <cstddef>
             int main() {
               std::cout<< __GLIBCXX__<< std::endl;
               return 0;
             }"
            COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBSTDCXX)
          if(COMPILER_CLANG_TEST_DEFAULT_STDLIB_LIBSTDCXX)
            set(COMPILER_CLANG_TEST_DEFAULT_STDLIB "libstdc++")
          else()
            set(COMPILER_CLANG_TEST_DEFAULT_STDLIB "unknown")
          endif()
        endif()
        message(STATUS "AppleClang use stdlib=default(${COMPILER_CLANG_TEST_DEFAULT_STDLIB})")
      endif()
    endif()

    # C++20 coroutine precondition
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0.1")
      # @see https://en.cppreference.com/w/cpp/compiler_support Apple clang 9 and older will crash when visit local
      # variable of a c++20 coroutine stack. It will use movaps of SSE to initialize local variables of a c++20
      # coroutine stack but doesn't aligned to 16, which will cause crash. @see
      # https://github.com/HJLebbink/asm-dude/wiki/MOVAPS for details
      set(COMPILER_OPTIONS_TEST_STD_COROUTINE FALSE)
      set(COMPILER_OPTIONS_TEST_STD_COROUTINE_TS FALSE)
    endif()
  elseif(MSVC)
    list(
      APPEND
      COMPILER_STRICT_CFLAGS
      /W4
      /wd4100
      /wd4125
      /wd4566
      /wd4127
      /wd4512
      /WX)
    add_linker_flags_for_runtime(/ignore:4217)

    if(NOT VCPKG_TOOLCHAIN)
      add_compiler_flags_to_inherit_var_unique(
        CMAKE_CXX_FLAGS
        /nologo
        /DWIN32
        /D_WINDOWS
        "/utf-8"
        /GR
        /MP
        /EHsc)
      add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS /nologo /DWIN32 /D_WINDOWS "/utf-8" /MP)
      add_compiler_flags_to_inherit_var_unique(CMAKE_RC_FLAGS "-c65001" "/DWIN32")
    endif()

    try_set_compiler_lang_standard(CMAKE_C_STANDARD 11)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.12.0")
      try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 20)
    elseif(CMAKE_VERSION VERSION_GREATER_EQUAL "3.8.0")
      try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 17)
    else()
      try_set_compiler_lang_standard(CMAKE_CXX_STANDARD 14)
    endif()
    # https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warnings-by-compiler-version
    # https://docs.microsoft.com/en-us/cpp/preprocessor/predefined-macros?view=vs-2019#microsoft-specific-predefined-macros
    # if (MSVC_VERSION GREATER_EQUAL 1910) add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS /std:c++17)
    # message(STATUS "MSVC ${MSVC_VERSION} found. using /std:c++17") endif() set __cplusplus to standard value, @see
    # https://docs.microsoft.com/zh-cn/cpp/build/reference/zc-cplusplus
    if(MSVC_VERSION GREATER_EQUAL 1914 AND COMPILER_OPTION_MSVC_ZC_CPP)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS /Zc:__cplusplus)
    endif()

    # C++20 coroutine precondition
    if(MSVC_VERSION LESS 1910)
      # VS2015 is the first version to support coroutine API, but it defines macro of yield,resume and etc. Which is
      # conflict with our old coroutine context and task. So we disable c++20 coroutine support for it.
      set(COMPILER_OPTIONS_TEST_STD_COROUTINE FALSE)
      set(COMPILER_OPTIONS_TEST_STD_COROUTINE_TS FALSE)
    endif()
  endif()

  if(MSVC)
    if(NOT VCPKG_TOOLCHAIN)
      add_compiler_flags_to_inherit_var_unique(
        CMAKE_CXX_FLAGS_DEBUG
        /Od
        /D_DEBUG
        /Z7
        /Ob0
        /Od
        /RTC1)
      add_compiler_flags_to_inherit_var_unique(
        CMAKE_C_FLAGS_DEBUG
        /Od
        /D_DEBUG
        /Z7
        /Ob0
        /Od
        /RTC1)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELEASE /O2 /Oi /Gy /DNDEBUG /Z7)
      add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS_RELEASE /O2 /Oi /Gy /DNDEBUG /Z7)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELWITHDEBINFO /O2 /Oi /Gy /DNDEBUG /Z7)
      add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS_RELWITHDEBINFO /O2 /Oi /Gy /DNDEBUG /Z7)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_MINSIZEREL /Ox /Gy /DNDEBUG /Z7)
      add_compiler_flags_to_inherit_var_unique(CMAKE_C_FLAGS_MINSIZEREL /Ox /Gy /DNDEBUG /Z7)
      add_compiler_flags_to_inherit_var_unique(CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ")
      add_compiler_flags_to_inherit_var_unique(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/nologo" "/DEBUG" "/INCREMENTAL:NO"
                                               "/OPT:REF" "/OPT:ICF")
      add_compiler_flags_to_inherit_var_unique(CMAKE_EXE_LINKER_FLAGS_RELEASE "/nologo" "/DEBUG" "/INCREMENTAL:NO"
                                               "/OPT:REF" "/OPT:ICF")

      add_compiler_flags_to_inherit_var_unique(CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo ")
      add_compiler_flags_to_inherit_var_unique(CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo ")
      add_compiler_flags_to_inherit_var_unique(CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo ")
    endif()
  else()
    if(NOT EMSCRIPTEN)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_DEBUG -ggdb)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELWITHDEBINFO -ggdb)
    endif()
    # add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_DEBUG -ggdb)
    # add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELEASE)
    # add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELWITHDEBINFO -ggdb)
    # add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_MINSIZEREL)
  endif()

  # ================== support checking ==================
  # check c++20 coroutine
  if(NOT DEFINED COMPILER_OPTIONS_TEST_STD_COROUTINE)
    set(COMPILER_OPTIONS_BAKCUP_CMAKE_REQUIRED_FLAGS ${CMAKE_REQUIRED_FLAGS})
    if(NOT MSVC)
      # Try add coroutine
      set(CMAKE_REQUIRED_FLAGS "${COMPILER_OPTIONS_BAKCUP_CMAKE_REQUIRED_FLAGS} -fcoroutines")
      check_cxx_source_compiles(
        "#include <coroutine>
         int main() {
           return std::suspend_always().await_ready()? 0: 1;
         }"
        COMPILER_OPTIONS_TEST_STD_COROUTINE)
      if(NOT COMPILER_OPTIONS_TEST_STD_COROUTINE)
        set(CMAKE_REQUIRED_FLAGS "${COMPILER_OPTIONS_BAKCUP_CMAKE_REQUIRED_FLAGS} -fcoroutines-ts")
        check_cxx_source_compiles(
          "#include <experimental/coroutine>
           int main() {
             return std::experimental::suspend_always().await_ready()? 0: 1;
           }"
          COMPILER_OPTIONS_TEST_STD_COROUTINE_TS)
      endif()
    else()
      if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15.0")
        set(CMAKE_MSVC_RUNTIME_LIBRARY
            "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<NOT:$<STREQUAL:${VCPKG_CRT_LINKAGE},static>>:DLL>"
            CACHE STRING "")
      else()
        if(VCPKG_CRT_LINKAGE STREQUAL "static")
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_DEBUG /MTd)
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELEASE /MT)
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELWITHDEBINFO /MT)
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_MINSIZEREL /MT)
        else()
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_DEBUG /MDd)
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELEASE /MD)
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_RELWITHDEBINFO /MD)
          add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS_MINSIZEREL /MD)
        endif()
      endif()

      # Try add coroutine
      set(CMAKE_REQUIRED_FLAGS "${COMPILER_OPTIONS_BAKCUP_CMAKE_REQUIRED_FLAGS} /await")
      check_cxx_source_compiles(
        "#include <coroutine>
            int main() {
                return std::suspend_always().await_ready()? 0: 1;
            }"
        COMPILER_OPTIONS_TEST_STD_COROUTINE)
      if(NOT COMPILER_OPTIONS_TEST_STD_COROUTINE)
        check_cxx_source_compiles(
          "#include <experimental/coroutine>
           int main() {
             return std::experimental::suspend_always().await_ready()? 0: 1;
           }"
          COMPILER_OPTIONS_TEST_STD_COROUTINE_TS)
      endif()
    endif()
    set(CMAKE_REQUIRED_FLAGS ${COMPILER_OPTIONS_BAKCUP_CMAKE_REQUIRED_FLAGS})
    unset(COMPILER_OPTIONS_BAKCUP_CMAKE_REQUIRED_FLAGS)
  endif()

  # check add c++20 coroutine flags
  if(NOT MSVC)
    if(COMPILER_OPTIONS_TEST_STD_COROUTINE)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS -fcoroutines)
    elseif(COMPILER_OPTIONS_TEST_STD_COROUTINE_TS)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS -fcoroutines-ts)
    endif()
  else()
    if(COMPILER_OPTIONS_TEST_STD_COROUTINE OR COMPILER_OPTIONS_TEST_STD_COROUTINE_TS)
      add_compiler_flags_to_inherit_var_unique(CMAKE_CXX_FLAGS /await)
    endif()
  endif()

  # Check if exception enabled
  check_cxx_source_compiles("int main () { try { throw 123; } catch (...) {} return 0; }"
                            COMPILER_OPTIONS_TEST_EXCEPTION)
  if(COMPILER_OPTIONS_TEST_EXCEPTION)
    check_cxx_source_compiles(
      "#include <exception>
       void handle_eptr(std::exception_ptr eptr) {
           try {
               if (eptr) {
                   std::rethrow_exception(eptr);
               }
           } catch(...) {}
       }

       int main() {
           std::exception_ptr eptr;
           try {
               throw 1;
           } catch(...) {
               eptr = std::current_exception(); // capture
           }
           handle_eptr(eptr);
       }"
      COMPILER_OPTIONS_TEST_STD_EXCEPTION_PTR)
  else()
    unset(COMPILER_OPTIONS_TEST_STD_EXCEPTION_PTR CACHE)
  endif()
  # Check if rtti enabled
  check_cxx_source_compiles(
    "#include <typeinfo>
    #include <cstdio>
    int main () { puts(typeid(int).name()); return 0; }" COMPILER_OPTIONS_TEST_RTTI)

  # For Windows.h
  if(WIN32
     OR MINGW
     OR CYGWIN)
    if(COMPILER_OPTION_WINDOWS_ENABLE_NOMINMAX)
      add_compiler_define("NOMINMAX")
    endif()
    if(COMPILER_OPTION_WINDOWS_ENABLE_WIN32_LEAN_AND_MEAN)
      add_compiler_define("WIN32_LEAN_AND_MEAN")
    endif()
  endif()
  # Features test finished
  cmake_policy(POP)
endif()
