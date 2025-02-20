include_guard(GLOBAL)

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C
    CMAKE_C_FLAGS
    CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE
    CMAKE_C_FLAGS_RELWITHDEBINFO
    CMAKE_C_FLAGS_MINSIZEREL
    CMAKE_C_FLAGS_INIT
    CMAKE_C_FLAGS_DEBUG_INIT
    CMAKE_C_FLAGS_RELEASE_INIT
    CMAKE_C_FLAGS_RELWITHDEBINFO_INIT
    CMAKE_C_FLAGS_MINSIZEREL_INIT
    CMAKE_C_ARCHIVE_APPEND
    CMAKE_C_ARCHIVE_CREATE
    CMAKE_C_ARCHIVE_FINISH
    CMAKE_C_COMPILER
    CMAKE_C_COMPILER_TARGET
    CMAKE_C_COMPILER_LAUNCHER
    CMAKE_C_LINK_LIBRARY_SUFFIX
    CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES
    CMAKE_C_IMPLICIT_LINK_DIRECTORIES
    CMAKE_C_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES
    CMAKE_C_IMPLICIT_LINK_LIBRARIES
    CMAKE_C_COMPILER_FRONTEND_VARIANT
    CMAKE_C_STANDARD_INCLUDE_DIRECTORIES
    CMAKE_C_STANDARD_LIBRARIES)
set(PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_C CMAKE_HOST_C_COMPILER CMAKE_HOST_C_COMPILER_LAUNCHER
                                          CMAKE_HOST_C_COMPILER_TARGET)
