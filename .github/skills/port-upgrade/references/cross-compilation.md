# Cross-Compilation Checks

## When to Use

Use this reference when a port:

- has a `crosscompiling-host/` directory
- calls `project_third_party_crosscompiling_host()`
- builds host tools such as `protoc`, `flatc`, or a
  gRPC plugin
- ships a `.cross.patch`

## Repository Truth Sources

- `ports/Configure.cmake` for
  `project_third_party_crosscompiling_host()`,
  host/target install directories, and
  `CMAKE_PROGRAM_PATH` handling
- the port file being upgraded for hosted-tool logic
- `test/CMakeLists.txt` and CI jobs for Android, iOS,
  and other cross-target coverage

## Current High-Risk Examples

- `abseil-cpp` and `flatbuffers` currently contain
  `crosscompiling-host/` assets
- `protobuf`, `grpc`, and related plugins require
  host-side tool discovery even when the target build is
  cross-compiled

## Checklist

1. Determine whether the port builds host tools, target
   libraries, or both.
2. Review host and target install directories:
   `PROJECT_THIRD_PARTY_HOST_INSTALL_DIR` and
   `PROJECT_THIRD_PARTY_INSTALL_DIR`.
3. If the port has a `.cross.patch`, test it separately
   from the normal patch.
4. Ensure host executables are searched from host paths
   and not the target sysroot.
5. If the port exports generated tools (`protoc`,
   `flatc`, plugins), verify downstream tests and ports
   still find them.
6. When the port affects Android, iOS, or other cross
   jobs, review `.github/workflows/build.yaml` and
   `ci/do_ci.*` for relevant matrix coverage.
7. After patch or build-logic changes, clear or rebuild
   host-side outputs before concluding validation.

## Common Failure Modes

- Reusing target executables during cross builds
- Updating only the target library but not host-side
  helper tools
- Forgetting to refresh `.cross.patch`
- Leaving stale host build artifacts that hide
  regressions
