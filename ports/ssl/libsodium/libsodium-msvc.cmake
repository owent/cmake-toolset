include_guard(DIRECTORY)

function(project_third_party_libsodium_msvc_import OUTPUT_LOCAL_FOUND)
  set(_libsodium_debug_lib "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/libsodium-dbg.lib")
  set(_libsodium_release_lib "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/libsodium.lib")
  set(_libsodium_debug_dll "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/libsodium-dbg.dll")
  set(_libsodium_release_dll "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/libsodium.dll")

  set(_libsodium_local_found FALSE)
  foreach(_libsodium_artifact
          "${_libsodium_debug_lib}" "${_libsodium_release_lib}" "${_libsodium_debug_dll}" "${_libsodium_release_dll}"
          "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/sodium-dbg.lib" "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/sodium.lib")
    if(EXISTS "${_libsodium_artifact}")
      set(_libsodium_local_found TRUE)
      break()
    endif()
  endforeach()
  set(${OUTPUT_LOCAL_FOUND}
      "${_libsodium_local_found}"
      PARENT_SCOPE)

  if(TARGET sodium
     OR TARGET unofficial-sodium::sodium
     OR TARGET libsodium::libsodium
     OR NOT EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium.h"
     OR NOT EXISTS "${_libsodium_debug_lib}"
     OR NOT EXISTS "${_libsodium_release_lib}")
    return()
  endif()

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_USE_SHARED)
    if(NOT EXISTS "${_libsodium_debug_dll}" OR NOT EXISTS "${_libsodium_release_dll}")
      return()
    endif()
    add_library(libsodium::libsodium SHARED IMPORTED)
    set_target_properties(
      libsodium::libsodium
      PROPERTIES IMPORTED_IMPLIB "${_libsodium_release_lib}"
                 IMPORTED_IMPLIB_DEBUG "${_libsodium_debug_lib}"
                 IMPORTED_IMPLIB_RELEASE "${_libsodium_release_lib}"
                 IMPORTED_LOCATION "${_libsodium_release_dll}"
                 IMPORTED_LOCATION_DEBUG "${_libsodium_debug_dll}"
                 IMPORTED_LOCATION_RELEASE "${_libsodium_release_dll}")
  else()
    if(EXISTS "${_libsodium_debug_dll}" OR EXISTS "${_libsodium_release_dll}")
      return()
    endif()
    add_library(libsodium::libsodium STATIC IMPORTED)
    set_target_properties(
      libsodium::libsodium
      PROPERTIES IMPORTED_LOCATION "${_libsodium_release_lib}"
                 IMPORTED_LOCATION_DEBUG "${_libsodium_debug_lib}"
                 IMPORTED_LOCATION_RELEASE "${_libsodium_release_lib}"
                 INTERFACE_COMPILE_DEFINITIONS "SODIUM_STATIC=1")
  endif()

  set_target_properties(
    libsodium::libsodium
    PROPERTIES IMPORTED_CONFIGURATIONS "Debug;Release"
               INTERFACE_INCLUDE_DIRECTORIES "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include"
               INTERFACE_LINK_LIBRARIES "advapi32"
               MAP_IMPORTED_CONFIG_MINSIZEREL Release
               MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release)
endfunction()