if(NOT MSVC)
  if(ENV{AR} OR ENV{CMAKE_C_COMPILER_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C CMAKE_C_COMPILER_AR)
  endif()
  if(ENV{RANLIB} OR ENV{CMAKE_C_COMPILER_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C CMAKE_C_COMPILER_RANLIB)
  endif()
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_C CMAKE_C_EXTENSIONS CMAKE_OBJC_EXTENSIONS)

  if(ENV{CMAKE_HOST_C_COMPILER_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_C CMAKE_HOST_C_COMPILER_AR)
  endif()
  if(ENV{CMAKE_HOST_C_COMPILER_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_C CMAKE_HOST_C_COMPILER_RANLIB)
  endif()
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_C CMAKE_HOST_C_EXTENSIONS CMAKE_HOST_OBJC_EXTENSIONS)
endif()

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_CXX_FLAGS_RELWITHDEBINFO
    CMAKE_CXX_FLAGS_MINSIZEREL
    CMAKE_CXX_FLAGS_INIT
    CMAKE_CXX_FLAGS_DEBUG_INIT
    CMAKE_CXX_FLAGS_RELEASE_INIT
    CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT
    CMAKE_CXX_FLAGS_MINSIZEREL_INIT
    CMAKE_CXX_ARCHIVE_APPEND
    CMAKE_CXX_ARCHIVE_CREATE
    CMAKE_CXX_ARCHIVE_FINISH
    CMAKE_CXX_COMPILER
    CMAKE_CXX_COMPILER_TARGET
    CMAKE_CXX_COMPILER_LAUNCHER
    CMAKE_CXX_LINK_LIBRARY_SUFFIX
    CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES
    CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES
    CMAKE_CXX_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES
    CMAKE_CXX_IMPLICIT_LINK_LIBRARIES
    CMAKE_CXX_COMPILER_FRONTEND_VARIANT
    ANDROID_CPP_FEATURES
    ANDROID_STL
    CMAKE_ANDROID_STL_TYPE
    CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
    CMAKE_CXX_STANDARD_LIBRARIES)
set(PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_CXX CMAKE_HOST_CXX_COMPILER CMAKE_HOST_CXX_COMPILER_LAUNCHER
                                            CMAKE_HOST_CXX_COMPILER_TARGET)
if(NOT MSVC)
  if(ENV{AR} OR ENV{CMAKE_CXX_COMPILER_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX CMAKE_CXX_COMPILER_AR)
  endif()
  if(ENV{RANLIB} OR ENV{CMAKE_CXX_COMPILER_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX CMAKE_CXX_COMPILER_RANLIB)
  endif()
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_CXX CMAKE_CXX_COMPILER_AR CMAKE_CXX_EXTENSIONS
       CMAKE_OBJCXX_EXTENSIONS)

  if(ENV{CMAKE_HOST_CXX_COMPILER_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_CXX CMAKE_HOST_CXX_COMPILER_AR)
  endif()
  if(ENV{CMAKE_HOST_CXX_COMPILER_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_CXX CMAKE_HOST_CXX_COMPILER_RANLIB)
  endif()
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_CXX CMAKE_HOST_CXX_EXTENSIONS CMAKE_HOST_OBJCXX_EXTENSIONS)
endif()

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM
    CMAKE_ASM_FLAGS
    CMAKE_ASM_FLAGS_INIT
    CMAKE_ASMFLAGS
    CMAKE_ASMFLAGS_INIT
    CMAKE_ASM_ARCHIVE_APPEND
    CMAKE_ASM_ARCHIVE_CREATE
    CMAKE_ASM_ARCHIVE_FINISH
    CMAKE_ASM_COMPILER
    CMAKE_ASM_COMPILER_TARGET
    CMAKE_ASM_COMPILER_LAUNCHER
    CMAKE_ASM_LINK_LIBRARY_SUFFIX
    CMAKE_ASM_COMPILER_FRONTEND_VARIANT)
set(PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_ASM CMAKE_HOST_ASM_COMPILER CMAKE_HOST_ASM_COMPILER_TARGET
                                            CMAKE_HOST_ASM_COMPILER_LAUNCHER)
if(NOT MSVC)
  if(ENV{AR} OR ENV{CMAKE_ASM_COMPILER_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM CMAKE_ASM_COMPILER_AR)
  endif()
  if(ENV{RANLIB} OR ENV{CMAKE_ASM_COMPILER_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM CMAKE_ASM_COMPILER_RANLIB)
  endif()
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_ASM CMAKE_ASM_EXTENSIONS)

  if(ENV{CMAKE_HOST_ASM_COMPILER_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_ASM CMAKE_HOST_ASM_COMPILER_AR)
  endif()
  if(ENV{CMAKE_HOST_ASM_COMPILER_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_ASM CMAKE_HOST_ASM_COMPILER_RANLIB)
  endif()
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_ASM CMAKE_HOST_ASM_EXTENSIONS)
endif()

set(PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON
    CMAKE_EXE_LINKER_FLAGS
    CMAKE_MODULE_LINKER_FLAGS
    CMAKE_SHARED_LINKER_FLAGS
    CMAKE_STATIC_LINKER_FLAGS
    CMAKE_EXE_LINKER_FLAGS_INIT
    CMAKE_MODULE_LINKER_FLAGS_INIT
    CMAKE_SHARED_LINKER_FLAGS_INIT
    CMAKE_BUILD_RPATH
    CMAKE_BUILD_RPATH_USE_ORIGIN
    CMAKE_BUILD_WITH_INSTALL_RPATH
    CMAKE_INSTALL_RPATH
    CMAKE_INSTALL_RPATH_USE_LINK_PATH
    CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH
    # CMake system
    CMAKE_EXPORT_NO_PACKAGE_REGISTRY
    CMAKE_EXPORT_PACKAGE_REGISTRY
    CMAKE_INCLUDE_DIRECTORIES_BEFORE
    CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE
    CMAKE_LINK_DIRECTORIES_BEFORE
    CMAKE_MAP_IMPORTED_CONFIG_NOCONFIG
    CMAKE_MAP_IMPORTED_CONFIG_DEBUG
    CMAKE_MAP_IMPORTED_CONFIG_RELEASE
    CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO
    CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL
    # For OSX
    CMAKE_OSX_ARCHITECTURES
    CMAKE_OSX_DEPLOYMENT_TARGET
    CMAKE_MACOSX_RPATH
    # For Android
    ANDROID_TOOLCHAIN
    ANDROID_ABI
    ANDROID_PIE
    ANDROID_PLATFORM
    ANDROID_ALLOW_UNDEFINED_SYMBOLS
    ANDROID_ARM_MODE
    ANDROID_ARM_NEON
    ANDROID_DISABLE_NO_EXECUTE
    ANDROID_DISABLE_RELRO
    ANDROID_DISABLE_FORMAT_STRING_CHECKS
    ANDROID_CCACHE
    ANDROID_TOOLCHAIN
    ANDROID_USE_LEGACY_TOOLCHAIN_FILE
    ANDROID_SANITIZE
    CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION
    CMAKE_ANDROID_ARCH_ABI
    CMAKE_ANDROID_API
    # For MSVC
    CMAKE_MSVC_RUNTIME_LIBRARY
    #[[ See
    #   https://github.com/microsoft/vcpkg/issues/16165
    #   https://github.com/microsoft/vcpkg/discussions/30252
    #   https://github.com/microsoft/vcpkg/discussions/19149
    ]]
    VS_GLOBAL_VcpkgEnabled)
if(CMAKE_CROSSCOMPILING)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_OSX_SYSROOT)
endif()
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_FIND_PACKAGE_REDIRECTS_DIR)
endif()
if(MSVC)
  list(
    APPEND
    PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON
    CMAKE_COMPILE_PDB_OUTPUT_DIRECTORY
    CMAKE_COMPILE_PDB_OUTPUT_DIRECTORY_DEBUG
    CMAKE_COMPILE_PDB_OUTPUT_DIRECTORY_RELEASE
    CMAKE_COMPILE_PDB_OUTPUT_DIRECTORY_RELWITHDEBINFO
    CMAKE_COMPILE_PDB_OUTPUT_DIRECTORY_MINISIZEREL
    CMAKE_PDB_OUTPUT_DIRECTORY
    CMAKE_PDB_OUTPUT_DIRECTORY_DEBUG
    CMAKE_PDB_OUTPUT_DIRECTORY_RELEASE
    CMAKE_PDB_OUTPUT_DIRECTORY_RELWITHDEBINFO
    CMAKE_PDB_OUTPUT_DIRECTORY_MINISIZEREL)
