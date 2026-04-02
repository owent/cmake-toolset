# cmake-toolset Project Guidelines

## Overview

CMake-based third-party dependency management toolkit
for fetching, patching, building, and installing
upstream libraries across platforms and toolchains.

## Build & Test

```bash
mkdir -p test/build_jobs_dir && cd test/build_jobs_dir
cmake .. \
  -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON
cmake --build . -j
ctest . -V
bash ci/format.sh
```

## Source of Truth

- `ports/Configure.cmake` — core macros, patch
  matching, shared/static helpers, and host-build
  helpers
- `test/CMakeLists.txt` — canonical include order and
  repository-specific compatibility guards
- `.github/workflows/build.yaml` and `ci/do_ci.*` —
  validated CI combinations
- upstream repo at the target tag — dependency pins,
  tag naming, and build option changes

## Structure

- `ports/` — standard ports, import aggregators, and
  orchestrators
- `modules/` — shared CMake helpers
- `test/` — integration coverage for most ports
- `ci/` — workflow entrypoints and platform wrappers

## Rules

- Historical dependency chains are hints only. Real
  pins come from upstream, and repository include order
  comes from `test/CMakeLists.txt`.
- Standard ports usually follow: `include_guard`,
  import macro, `find_package`,
  `project_third_party_port_declare`, patch lookup, and
  `find_configure_package`.
- Treat `ssl/port.cmake`, `grpc/import.cmake`, and
  `protobuf/protobuf.cmake` as special cases.
- Patch names are `{port}-{version}.patch` or
  `{port}-{version}.cross.patch`. Same-minor matching
  picks the highest version `<=` target.
- Ports with `crosscompiling-host/` assets need
  host-side validation.
- CMake style: 2-space indentation, lowercase function
  names, uppercase variables, `if(TARGET ...)`, and
  `echowithcolor()` for user-facing messages.
- **Pre-commit formatting is mandatory.** Before
  committing, run `cmake-format -i` on every modified
  `.cmake`, `.cmake.in`, and `CMakeLists.txt` file
  (excluding `test/third_party/` and
  `test/build_jobs_*/`). Alternatively run
  `bash ci/format.sh` to format the entire tree.
- Shared/static library selection uses
  `project_third_party_check_build_shared_lib()` with
  this priority (first match wins):
  1. `${FULL_PORT_NAME}_USE_SHARED` — per-port force
     shared
  2. `${FULL_PORT_NAME}_USE_STATIC` — per-port force
     static
  3. `BUILD_SHARED_LIBS` or
     `ATFRAMEWORK_USE_DYNAMIC_LIBRARY` — global shared
  4. Default — static
  where `FULL_PORT_NAME` =
  `ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_{PREFIX}_{PORT}`
  (uppercased). Environment variables with the same
  names are also checked. See `ports/Configure.cmake`
  for the full implementation. Ports must use the
  helper macros, not hardcode `BUILD_SHARED_LIBS`
  directly.
