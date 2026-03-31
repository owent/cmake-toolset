---
description: >-
  Use when editing or creating cmake port files
  under ports/. Covers port declaration, patch file
  naming, version variables, BUILD_OPTIONS patterns,
  and find_configure_package usage.
applyTo: "ports/**/*.cmake"
---

# CMake Port File Guidelines

## Structure Template

```cmake
include_guard(DIRECTORY)

# =========== third party {PORT_NAME} ============
# {upstream URL}
# =========== third party {PORT_NAME} ============

macro(PROJECT_THIRD_PARTY_{PORT}_IMPORT)
  if(TARGET {namespace}::{target})
    message(STATUS
      "Dependency(${PROJECT_NAME}): "
      "{PORT} using target "
      "{namespace}::{target}")
    set(
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PREFIX}_{PORT}_LINK_NAME
      {namespace}::{target})
  endif()
endmacro()

# Try system/prebuilt first
if(NOT TARGET {namespace}::{target})
  find_package({PackageName} QUIET)
  project_third_party_{port}_import()
endif()

if(NOT TARGET {namespace}::{target})
  project_third_party_port_declare(
    {port-name}
    VERSION "vX.Y.Z"
    GIT_URL "https://github.com/org/repo.git"
    BUILD_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DBUILD_TESTING=OFF")

  # Shared/static selection
  project_third_party_append_build_shared_lib_var(
    "{port-name}" ""
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_BUILD_OPTIONS
    BUILD_SHARED_LIBS)

  # Patch
  project_third_party_try_patch_file(
    ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_PATCH_FILE
    "${CMAKE_CURRENT_LIST_DIR}" "{port-name}"
    "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_VERSION}")

  if(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_PATCH_FILE
      AND EXISTS
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_PATCH_FILE}")
    list(APPEND
      ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_BUILD_OPTIONS
      GIT_PATCH_FILES
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_PATCH_FILE}")
  endif()

  find_configure_package(
    PACKAGE {PackageName}
    BUILD_WITH_CMAKE
    CMAKE_INHERIT_BUILD_ENV
    CMAKE_FLAGS
      ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_BUILD_OPTIONS}
    WORKING_DIRECTORY
      "${PROJECT_THIRD_PARTY_PACKAGE_DIR}"
    PREFIX_DIRECTORY
      "${PROJECT_THIRD_PARTY_INSTALL_DIR}"
    SRC_DIRECTORY_NAME
      "{port}-${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_VERSION}"
    GIT_BRANCH
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_VERSION}"
    GIT_URL
      "${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PORT}_GIT_URL}")

  project_third_party_{port}_import()
endif()
```

## Rules

- Use `PORT_PREFIX` when the port belongs to a
  dependency group (e.g., `"GRPC"` for abseil-cpp,
  re2, protobuf, grpc).
- Patch files go in the same directory as the port
  cmake file.
- Patch naming: `{port-name}-{version}.patch` — use
  the version at which the patch was created/tested.
- Always set versions as defaults (only if not
  already defined) — users can override via `-D`
  flags.
- Use `project_third_party_append_build_shared_lib_var`
  for `BUILD_SHARED_LIBS`, not hardcoded values.

## Truth Sources

- Use the upstream repository at the target tag for
  dependency pins, tag naming, and option changes.
- Use `ports/Configure.cmake` for macro behavior,
  patch matching, shared/static helpers, and
  cross-compiling host helpers.
- Use `test/CMakeLists.txt` for repository include
  order and compatibility guards.

## Special Patterns

- `import.cmake` files coordinate grouped includes and
  order. Do not treat them as simple single-port files.
- Orchestrators such as `ssl/port.cmake` select among
  multiple backends and may not call the standard
  template directly.
- Complex ports such as `protobuf/protobuf.cmake` may
  manage hosted tools, RTTI, visibility, or
  version-conditional logic.
- Ports with `crosscompiling-host/` assets may require
  host-side validation and `.cross.patch` handling in
  addition to the target build.