endif()

set(PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_COMMON
    CMAKE_HOST_EXE_LINKER_FLAGS
    CMAKE_HOST_MODULE_LINKER_FLAGS
    CMAKE_HOST_SHARED_LINKER_FLAGS
    CMAKE_HOST_STATIC_LINKER_FLAGS
    CMAKE_HOST_LINK_DIRECTORIES_BEFORE
    CMAKE_HOST_BUILD_RPATH
    CMAKE_HOST_BUILD_RPATH_USE_ORIGIN
    CMAKE_HOST_BUILD_WITH_INSTALL_RPATH
    CMAKE_HOST_INSTALL_RPATH
    CMAKE_HOST_INSTALL_RPATH_USE_LINK_PATH
    CMAKE_HOST_INSTALL_REMOVE_ENVIRONMENT_RPATH
    CMAKE_HOST_SYSROOT
    CMAKE_HOST_SYSROOT_COMPILE
    CMAKE_HOST_SYSROOT_LINK
    CMAKE_HOST_FIND_ROOT_PATH
    CMAKE_HOST_PREFIX_PATH
    CMAKE_HOST_STAGING_PREFIX
    CMAKE_HOST_IGNORE_PATH
    CMAKE_HOST_SYSTEM_LIBRARY_PATH
    CMAKE_HOST_SYSTEM_VERSION
    CMAKE_HOST_SYSTEM_INCLUDE_PATH
    CMAKE_HOST_SYSTEM_LIBRARY_PATH
    CMAKE_HOST_SYSTEM_PREFIX_PATH
    CMAKE_HOST_SYSTEM_PROGRAM_PATH
    CMAKE_HOST_SYSTEM_IGNORE_PATH
    # For OSX
    CMAKE_HOST_OSX_SYSROOT
    CMAKE_HOST_OSX_ARCHITECTURES
    CMAKE_HOST_OSX_DEPLOYMENT_TARGET
    CMAKE_HOST_MACOSX_RPATH
    CMAKE_HOST_MACOSX_BUNDLE
    CMAKE_HOST_FIND_FRAMEWORK
    CMAKE_HOST_FIND_APPBUNDLE
    CMAKE_FRAMEWORK_PATH
    CMAKE_APPBUNDLE_PATH
    CMAKE_HOST_SYSTEM_FRAMEWORK_PATH
    CMAKE_HOST_SYSTEM_APPBUNDLE_PATH
    # For MSVC
    CMAKE_HOST_MSVC_RUNTIME_LIBRARY
    # For CMake
    CMAKE_HOST_FIND_USE_CMAKE_SYSTEM_PATH
    CMAKE_HOST_FIND_USE_CMAKE_ENVIRONMENT_PATH
    CMAKE_HOST_FIND_USE_CMAKE_PATH
    CMAKE_HOST_FIND_USE_PACKAGE_ROOT_PATH
    CMAKE_HOST_FIND_USE_SYSTEM_ENVIRONMENT_PATH
    CMAKE_HOST_FIND_NO_INSTALL_PREFIX
    CMAKE_HOST_FIND_ROOT_PATH_MODE_PROGRAM
    CMAKE_HOST_FIND_ROOT_PATH_MODE_LIBRARY
    CMAKE_HOST_FIND_ROOT_PATH_MODE_INCLUDE
    CMAKE_HOST_FIND_ROOT_PATH_MODE_PACKAGE)