function(project_third_party_libsodium_msvc_select_project OUTPUT_PROJECT OUTPUT_VERSION)
  if(MSVC_TOOLSET_VERSION)
    if(MSVC_TOOLSET_VERSION GREATER_EQUAL 145)
      set(_libsodium_requested_vs 2026)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 144)
      set(_libsodium_requested_vs 2025)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 143)
      set(_libsodium_requested_vs 2022)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 142)
      set(_libsodium_requested_vs 2019)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 141)
      set(_libsodium_requested_vs 2017)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 140)
      set(_libsodium_requested_vs 2015)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 120)
      set(_libsodium_requested_vs 2013)
    elseif(MSVC_TOOLSET_VERSION GREATER_EQUAL 110)
      set(_libsodium_requested_vs 2012)
    else()
      set(_libsodium_requested_vs 2010)
    endif()
  elseif(MSVC_VERSION)
    if(MSVC_VERSION GREATER_EQUAL 1950)
      set(_libsodium_requested_vs 2026)
    elseif(MSVC_VERSION GREATER_EQUAL 1930)
      set(_libsodium_requested_vs 2022)
    elseif(MSVC_VERSION GREATER_EQUAL 1920)
      set(_libsodium_requested_vs 2019)
    elseif(MSVC_VERSION GREATER_EQUAL 1910)
      set(_libsodium_requested_vs 2017)
    elseif(MSVC_VERSION GREATER_EQUAL 1900)
      set(_libsodium_requested_vs 2015)
    elseif(MSVC_VERSION GREATER_EQUAL 1800)
      set(_libsodium_requested_vs 2013)
    elseif(MSVC_VERSION GREATER_EQUAL 1700)
      set(_libsodium_requested_vs 2012)
    else()
      set(_libsodium_requested_vs 2010)
    endif()
  elseif(CMAKE_GENERATOR MATCHES "^Visual Studio\\s*[0-9]+\\s*([0-9]+)$")
    set(_libsodium_requested_vs "${CMAKE_MATCH_1}")
  else()
    message(FATAL_ERROR "Dependency(${PROJECT_NAME}): Unable to detect the MSVC toolset for libsodium")
  endif()

  foreach(
    _libsodium_vs_version
    2026
    2022
    2019
    2017
    2015
    2013
    2012
    2010)
    if(_libsodium_vs_version GREATER _libsodium_requested_vs)
      continue()
    endif()
    set(_libsodium_vcxproj
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}/builds/msvc/vs${_libsodium_vs_version}/libsodium/libsodium.vcxproj"
    )
    if(EXISTS "${_libsodium_vcxproj}")
      set(${OUTPUT_PROJECT}
          "${_libsodium_vcxproj}"
          PARENT_SCOPE)
      set(${OUTPUT_VERSION}
          "${_libsodium_vs_version}"
          PARENT_SCOPE)
      return()
    endif()
  endforeach()

  message(
    FATAL_ERROR
      "Dependency(${PROJECT_NAME}): No compatible libsodium MSVC project found for Visual Studio ${_libsodium_requested_vs}"
  )
endfunction()

function(project_third_party_libsodium_msvc_find_msbuild OUTPUT_COMMAND)
  if(CMAKE_VS_MSBUILD_COMMAND AND EXISTS "${CMAKE_VS_MSBUILD_COMMAND}")
    set(${OUTPUT_COMMAND}
        "${CMAKE_VS_MSBUILD_COMMAND}"
        PARENT_SCOPE)
    return()
  endif()

  unset(_libsodium_msbuild CACHE)
  find_program(_libsodium_msbuild NAMES MSBuild.exe msbuild)
  if(NOT _libsodium_msbuild)
    unset(_libsodium_vswhere CACHE)
    find_program(
      _libsodium_vswhere
      NAMES vswhere.exe
      HINTS "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer"
            "$ENV{ProgramFiles}/Microsoft Visual Studio/Installer"
      NO_DEFAULT_PATH)
    if(_libsodium_vswhere)
      execute_process(
        COMMAND "${_libsodium_vswhere}" -latest -products "*" -requires Microsoft.Component.MSBuild -find
                "MSBuild/**/Bin/MSBuild.exe"
        OUTPUT_VARIABLE _libsodium_msbuild
        OUTPUT_STRIP_TRAILING_WHITESPACE)
      if(_libsodium_msbuild)
        string(REGEX REPLACE "[\r\n]+" ";" _libsodium_msbuild "${_libsodium_msbuild}")
        list(GET _libsodium_msbuild 0 _libsodium_msbuild)
      endif()
    endif()
    unset(_libsodium_vswhere CACHE)
  endif()
  set(_libsodium_msbuild_command "${_libsodium_msbuild}")
  unset(_libsodium_msbuild CACHE)

  if(NOT EXISTS "${_libsodium_msbuild_command}")
    message(FATAL_ERROR "Dependency(${PROJECT_NAME}): MSBuild is required to build libsodium on MSVC")
  endif()
  set(${OUTPUT_COMMAND}
      "${_libsodium_msbuild_command}"
      PARENT_SCOPE)
endfunction()