set(PROJECT_BUILD_TOOLS_CMAKE_HOST_INHERIT_VARS_COMMON
    # CMake system
    CMAKE_HOST_FIND_USE_PACKAGE_REGISTRY
    CMAKE_HOST_FIND_PACKAGE_NO_PACKAGE_REGISTRY
    CMAKE_HOST_FIND_USE_SYSTEM_PACKAGE_REGISTRY
    CMAKE_HOST_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY
    CMAKE_HOST_FIND_PACKAGE_PREFER_CONFIG
    CMAKE_HOST_FIND_PACKAGE_RESOLVE_SYMLINKS
    CMAKE_HOST_EXPORT_NO_PACKAGE_REGISTRY
    CMAKE_HOST_EXPORT_PACKAGE_REGISTRY
    CMAKE_HOST_MAP_IMPORTED_CONFIG_NOCONFIG
    CMAKE_HOST_MAP_IMPORTED_CONFIG_DEBUG
    CMAKE_HOST_MAP_IMPORTED_CONFIG_RELEASE
    CMAKE_HOST_MAP_IMPORTED_CONFIG_RELWITHDEBINFO
    CMAKE_HOST_MAP_IMPORTED_CONFIG_MINSIZEREL)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24")
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_INHERIT_VARS_COMMON CMAKE_HOST_FIND_PACKAGE_REDIRECTS_DIR)
endif()

if(NOT MSVC AND CMAKE_AR)
  if(ENV{AR} OR ENV{CMAKE_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_AR)
  endif()
  if(ENV{CMAKE_HOST_AR})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_COMMON CMAKE_HOST_AR)
  endif()
endif()
if(NOT MSVC AND CMAKE_RANLIB)
  if(ENV{RANLIB} OR ENV{CMAKE_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_RANLIB)
  endif()
  if(ENV{CMAKE_HOST_RANLIB})
    list(APPEND PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_COMMON CMAKE_HOST_RANLIB)
  endif()
endif()
if(VCPKG_TOOLCHAIN)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON VCPKG_TOOLCHAIN)
endif()
if(VCPKG_TARGET_TRIPLET)
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON VCPKG_TARGET_TRIPLET)
endif()