function(project_third_party_libsodium_msvc_generate_version_header)
  set(_libsodium_version_header_in
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/version.h.in")
  if(NOT EXISTS "${_libsodium_version_header_in}")
    return()
  endif()

  string(REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" _libsodium_version_match
               "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_VERSION}")
  if(_libsodium_version_match)
    set(VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")
  else()
    set(VERSION "1.0.21")
  endif()

  set(SODIUM_LIBRARY_VERSION_MAJOR "26")
  set(SODIUM_LIBRARY_VERSION_MINOR "3")
  set(_libsodium_configure_ac "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}/configure.ac")
  if(EXISTS "${_libsodium_configure_ac}")
    file(STRINGS "${_libsodium_configure_ac}" _libsodium_library_major REGEX "^SODIUM_LIBRARY_VERSION_MAJOR=[0-9]+")
    file(STRINGS "${_libsodium_configure_ac}" _libsodium_library_minor REGEX "^SODIUM_LIBRARY_VERSION_MINOR=[0-9]+")
    if(_libsodium_library_major)
      string(REGEX REPLACE ".*=([0-9]+).*" "\\1" SODIUM_LIBRARY_VERSION_MAJOR "${_libsodium_library_major}")
    endif()
    if(_libsodium_library_minor)
      string(REGEX REPLACE ".*=([0-9]+).*" "\\1" SODIUM_LIBRARY_VERSION_MINOR "${_libsodium_library_minor}")
    endif()
  endif()
  set(SODIUM_LIBRARY_MINIMAL_DEF "")

  configure_file(
    "${_libsodium_version_header_in}"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium/version.h" @ONLY
    NEWLINE_STYLE LF)
endfunction()

function(project_third_party_libsodium_msvc_build)
  set(_libsodium_git_args
      URL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_GIT_URL}" REPO_DIRECTORY
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}" TAG
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_VERSION}")
  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE
     AND EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE}")
    list(APPEND _libsodium_git_args PATCH_FILES "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_PATCH_FILE}")
  endif()
  project_git_clone_repository(${_libsodium_git_args})

  if(NOT EXISTS "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}")
    message(WARNING "Dependency(${PROJECT_NAME}): libsodium source directory is unavailable")
    return()
  endif()
  file(MAKE_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_USE_SHARED)
    set(_libsodium_linkage DLL)
  else()
    set(_libsodium_linkage LIB)
  endif()

  if(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
    set(_libsodium_platform ARM64)
  elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
    set(_libsodium_platform ARM)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(_libsodium_platform x64)
  else()
    set(_libsodium_platform Win32)
  endif()

  project_third_party_libsodium_msvc_select_project(_libsodium_vcxproj _libsodium_vs_version)
  project_third_party_libsodium_msvc_find_msbuild(_libsodium_msbuild)
  message(STATUS "Dependency(${PROJECT_NAME}): Build libsodium with Visual Studio ${_libsodium_vs_version} project")

  if(DEFINED ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_MSVC_STATIC_RUNTIME)
    set(_libsodium_static_runtime "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_MSVC_STATIC_RUNTIME}")
  elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(_libsodium_static_runtime TRUE)
  elseif(CMAKE_MSVC_RUNTIME_LIBRARY AND NOT CMAKE_MSVC_RUNTIME_LIBRARY MATCHES "DLL")
    set(_libsodium_static_runtime TRUE)
  else()
    set(_libsodium_static_runtime FALSE)
  endif()
  if(_libsodium_static_runtime)
    set(_libsodium_debug_runtime MultiThreadedDebug)
    set(_libsodium_release_runtime MultiThreaded)
  else()
    set(_libsodium_debug_runtime MultiThreadedDebugDLL)
    set(_libsodium_release_runtime MultiThreadedDLL)
  endif()

  set(_libsodium_runtime_props "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}/msvc-runtime.props")
  set(_libsodium_runtime_props_content
      [=[<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemDefinitionGroup>
    <ClCompile>
      <RuntimeLibrary Condition="$(Configuration.IndexOf('Debug')) != -1">@_libsodium_debug_runtime@</RuntimeLibrary>
      <RuntimeLibrary Condition="$(Configuration.IndexOf('Release')) != -1">@_libsodium_release_runtime@</RuntimeLibrary>
    </ClCompile>
  </ItemDefinitionGroup>
</Project>
]=])
  string(CONFIGURE "${_libsodium_runtime_props_content}" _libsodium_runtime_props_content @ONLY)
  if(EXISTS "${_libsodium_runtime_props}")
    file(READ "${_libsodium_runtime_props}" _libsodium_runtime_props_old_content)
  endif()
  if(NOT _libsodium_runtime_props_content STREQUAL _libsodium_runtime_props_old_content)
    file(WRITE "${_libsodium_runtime_props}" "${_libsodium_runtime_props_content}")
  endif()

  project_third_party_libsodium_msvc_generate_version_header()

  set(_libsodium_msbuild_common_args "${_libsodium_vcxproj}" "/m" "/v:minimal" "/p:Platform=${_libsodium_platform}"
                                     "/p:ForceImportBeforeCppTargets=${_libsodium_runtime_props}")
  if(CMAKE_VS_PLATFORM_TOOLSET)
    list(APPEND _libsodium_msbuild_common_args "/p:PlatformToolset=${CMAKE_VS_PLATFORM_TOOLSET}")
  elseif(MSVC_TOOLSET_VERSION)
    list(APPEND _libsodium_msbuild_common_args "/p:PlatformToolset=v${MSVC_TOOLSET_VERSION}")
  endif()

  foreach(_libsodium_build_type Debug Release)
    if(_libsodium_build_type STREQUAL "Debug")
      set(_libsodium_target_name "libsodium-dbg")
    else()
      set(_libsodium_target_name "libsodium")
    endif()
    set(_libsodium_output_dir
        "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}/msbuild/${_libsodium_build_type}")

    execute_process(
      COMMAND
        "${_libsodium_msbuild}" ${_libsodium_msbuild_common_args}
        "/p:Configuration=${_libsodium_build_type}${_libsodium_linkage}" "/p:TargetName=${_libsodium_target_name}"
        "/p:OutDir=${_libsodium_output_dir}/" "/p:IntDir=${_libsodium_output_dir}/obj/"
      WORKING_DIRECTORY "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}"
                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS}
      RESULT_VARIABLE _libsodium_build_result)
    if(NOT _libsodium_build_result EQUAL 0)
      message(WARNING "Dependency(${PROJECT_NAME}): libsodium ${_libsodium_build_type} MSBuild failed")
      return()
    endif()
  endforeach()

  set(_libsodium_debug_output "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}/msbuild/Debug")
  set(_libsodium_release_output "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_BUILD_DIR}/msbuild/Release")
  set(_libsodium_debug_lib "${_libsodium_debug_output}/libsodium-dbg.lib")
  set(_libsodium_release_lib "${_libsodium_release_output}/libsodium.lib")
  if(NOT EXISTS "${_libsodium_debug_lib}" OR NOT EXISTS "${_libsodium_release_lib}")
    message(WARNING "Dependency(${PROJECT_NAME}): libsodium MSBuild did not produce the expected libraries")
    return()
  endif()
  if(_libsodium_linkage STREQUAL "DLL")
    set(_libsodium_debug_dll "${_libsodium_debug_output}/libsodium-dbg.dll")
    set(_libsodium_release_dll "${_libsodium_release_output}/libsodium.dll")
    if(NOT EXISTS "${_libsodium_debug_dll}" OR NOT EXISTS "${_libsodium_release_dll}")
      message(WARNING "Dependency(${PROJECT_NAME}): libsodium MSBuild did not produce the expected DLLs")
      return()
    endif()
  endif()

  file(INSTALL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium.h"
       DESTINATION "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include")
  file(INSTALL "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LIBSODIUM_SOURCE_DIR}/src/libsodium/include/sodium"
       DESTINATION "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include")
  file(REMOVE "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/Makefile.am"
       "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/version.h.in")

  file(
    REMOVE
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/libsodium-dbg.lib"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/libsodium.lib"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/sodium-dbg.lib"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib/sodium.lib"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/libsodium-dbg.dll"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/libsodium.dll"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/libsodium-dbg.pdb"
    "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin/libsodium.pdb")
  file(INSTALL "${_libsodium_debug_lib}" "${_libsodium_release_lib}"
       DESTINATION "${PROJECT_THIRD_PARTY_INSTALL_DIR}/lib")

  if(_libsodium_linkage STREQUAL "DLL")
    file(INSTALL "${_libsodium_debug_dll}" "${_libsodium_release_dll}"
         DESTINATION "${PROJECT_THIRD_PARTY_INSTALL_DIR}/bin")
  elseif(EXISTS "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/export.h")
    file(READ "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/export.h" _libsodium_export_h)
    string(REPLACE "#ifdef SODIUM_STATIC" "#if 1" _libsodium_patched_export_h "${_libsodium_export_h}")
    if(NOT _libsodium_export_h STREQUAL _libsodium_patched_export_h)
      file(WRITE "${PROJECT_THIRD_PARTY_INSTALL_DIR}/include/sodium/export.h" "${_libsodium_patched_export_h}")
    endif()
  endif()

  project_third_party_libsodium_msvc_import(_libsodium_local_found)
endfunction()