if(NOT CMAKE_SYSTEM_NAME STREQUAL CMAKE_HOST_SYSTEM_NAME)
  # Set CMAKE_SYSTEM_NAME will cause cmake to set CMAKE_CROSSCOMPILING to TRUE, so we don't set it when not
  # crosscompiling
  list(APPEND PROJECT_BUILD_TOOLS_CMAKE_INHERIT_VARS_COMMON CMAKE_SYSTEM_NAME CMAKE_SYSTEM_PROCESSOR)
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  list(
    APPEND
    PROJECT_BUILD_TOOLS_CMAKE_HOST_VARS_COMMON
    CMAKE_HOST_COMPILE_PDB_OUTPUT_DIRECTORY
    CMAKE_HOST_COMPILE_PDB_OUTPUT_DIRECTORY_DEBUG
    CMAKE_HOST_COMPILE_PDB_OUTPUT_DIRECTORY_RELEASE
    CMAKE_HOST_COMPILE_PDB_OUTPUT_DIRECTORY_RELWITHDEBINFO
    CMAKE_HOST_COMPILE_PDB_OUTPUT_DIRECTORY_MINISIZEREL
    CMAKE_HOST_PDB_OUTPUT_DIRECTORY
    CMAKE_HOST_PDB_OUTPUT_DIRECTORY_DEBUG
    CMAKE_HOST_PDB_OUTPUT_DIRECTORY_RELEASE
    CMAKE_HOST_PDB_OUTPUT_DIRECTORY_RELWITHDEBINFO
    CMAKE_HOST_PDB_OUTPUT_DIRECTORY_MINISIZEREL)
endif()

set(PROJECT_BUILD_TOOLS_CMAKE_FIND_ROOT_VARS
    CMAKE_SYSROOT
    CMAKE_SYSROOT_COMPILE
    CMAKE_SYSROOT_LINK
    CMAKE_STAGING_PREFIX
    CMAKE_MODULE_PATH
    CMAKE_PREFIX_PATH
    CMAKE_FIND_ROOT_PATH
    CMAKE_FIND_PACKAGE_PREFER_CONFIG
    CMAKE_FIND_NO_INSTALL_PREFIX
    CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY
    CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY
    CMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH
    CMAKE_FIND_USE_CMAKE_PATH
    CMAKE_FIND_USE_CMAKE_SYSTEM_PATH
    CMAKE_FIND_USE_PACKAGE_REGISTRY
    CMAKE_FIND_USE_PACKAGE_ROOT_PATH
    CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH
    CMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY
    CMAKE_FIND_ROOT_PATH_MODE_INCLUDE
    CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
    CMAKE_FIND_ROOT_PATH_MODE_PACKAGE
    CMAKE_FIND_ROOT_PATH_MODE_PROGRAM
    CMAKE_FIND_LIBRARY_CUSTOM_LIB_SUFFIX
    CMAKE_FIND_PACKAGE_RESOLVE_SYMLINKS
    FIND_LIBRARY_USE_LIB32_PATHS
    FIND_LIBRARY_USE_LIBX32_PATHS
    FIND_LIBRARY_USE_LIB64_PATHS
    CMAKE_FIND_FRAMEWORK
    CMAKE_FIND_APPBUNDLE
    CMAKE_FRAMEWORK_PATH
    CMAKE_APPBUNDLE_PATH
    CMAKE_SYSTEM_FRAMEWORK_PATH
    CMAKE_SYSTEM_APPBUNDLE_PATH
    CMAKE_IGNORE_PATH
    CMAKE_IGNORE_PREFIX_PATH
    CMAKE_SYSTEM_LIBRARY_PATH
    CMAKE_SYSTEM_VERSION
    CMAKE_SYSTEM_INCLUDE_PATH
    CMAKE_SYSTEM_LIBRARY_PATH
    CMAKE_SYSTEM_PREFIX_PATH
    CMAKE_SYSTEM_PROGRAM_PATH
    CMAKE_SYSTEM_IGNORE_PATH
    CMAKE_SYSTEM_IGNORE_PREFIX_PATH)
